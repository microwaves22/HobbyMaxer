"""Families: setup plus child profiles with Kids/Teen mode."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import get_password_hash, require_parent
from ..models import Family, User
from ..schemas.families import FamilyCreate, FamilyRead, FamilyWithMembers
from ..schemas.users import ChildCreate, ChildModeUpdate, UserRead

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
    db.flush()
    parent.family_id = family.id
    db.commit()
    db.refresh(family)
    return family


@router.get("/me", response_model=FamilyWithMembers)
def my_family(
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(status_code=404, detail="No family yet.")
    family = db.get(Family, parent.family_id)
    members = db.query(User).filter(User.family_id == family.id).all()
    return FamilyWithMembers(
        id=family.id,
        name=family.name,
        created_at=family.created_at,
        members=[UserRead.model_validate(m) for m in members],
    )


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
    )
    db.add(child)
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
