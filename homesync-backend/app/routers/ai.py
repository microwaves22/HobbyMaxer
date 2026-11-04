"""Meta AI quick-add: natural language to draft events and tasks.

Drafts only — nothing is persisted. Parents review and tap Confirm in
the app, which saves through the existing events/tasks endpoints.
Provider output is validated strictly: invalid drafts are dropped with
a warning instead of failing the request. Muse serves requests when
`META_AI_API_KEY` is set; any Muse failure falls back to the offline
local parser with a warning, so the endpoint never 500s on AI errors.
"""

import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import ValidationError
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..core.security import require_parent
from ..models import User
from ..models.family import utcnow
from ..schemas.ai import EventDraft, QuickAddRead, QuickAddRequest, TaskDraft
from ..services.ai_provider import (
    LocalQuickAddProvider,
    MuseQuickAddProvider,
    QuickAddProviderError,
)

router = APIRouter(prefix="/ai", tags=["ai"])

logger = logging.getLogger("homesync")


def _strict(items, model, kind, warnings):
    if not isinstance(items, list):
        warnings.append(f"Skipped invalid {kind} drafts: expected a list.")
        return []
    valid = []
    for item in items:
        try:
            valid.append(model.model_validate(item))
        except ValidationError as exc:
            detail = "; ".join(
                f"{'.'.join(str(part) for part in error['loc'])}: "
                f"{error['msg']}"
                for error in exc.errors()
            )
            warnings.append(f"Skipped invalid {kind} draft: {detail}.")
    return valid


def _parse_raw(text, members, now):
    """Muse when configured, else local; Muse errors fall back local."""
    if not settings.meta_ai_api_key:
        return LocalQuickAddProvider().parse(text, members, now)
    try:
        return MuseQuickAddProvider().parse(text, members, now)
    except QuickAddProviderError as exc:
        logger.warning("Muse quick-add failed, using local parser: %s", exc)
        raw = LocalQuickAddProvider().parse(text, members, now)
        raw["warnings"] = [
            f"Muse parse failed ({exc}); used offline parser instead.",
            *raw.get("warnings", []),
        ]
        return raw


@router.post("/quick-add", response_model=QuickAddRead)
def quick_add(
    payload: QuickAddRequest,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    members = [
        (user.id, user.display_name)
        for user in db.query(User)
        .filter(User.family_id == parent.family_id)
        .order_by(User.id)
        .all()
    ]
    raw = _parse_raw(payload.text, members, utcnow())
    if not isinstance(raw, dict):
        raw = {"events": [], "tasks": [], "warnings": []}
    warnings = [str(item) for item in raw.get("warnings", []) or []]
    events = _strict(raw.get("events", []), EventDraft, "event", warnings)
    tasks = _strict(raw.get("tasks", []), TaskDraft, "task", warnings)
    if not events and not tasks and not warnings:
        warnings.append(
            "Couldn't find any events or tasks — "
            "try names, days, and times."
        )
    return QuickAddRead(events=events, tasks=tasks, warnings=warnings)
