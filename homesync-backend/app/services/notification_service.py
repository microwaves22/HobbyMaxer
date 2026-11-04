"""In-app notification fan-out for co-parents.

Triggers live at the call sites (submission, review, join); this module
owns preference gating plus one row per recipient parent. Commits
nothing: the caller commits with the triggering change.
"""

from sqlalchemy.orm import Session

from ..models import Family, Notification, User
from ..models.notification import NOTIFICATION_TYPES


def family_prefs(family: Family | None) -> dict[str, bool]:
    """Stored family preferences merged over all-enabled defaults."""
    stored = family.notification_prefs if family is not None else None
    stored = stored if isinstance(stored, dict) else {}
    return {kind: bool(stored.get(kind, True)) for kind in NOTIFICATION_TYPES}


def notify_parents(
    db: Session,
    family: Family | None,
    *,
    exclude_user_id: int,
    kind: str,
    title: str,
    body: str | None = None,
    ref_type: str | None = None,
    ref_id: int | None = None,
) -> list[Notification]:
    """Queue one unread row per parent except the actor; skips unknown
    and family-disabled types."""
    if family is None or kind not in NOTIFICATION_TYPES:
        return []
    if not family_prefs(family).get(kind, True):
        return []
    parents = (
        db.query(User)
        .filter(
            User.family_id == family.id,
            User.role == "parent",
            User.id != exclude_user_id,
        )
        .all()
    )
    rows = [
        Notification(
            family_id=family.id,
            user_id=parent.id,
            type=kind,
            title=title,
            body=body,
            ref_type=ref_type,
            ref_id=ref_id,
        )
        for parent in parents
    ]
    db.add_all(rows)
    return rows
