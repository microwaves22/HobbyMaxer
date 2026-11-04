"""Families: setup plus child profiles with Kids/Teen mode."""

from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..core.security import get_current_user, get_password_hash, require_parent
from ..services.notification_service import family_prefs, notify_parents
from ..models import Event, Family, FamilyInvite, Task, TaskSubmission, User
from ..models.family import new_invite_code, normalize_invite_code, utcnow
from ..schemas.families import (
    FamilyCreate,
    FamilyInviteRead,
    FamilyJoin,
    FamilyRead,
    FamilyWithMembers,
    LoadBalanceRead,
)
from ..schemas.notifications import NotificationPrefs, NotificationPrefsUpdate
from ..schemas.users import ChildCreate, ChildModeUpdate, ChildPinUpdate, UserRead

router = APIRouter(prefix="/families", tags=["families"])


@router.post("/", response_model=FamilyRead, status_code=201)
def create_family(
    payload: FamilyCreate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already belong to a family.",
        )
    family = Family(
        name=payload.name, parent_pin_hashed=get_password_hash(payload.parent_pin)
    )
    db.add(family)
    for _ in range(3):
        try:
            db.flush()
            break
        except IntegrityError:
            db.rollback()
            db.add(family)
            family.invite_code = new_invite_code()
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create a family invite code.",
        )
    parent.family_id = family.id
    db.commit()
    db.refresh(family)
    return family


@router.post("/join", response_model=FamilyRead)
def join_family(
    payload: FamilyJoin,
    db: Session = Depends(get_db),
    member: User = Depends(get_current_user),
):
    """Attach the caller to a family via an invite code.

    Single-use co-parent invites redeem first (granting the parent role);
    otherwise the code matches a family invite code and the caller's role
    is preserved. Unknown, expired, and consumed codes all return 404 so
    codes cannot be probed.
    """
    if member.family_id is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already belong to a family.",
        )
    code = normalize_invite_code(payload.code)
    if code is not None:
        invite = (
            db.query(FamilyInvite)
            .filter(
                FamilyInvite.code == code,
                FamilyInvite.used_at.is_(None),
                FamilyInvite.expires_at > utcnow(),
            )
            .first()
        )
        if invite is not None:
            joined = _redeem_co_parent_invite(db, member, invite)
            notify_parents(
                db,
                db.get(Family, joined.id),
                exclude_user_id=member.id,
                kind="member_joined",
                title=f"{member.display_name} joined the family.",
            )
            db.commit()
            return joined
    family = (
        db.query(Family).filter(Family.invite_code == code).first()
        if code is not None
        else None
    )
    if family is None:
        raise HTTPException(status_code=404, detail="Invite code not found.")
    member.family_id = family.id
    notify_parents(
        db,
        family,
        exclude_user_id=member.id,
        kind="member_joined",
        title=f"{member.display_name} joined the family.",
    )
    db.commit()
    db.refresh(family)
    return family


def _redeem_co_parent_invite(db: Session, member: User, invite: FamilyInvite):
    """Attach [member] to the invite's family with the invite's role.

    Consumption is a conditional UPDATE so concurrent redeems cannot both
    succeed: only the first commit consumes a single-use code.
    """
    now = utcnow()
    member.family_id = invite.family_id
    member.role = invite.role
    if invite.role == "parent":
        member.mode = None
    consumed = (
        db.query(FamilyInvite)
        .filter(FamilyInvite.id == invite.id, FamilyInvite.used_at.is_(None))
        .update(
            {"used_at": now, "used_by_user_id": member.id},
            synchronize_session="fetch",
        )
    )
    family = db.get(Family, invite.family_id) if consumed else None
    if not consumed or family is None:
        db.rollback()
        raise HTTPException(status_code=404, detail="Invite code not found.")
    db.commit()
    db.refresh(family)
    return family


@router.post("/{family_id}/invites", response_model=FamilyInviteRead, status_code=201)
def create_invite(
    family_id: int,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    """Mint a single-use co-parent invite code for this family.

    The code expires after CO_PARENT_INVITE_HOURS (default 48) and is
    redeemed via `POST /families/join`, which grants the parent role.
    """
    family = db.get(Family, family_id)
    if family is None or parent.family_id != family.id:
        raise HTTPException(status_code=404, detail="Family not found.")
    expires_at = utcnow() + timedelta(hours=settings.co_parent_invite_hours)
    for _ in range(5):
        code = new_invite_code()
        if db.query(Family).filter(Family.invite_code == code).first():
            continue
        if db.query(FamilyInvite).filter(FamilyInvite.code == code).first():
            continue
        invite = FamilyInvite(
            family_id=family.id,
            code=code,
            role="parent",
            expires_at=expires_at,
            created_by_user_id=parent.id,
        )
        db.add(invite)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            continue
        db.refresh(invite)
        return invite
    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Could not create an invite code.",
    )


@router.get("/me", response_model=FamilyWithMembers)
def my_family(
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    family = db.get(Family, parent.family_id)
    if family is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    members = db.query(User).filter(User.family_id == family.id).all()
    return FamilyWithMembers(
        id=family.id,
        name=family.name,
        invite_code=family.invite_code,
        created_at=family.created_at,
        members=[UserRead.model_validate(m) for m in members],
    )


def _split_hundred(scores: list[int]) -> list[int]:
    """Largest-remainder percents summing to 100 (zeros when total is 0)."""
    total = sum(scores)
    if total == 0:
        return [0] * len(scores)
    raw = [score * 100 / total for score in scores]
    base = [int(value) for value in raw]
    leftover = 100 - sum(base)
    order = sorted(
        range(len(scores)), key=lambda i: raw[i] - base[i], reverse=True
    )
    for i in order[:leftover]:
        base[i] += 1
    return base


@router.get("/load-balance", response_model=LoadBalanceRead)
def load_balance(
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    """Per-parent workload shares over the trailing 7 days.

    Score = tasks created + approvals completed + events added, equal
    weights; percents use largest remainder so they sum to 100.
    """
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    parents = (
        db.query(User)
        .filter(User.family_id == parent.family_id, User.role == "parent")
        .order_by(User.id)
        .all()
    )
    since = utcnow() - timedelta(days=7)
    rows = []
    for candidate in parents:
        tasks_created = (
            db.query(Task)
            .filter(
                Task.family_id == parent.family_id,
                Task.created_by_user_id == candidate.id,
                Task.created_at >= since,
            )
            .count()
        )
        approvals = (
            db.query(TaskSubmission)
            .join(Task, TaskSubmission.task_id == Task.id)
            .filter(
                Task.family_id == parent.family_id,
                TaskSubmission.status == "approved",
                TaskSubmission.reviewed_by_user_id == candidate.id,
                TaskSubmission.reviewed_at >= since,
            )
            .count()
        )
        events_added = (
            db.query(Event)
            .filter(
                Event.family_id == parent.family_id,
                Event.created_by_user_id == candidate.id,
                Event.created_at >= since,
            )
            .count()
        )
        rows.append(
            {
                "user_id": candidate.id,
                "display_name": candidate.display_name,
                "tasks_created": tasks_created,
                "approvals": approvals,
                "events_added": events_added,
                "score": tasks_created + approvals + events_added,
            }
        )
    scores = [row["score"] for row in rows]
    for row, percent in zip(rows, _split_hundred(scores)):
        row["percent"] = percent
    return LoadBalanceRead(window_days=7, total=sum(scores), shares=rows)


@router.get("/me/preferences", response_model=NotificationPrefs)
def get_preferences(
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    family = db.get(Family, parent.family_id)
    if family is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    return NotificationPrefs(**family_prefs(family))


@router.put("/me/preferences", response_model=NotificationPrefs)
def update_preferences(
    payload: NotificationPrefsUpdate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    family = db.get(Family, parent.family_id)
    if family is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    stored = dict(family.notification_prefs or {})
    for key, value in payload.model_dump(exclude_unset=True).items():
        if value is not None:
            stored[key] = value
    family.notification_prefs = stored
    db.commit()
    return NotificationPrefs(**family_prefs(family))


@router.post("/{family_id}/children", response_model=UserRead, status_code=201)
def add_child(
    family_id: int,
    payload: ChildCreate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    family = db.get(Family, family_id)
    if family is None or parent.family_id != family.id:
        raise HTTPException(status_code=404, detail="Family not found.")
    child = User(
        family_id=family.id,
        display_name=payload.display_name,
        role="child",
        mode=payload.mode,
        child_pin_hashed=(
            get_password_hash(payload.child_pin) if payload.child_pin else None
        ),
    )
    db.add(child)
    db.commit()
    db.refresh(child)
    return child


@router.patch(
    "/{family_id}/children/{child_id}/pin", response_model=UserRead
)
def set_child_pin(
    family_id: int,
    child_id: int,
    payload: ChildPinUpdate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    """Set (or clear, with null) a child's login PIN. Parents only."""
    if parent.family_id != family_id:
        raise HTTPException(status_code=404, detail="Family not found.")
    child = (
        db.query(User)
        .filter(
            User.id == child_id,
            User.family_id == family_id,
            User.role == "child",
        )
        .first()
    )
    if child is None:
        raise HTTPException(status_code=404, detail="Child profile not found.")
    child.child_pin_hashed = (
        get_password_hash(payload.child_pin) if payload.child_pin else None
    )
    db.commit()
    db.refresh(child)
    return child


@router.patch("/{family_id}/children/{child_id}/mode", response_model=UserRead)
def set_child_mode(
    family_id: int,
    child_id: int,
    payload: ChildModeUpdate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id != family_id:
        raise HTTPException(status_code=404, detail="Family not found.")
    child = (
        db.query(User)
        .filter(
            User.id == child_id,
            User.family_id == family_id,
            User.role == "child",
        )
        .first()
    )
    if child is None:
        raise HTTPException(status_code=404, detail="Child profile not found.")
    child.mode = payload.mode
    db.commit()
    db.refresh(child)
    return child
