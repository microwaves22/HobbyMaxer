"""Task model: chores and homework items."""

from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base
from .family import utcnow

TASK_TYPES = ("chore", "homework")
TASK_STATUSES = ("open", "pending_review", "approved")


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    family_id: Mapped[int] = mapped_column(
        ForeignKey("families.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    task_type: Mapped[str] = mapped_column(String(16), default="chore")
    points_reward: Mapped[int] = mapped_column(Integer, default=0)
    requires_photo: Mapped[bool] = mapped_column(Boolean, default=False)
    assigned_to_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    created_by_user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    status: Mapped[str] = mapped_column(String(32), default="open", index=True)
    due_date: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    family: Mapped["Family"] = relationship(back_populates="tasks")
    assigned_to: Mapped["User | None"] = relationship(
        back_populates="assigned_tasks", foreign_keys=[assigned_to_user_id]
    )
    created_by: Mapped["User | None"] = relationship(
        back_populates="created_tasks", foreign_keys=[created_by_user_id]
    )
    submissions: Mapped[list["TaskSubmission"]] = relationship(
        back_populates="task", cascade="all, delete-orphan"
    )
