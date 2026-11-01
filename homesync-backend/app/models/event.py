"""Event model: family calendar entries."""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base
from .family import utcnow


class Event(Base):
    __tablename__ = "events"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    family_id: Mapped[int] = mapped_column(
        ForeignKey("families.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    starts_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ends_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_by_user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    family: Mapped["Family"] = relationship(back_populates="events")
