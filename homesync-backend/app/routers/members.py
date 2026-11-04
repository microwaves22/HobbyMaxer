"""Members: avatar upload for family profiles."""

import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..core.security import require_family_member
from ..models import User
from ..schemas.users import UserRead

router = APIRouter(prefix="/members", tags=["members"])

ALLOWED_AVATAR_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_AVATAR_BYTES = 5 * 1024 * 1024


def _avatars_dir() -> Path:
    path = Path(settings.uploads_dir) / "avatars"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _member_or_404(db: Session, member: User, member_id: int) -> User:
    target = (
        db.query(User)
        .filter(User.id == member_id, User.family_id == member.family_id)
        .first()
    )
    if target is None:
        raise HTTPException(status_code=404, detail="Member not found.")
    return target


def _remove_previous_avatar(previous_url: str | None) -> None:
    if not previous_url or not previous_url.startswith("/avatars/"):
        return
    try:
        previous = _avatars_dir() / Path(previous_url).name
        if previous.is_file():
            previous.unlink()
    except OSError:
        pass


@router.post("/{member_id}/avatar", response_model=UserRead)
def upload_member_avatar(
    member_id: int,
    avatar: UploadFile = File(...),
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    """Upload a profile picture for a family member.

    Accepts a compressed image (the Flutter client sends maxWidth 512,
    imageQuality 70 bytes), stores it under `uploads/avatars/`, and
    returns the updated member including the public `avatar_url`.
    """
    target = _member_or_404(db, member, member_id)
    ext = Path(avatar.filename or "").suffix.lower()
    if ext not in ALLOWED_AVATAR_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported file type: {ext or 'unknown'}.",
        )
    data = avatar.file.read()
    if len(data) > MAX_AVATAR_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Avatar is too large (5 MB max).",
        )
    if not data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Avatar file is empty.",
        )
    filename = f"avatar_{target.id}_{uuid.uuid4().hex}{ext}"
    (_avatars_dir() / filename).write_bytes(data)
    _remove_previous_avatar(target.avatar_url)
    target.avatar_url = f"/avatars/{filename}"
    db.commit()
    db.refresh(target)
    return target
