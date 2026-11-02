"""User model: parents and children with Kids/Teen mode."""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base
from .family import utcnow

USER_ROLES = ("parent", "child")
USER_MODES = ("kids", "teen")  # child profiles only; parents use None


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    family_id: Mapped[int | None] = mapped_column(
        ForeignKey("families.id", ondelete="SET NULL"), nullable=True, index=True
    )
    email: Mapped[str | None] = mapped_column(
        String(255), unique=True, nullable=True, index=True
    )
    hashed_password: Mapped[str | None] = mapped_column(String(255), nullable=True)
    display_name: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(16), default="parent", index=True)
    mode: Mapped[str | None] = mapped_column(String(16), nullable=True)
    points_balance: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    family: Mapped["Family | None"] = relationship(back_populates="users")
    created_tasks: Mapped[list["Task"]] = relationship(
        back_populates="created_by",
        foreign_keys="Task.created_by_user_id",
    )
    assigned_tasks: Mapped[list["Task"]] = relationship(
        back_populates="assigned_to",
        foreign_keys="Task.assigned_to_user_id",
    )
    submissions: Mapped[list["TaskSubmission"]] = relationship(
        back_populates="submitted_by",
        foreign_keys="TaskSubmission.submitted_by_user_id",
    )
    point_transactions: Mapped[list["PointTransaction"]] = relationship(
        back_populates="user",
        foreign_keys="PointTransaction.user_id",
    )
