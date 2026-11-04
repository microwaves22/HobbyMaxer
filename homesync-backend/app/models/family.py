"""SQLAlchemy models for HomeSync."""

import secrets
from datetime import datetime, timezone

from sqlalchemy import JSON, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


_INVITE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def new_invite_code() -> str:
    """Random 6-character family invite code (no ambiguous glyphs)."""
    return "".join(secrets.choice(_INVITE_ALPHABET) for _ in range(6))


def normalize_invite_code(raw: str) -> str | None:
    """Normalize user input to the compact code, or None when malformed."""
    compact = "".join(ch for ch in raw.upper() if ch.isalnum())
    return compact if len(compact) == 6 else None


class Family(Base):
    __tablename__ = "families"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255))
    parent_pin_hashed: Mapped[str] = mapped_column(String(255))
    invite_code: Mapped[str] = mapped_column(
        String(6), unique=True, index=True, default=new_invite_code
    )
    notification_prefs: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    users: Mapped[list["User"]] = relationship(back_populates="family")
    invites: Mapped[list["FamilyInvite"]] = relationship(
        back_populates="family", cascade="all, delete-orphan"
    )
    tasks: Mapped[list["Task"]] = relationship(
        back_populates="family", cascade="all, delete-orphan"
    )
    rewards: Mapped[list["Reward"]] = relationship(
        back_populates="family", cascade="all, delete-orphan"
    )
    events: Mapped[list["Event"]] = relationship(
        back_populates="family", cascade="all, delete-orphan"
    )
    point_transactions: Mapped[list["PointTransaction"]] = relationship(
        back_populates="family", cascade="all, delete-orphan"
    )
