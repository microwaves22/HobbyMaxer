"""Quick-add providers: Muse when configured, local fallback offline.

`QuickAddProvider.parse` returns plain dicts shaped like the response
schemas; the router validates every item strictly through Pydantic and
drops invalid ones with a warning. Nothing here persists anything.

`MuseQuickAddProvider` calls a Muse chat-completions endpoint
(OpenAI-compatible) using `MUSE_PROMPT_TEMPLATE` and returns the
model's JSON verbatim for the router to validate. Any transport error,
non-JSON reply, or wrong-shaped payload raises `QuickAddProviderError`
so the router can fall back to `LocalQuickAddProvider`, which serves
every request offline and deterministically.
"""

import json
import re
import urllib.error
import urllib.request
from datetime import datetime, timedelta
from typing import Protocol

WEEKDAYS = {
    "monday": 0,
    "tuesday": 1,
    "wednesday": 2,
    "thursday": 3,
    "friday": 4,
    "saturday": 5,
    "sunday": 6,
    "mon": 0,
    "tue": 1,
    "tues": 1,
    "wed": 2,
    "thu": 3,
    "thur": 3,
    "thurs": 3,
    "fri": 4,
    "sat": 5,
    "sun": 6,
}

TASK_VERBS = (
    "needs to",
    "need to",
    "has to",
    "have to",
    "must",
    "should",
)

CHORE_WORDS = (
    "empty",
    "clean",
    "mow",
    "wash",
    "vacuum",
    "tidy",
    "trash",
    "dishes",
    "dishwasher",
    "laundry",
    "room",
    "lawn",
    "homework",
    "finish",
    "do",
)

MUSE_PROMPT_TEMPLATE = """You are HomeSync's quick-add parser. Extract calendar events and
chore/homework tasks from one parent message. Reply with JSON only:

{"events": [{"title": str, "starts_at": str, "ends_at": str | null,
"attendee_names": [str]}], "tasks": [{"title": str,
"description": str | null, "task_type": "chore" | "homework",
"points_reward": int, "requires_photo": false,
"assigned_to_user_id": int | null, "assigned_to_name": str | null,
"due_date": str | null, "repeat_rule": str | null}], "warnings": [str]}

Rules: datetimes are ISO-8601 UTC; resolve weekday names to the next
future date; bare hours 1-11 mean PM; match people against the roster
below and warn on unknown names; repeat_rule is "daily", "weekly", or
weekday names like "mon,wed", else null; never invent people, points,
or times that are absent; warn instead of guessing.
Roster: {roster}
Message: {text}"""


class QuickAddProviderError(Exception):
    """Muse transport, JSON, or shape failure (router falls back local)."""


def build_muse_prompt(
    text: str, members: list[tuple[int, str]], now: datetime
) -> str:
    """Fill `MUSE_PROMPT_TEMPLATE` with the roster, now, and message."""
    if members:
        roster = ", ".join(f"{name} (id {uid})" for uid, name in members)
    else:
        roster = "none"
    stamped = f"[Now: {now.isoformat()}] {text}"
    # Plain replace: the template's JSON braces are literal, not fields.
    return MUSE_PROMPT_TEMPLATE.replace("{roster}", roster).replace(
        "{text}", stamped
    )


class QuickAddProvider(Protocol):
    """Returns raw draft dicts; the router validates strictly."""

    def parse(
        self,
        text: str,
        members: list[tuple[int, str]],
        now: datetime,
    ) -> dict:
        ...


class MuseQuickAddProvider:
    """Live Muse call over an OpenAI-compatible chat-completions API.

    Credentials come from settings (`META_AI_API_KEY`, `META_AI_API_URL`,
    `META_AI_MODEL`) unless passed explicitly (tests inject fakes).
    """

    prompt_template = MUSE_PROMPT_TEMPLATE

    def __init__(
        self,
        api_key: str | None = None,
        api_url: str | None = None,
        model: str | None = None,
        timeout_seconds: int = 15,
    ):
        from ..core.config import settings

        self.api_key = api_key if api_key is not None else settings.meta_ai_api_key
        self.api_url = api_url if api_url is not None else settings.meta_ai_api_url
        self.model = model if model is not None else settings.meta_ai_model
        self.timeout_seconds = timeout_seconds

    def parse(self, text, members, now):
        if not self.api_key:
            raise QuickAddProviderError("META_AI_API_KEY is not configured.")
        body = {
            "model": self.model,
            "temperature": 0,
            "response_format": {"type": "json_object"},
            "messages": [
                {
                    "role": "user",
                    "content": build_muse_prompt(text, members, now),
                }
            ],
        }
        request = urllib.request.Request(
            self.api_url,
            data=json.dumps(body).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(
                request, timeout=self.timeout_seconds
            ) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            raise QuickAddProviderError(
                f"Muse HTTP {exc.code}."
            ) from exc
        except (urllib.error.URLError, TimeoutError, OSError) as exc:
            raise QuickAddProviderError(
                f"Muse unreachable ({exc})."
            ) from exc
        except ValueError as exc:
            raise QuickAddProviderError(
                "Muse returned invalid JSON."
            ) from exc
        try:
            content = payload["choices"][0]["message"]["content"]
            data = json.loads(content)
        except (KeyError, IndexError, TypeError) as exc:
            raise QuickAddProviderError(
                "Muse reply had no message content."
            ) from exc
        except ValueError as exc:
            raise QuickAddProviderError(
                "Muse message was not JSON."
            ) from exc
        if not isinstance(data, dict):
            raise QuickAddProviderError("Muse returned non-object JSON.")
        events = data.get("events", [])
        tasks = data.get("tasks", [])
        warnings = data.get("warnings", [])
        if not isinstance(events, list) or not isinstance(tasks, list):
            raise QuickAddProviderError(
                "Muse JSON must hold 'events' and 'tasks' lists."
            )
        if not isinstance(warnings, list):
            warnings = []
        return {
            "events": events,
            "tasks": tasks,
            "warnings": [str(item) for item in warnings],
        }


def _hour_24(hour: int, meridiem: str | None) -> int:
    if meridiem == "am":
        return 0 if hour == 12 else hour
    if meridiem == "pm":
        return hour if hour == 12 else hour + 12
    if hour == 12:
        return 12
    if 1 <= hour <= 11:
        return hour + 12  # bare hours default to PM
    return hour


def _next_weekday(base: datetime, target: int) -> datetime:
    day = base.date() + timedelta(days=(target - base.weekday()) % 7)
    return datetime(
        day.year, day.month, day.day, tzinfo=base.tzinfo or None
    )


class LocalQuickAddProvider:
    """Roster-aware heuristic parser. Deterministic, offline, tested."""

    _range = re.compile(
        r"(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*[-\u2013\u2014]"
        r"\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?",
        re.IGNORECASE,
    )
    _single = re.compile(
        r"(?:\bat\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b)"
        r"|(?:\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b)",
        re.IGNORECASE,
    )
    _points = re.compile(
        r"(\d{1,4})\s*(?:pts?|points?)\b|\bfor\s+(\d{1,4})\b",
        re.IGNORECASE,
    )

    def parse(self, text, members, now):
        events: list[dict] = []
        tasks: list[dict] = []
        warnings: list[str] = []
        roster = {name.lower(): (uid, name) for uid, name in members}
        firsts = {name.split()[0].lower(): (uid, name) for uid, name in members}
        clauses = [
            c.strip() for c in re.split(r"\s*(?:,?\s+and\s+|;)\s*", text) if c.strip()
        ]
        for clause in clauses:
            self._parse_clause(clause, roster, firsts, now, events, tasks, warnings)
        if not events and not tasks and not warnings:
            warnings.append(
                "Couldn't find any events or tasks — "
                "try names, days, and times."
            )
        return {"events": events, "tasks": tasks, "warnings": warnings}

    def _parse_clause(self, clause, roster, firsts, now, events, tasks, warnings):
        lowered = clause.lower()
        person = self._match_person(clause, roster, firsts)
        suspect = None
        if person is None:
            suspect = self._suspect_name(clause)
            if suspect is not None:
                warnings.append(
                    f"Couldn't match '{suspect}' to a family member."
                )
                clause = re.sub(
                    rf"\b{re.escape(suspect)}\b", " ", clause
                )
        day = self._match_day(lowered)
        start, end, span = self._match_time(clause, day, now)
        points = self._match_points(clause)
        repeat = self._match_repeat(lowered)
        taskish = (
            points is not None
            or repeat is not None
            or any(v in lowered for v in TASK_VERBS)
            or any(re.search(rf"\b{w}\b", lowered) for w in CHORE_WORDS)
        )
        if start is not None:
            title = self._event_title(clause, person, span)
            events.append({
                "title": title,
                "starts_at": start.isoformat(),
                "ends_at": end.isoformat() if end else None,
                "attendee_names": [person[1]] if person else [],
            })
        elif taskish:
            title = self._task_title(clause, person)
            due = self._due_date(day, now)
            tasks.append({
                "title": title,
                "description": None,
                "task_type": "homework" if "homework" in lowered else "chore",
                "points_reward": points if points is not None else 5,
                "requires_photo": False,
                "assigned_to_user_id": person[0] if person else None,
                "assigned_to_name": person[1] if person else None,
                "due_date": due.isoformat() if due else None,
                "repeat_rule": repeat,
            })
        elif day is not None:
            date = _next_weekday(now, day).replace(hour=9, minute=0)
            if date <= now:
                date += timedelta(days=7)
            title = self._event_title(clause, person, None)
            events.append({
                "title": title,
                "starts_at": date.isoformat(),
                "ends_at": None,
                "attendee_names": [person[1]] if person else [],
            })
        else:
            warnings.append(f"Couldn't understand '{clause}'.")

    def _match_person(self, clause, roster, firsts):
        lowered = f" {clause.lower()} "
        for table in (roster, firsts):
            for key, found in table.items():
                if f" {key} " in lowered or lowered.startswith(f"{key} "):
                    return found
        return None

    def _suspect_name(self, clause):
        words = re.findall(r"[A-Za-z']+", clause)
        if not words:
            return None
        first = words[0]
        if (
            first[0].isupper()
            and first.lower() not in WEEKDAYS
            and first.lower() not in ("today", "tomorrow")
        ):
            return first
        return None

    def _match_day(self, lowered):
        if re.search(r"\btoday\b", lowered):
            return "today"
        if re.search(r"\btomorrow\b", lowered):
            return "tomorrow"
        for name, number in WEEKDAYS.items():
            if re.search(rf"\b{name}\b", lowered):
                return number
        return None

    def _match_time(self, clause, day, now):
        match = self._range.search(clause)
        if match:
            start_mer = (match.group(3) or match.group(6) or "").lower() or None
            end_mer = (match.group(6) or match.group(3) or "").lower() or None
            start = self._at_time(
                now, day, int(match.group(1)), match.group(2), start_mer
            )
            end = self._at_time(
                now, day, int(match.group(4)), match.group(5), end_mer
            )
            if end <= start:
                end += timedelta(hours=12)
            return start, end, match.span()
        match = self._single.search(clause)
        if match:
            hour = match.group(1) or match.group(4)
            minute = match.group(2) or match.group(5)
            meridiem = (match.group(3) or match.group(6) or "").lower() or None
            start = self._at_time(now, day, int(hour), minute, meridiem)
            return start, None, match.span()
        return None, None, None

    def _at_time(self, now, day, hour, minute, meridiem):
        if day == "today":
            base = now
        elif day == "tomorrow":
            base = now + timedelta(days=1)
        elif isinstance(day, int):
            base = _next_weekday(now, day)
        else:
            base = now
        moment = base.replace(
            hour=_hour_24(hour, meridiem),
            minute=int(minute) if minute else 0,
            second=0,
            microsecond=0,
        )
        if moment <= now:
            moment += timedelta(days=7 if isinstance(day, int) else 1)
        return moment

    def _match_points(self, clause):
        match = self._points.search(clause)
        if not match:
            return None
        return int(match.group(1) or match.group(2))

    def _match_repeat(self, lowered):
        if re.search(r"\bdaily\b", lowered) or re.search(
            r"\bevery\s+day\b", lowered
        ):
            return "daily"
        if re.search(r"\bweekly\b", lowered) or re.search(
            r"\bevery\s+week\b", lowered
        ):
            return "weekly"
        days = [
            name
            for name, _ in sorted(WEEKDAYS.items(), key=lambda kv: kv[1])
            if len(name) > 3
            and re.search(rf"\bevery\s+{name}\b", lowered)
        ]
        if days:
            return ",".join(n[:3] for n in days)
        return None

    def _due_date(self, day, now):
        if day == "today":
            return now.replace(hour=18, minute=0, second=0, microsecond=0)
        if day == "tomorrow":
            base = now + timedelta(days=1)
            return base.replace(hour=18, minute=0, second=0, microsecond=0)
        if isinstance(day, int):
            base = _next_weekday(now, day).replace(hour=18, minute=0)
            if base <= now:
                base += timedelta(days=7)
            return base
        return None

    def _strip(self, clause, *patterns):
        text = clause
        for pattern in patterns:
            text = re.sub(pattern, " ", text, flags=re.IGNORECASE)
        return re.sub(r"\s+", " ", text).strip(" ,.-")

    def _event_title(self, clause, person, span):
        text = clause
        if span is not None:
            text = text[: span[0]] + " " + text[span[1] :]
        if person is not None:
            for form in {person[1], person[1].split()[0]}:
                text = re.sub(rf"\b{re.escape(form)}\b", " ", text, flags=re.IGNORECASE)
        text = self._strip(
            text,
            r"\b(?:has|have|with)\b",
            r"\b(?:" + "|".join(WEEKDAYS) + r"|today|tomorrow)\b",
            r"\d",
        )
        return text[:1].upper() + text[1:] if text else "Event"

    def _task_title(self, clause, person):
        text = clause
        if person is not None:
            for form in {person[1], person[1].split()[0]}:
                text = re.sub(rf"\b{re.escape(form)}\b", " ", text, flags=re.IGNORECASE)
        text = self._strip(
            text,
            r"\bneeds?\s+to\b",
            r"\bha(?:s|ve)\s+to\b",
            r"\bmust\b",
            r"\bshould\b",
            r"\b(?:" + "|".join(WEEKDAYS) + r"|today|tomorrow)\b",
            r"\bdaily\b",
            r"\bweekly\b",
            r"\bevery\s+\w+\b",
            r"\bfor\s+\d+\s*(?:pts?|points?)?\b",
            r"\d+\s*(?:pts?|points?)\b",
        )
        return text[:1].upper() + text[1:] if text else "Task"
