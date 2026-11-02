"""Calendar: family event stubs."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import require_family_member
from ..models import Event, User
from ..schemas.events import EventCreate, EventRead

router = APIRouter(prefix="/calendar", tags=["calendar"])


@router.post("/events", response_model=EventRead, status_code=201)
def create_event(
    payload: EventCreate,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    event = Event(
        family_id=member.family_id,
        created_by_user_id=member.id,
        **payload.model_dump(),
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@router.get("/events", response_model=list[EventRead])
def list_events(
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    return (
        db.query(Event)
        .filter(Event.family_id == member.family_id)
        .order_by(Event.starts_at)
        .all()
    )


@router.get("/events/{event_id}", response_model=EventRead)
def get_event(
    event_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    event = (
        db.query(Event)
        .filter(
            Event.id == event_id,
            Event.family_id == member.family_id,
        )
        .first()
    )
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found.")
    return event


@router.delete("/events/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(
    event_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    event = (
        db.query(Event)
        .filter(
            Event.id == event_id,
            Event.family_id == member.family_id,
        )
        .first()
    )
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found.")
    db.delete(event)
    db.commit()
    return None
