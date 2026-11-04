"""Notifications: own inbox, mark read, mark all read."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import require_family_member
from ..models import Notification, User
from ..schemas.notifications import NotificationRead, ReadAllResult

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationRead])
def list_notifications(
    unread_only: bool = False,
    limit: int = Query(default=50, le=100),
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    query = db.query(Notification).filter(Notification.user_id == member.id)
    if unread_only:
        query = query.filter(Notification.is_read.is_(False))
    return query.order_by(Notification.id.desc()).limit(limit).all()


@router.put("/{notification_id}/read", response_model=NotificationRead)
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    note = (
        db.query(Notification)
        .filter(
            Notification.id == notification_id,
            Notification.user_id == member.id,
        )
        .first()
    )
    if note is None:
        raise HTTPException(status_code=404, detail="Notification not found.")
    note.is_read = True
    db.commit()
    db.refresh(note)
    return note


@router.post("/read-all", response_model=ReadAllResult)
def mark_all_read(
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    marked = (
        db.query(Notification)
        .filter(
            Notification.user_id == member.id,
            Notification.is_read.is_(False),
        )
        .update({"is_read": True}, synchronize_session=False)
    )
    db.commit()
    return ReadAllResult(marked_read=marked)
