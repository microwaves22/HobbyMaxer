"""Task and submission schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

TaskType = Literal["chore", "homework"]
SubmissionStatus = Literal["pending", "approved", "changes_requested"]
ReviewAction = Literal["approve", "request_changes"]


class _FromORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    task_type: TaskType = "chore"
    points_reward: int = Field(default=0, ge=0)
    requires_photo: bool = False
    assigned_to_user_id: int | None = None
    due_date: datetime | None = None


class TaskRead(_FromORM):
    id: int
    family_id: int
    title: str
    description: str | None
    task_type: str
    points_reward: int
    requires_photo: bool
    assigned_to_user_id: int | None
    status: str
    due_date: datetime | None
    created_at: datetime


class SubmissionRead(_FromORM):
    id: int
    task_id: int
    submitted_by_user_id: int | None
    status: str
    photo_path: str | None
    note: str | None
    expires_at: datetime | None
    reviewed_at: datetime | None
    created_at: datetime


class ReviewRequest(BaseModel):
    action: ReviewAction = "approve"
    note: str | None = None
