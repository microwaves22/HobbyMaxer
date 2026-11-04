"""Single-use co-parent invite codes with expiry.

A parent mints an invite (`POST /families/{id}/invites`); the second
parent registers/logs in and redeems it (`POST /families/join`), which
attaches them to the family with the parent role and consumes the code.
Legacy `families.invite_code` values keep working on `/join` unchanged.
"""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base
from .family import utcnow


class FamilyInvite(Base):
    __tablename__ = "family_invites"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    family_id: Mapped[int] = mapped_column(
        ForeignKey("families.id", ondelete="CASCADE"), index=True
    )
    code: Mapped[str] = mapped_column(String(6), unique=True, index=True)
    role: Mapped[str] = mapped_column(String(16), default="parent")
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), index=True
    )
    used_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    used_by_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    created_by_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow
    )

    family: Mapped["Family"] = relationship(back_populates="invites")
