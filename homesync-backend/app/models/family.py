"""SQLAlchemy models for HomeSync."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Family(Base):
    __tablename__ = "families"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255))
    parent_pin_hashed: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    users: Mapped[list["User"]] = relationship(back_populates="family")
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
