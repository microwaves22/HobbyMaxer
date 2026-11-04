"""Task model: chores and homework items."""

from datetime import datetime, timedelta

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base
from .family import utcnow

TASK_TYPES = ("chore", "homework")
TASK_STATUSES = ("open", "pending_review", "approved")

WEEKDAY_NUMBERS = {
    "mon": 0,
    "tue": 1,
    "wed": 2,
    "thu": 3,
    "fri": 4,
    "sat": 5,
    "sun": 6,
}
WEEKDAY_NAMES = ("mon", "tue", "wed", "thu", "fri", "sat", "sun")


def parse_repeat_rule(rule: str | None):
    """Parse a repeat rule to "daily", "weekly", or a weekday-number set.

    Returns None for blank rules; raises ValueError when malformed.
    """
    if rule is None:
        return None
    text = rule.strip().lower()
    if text in ("", "none"):
        return None
    if text in ("daily", "weekly"):
        return text
    days = set()
    for part in text.split(","):
        day = WEEKDAY_NUMBERS.get(part.strip())
        if day is None:
            raise ValueError(f"Invalid repeat rule: {rule!r}.")
        days.add(day)
    if not days:
        raise ValueError(f"Invalid repeat rule: {rule!r}.")
    return days


def normalize_repeat_rule(rule: str | None) -> str | None:
    """Canonical storage form ("daily", "weekly", "mon,wed")."""
    parsed = parse_repeat_rule(rule)
    if parsed is None or isinstance(parsed, str):
        return parsed
    return ",".join(WEEKDAY_NAMES[day] for day in sorted(parsed))


def next_repeat_date(rule: str, anchor: datetime) -> datetime:
    """Next occurrence strictly after [anchor]'s date (time preserved)."""
    parsed = parse_repeat_rule(rule)
    if parsed == "daily":
        return anchor + timedelta(days=1)
    if parsed == "weekly":
        return anchor + timedelta(days=7)
    days = parsed if isinstance(parsed, set) else set()
    candidate = anchor
    for _ in range(7):
        candidate += timedelta(days=1)
        if candidate.weekday() in days:
            return candidate
    raise ValueError(f"Invalid repeat rule: {rule!r}.")


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    family_id: Mapped[int] = mapped_column(
        ForeignKey("families.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    task_type: Mapped[str] = mapped_column(String(16), default="chore")
    points_reward: Mapped[int] = mapped_column(Integer, default=0)
    requires_photo: Mapped[bool] = mapped_column(Boolean, default=False)
    assigned_to_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    created_by_user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    status: Mapped[str] = mapped_column(String(32), default="open", index=True)
    due_date: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    repeat_rule: Mapped[str | None] = mapped_column(String(32), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    family: Mapped["Family"] = relationship(back_populates="tasks")
    assigned_to: Mapped["User | None"] = relationship(
        back_populates="assigned_tasks", foreign_keys=[assigned_to_user_id]
    )
    created_by: Mapped["User | None"] = relationship(
        back_populates="created_tasks", foreign_keys=[created_by_user_id]
    )
    submissions: Mapped[list["TaskSubmission"]] = relationship(
        back_populates="task", cascade="all, delete-orphan"
    )
