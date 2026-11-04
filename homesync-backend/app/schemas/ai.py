"""Quick-add request/response schemas (strict draft validation)."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator

from ..models.task import normalize_repeat_rule


class QuickAddRequest(BaseModel):
    text: str = Field(min_length=1, max_length=2000)


class EventDraft(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    starts_at: datetime
    ends_at: datetime | None = None
    attendee_names: list[str] = []


class TaskDraft(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    task_type: Literal["chore", "homework"] = "chore"
    points_reward: int = Field(default=5, ge=0, le=1000)
    requires_photo: bool = False
    assigned_to_user_id: int | None = None
    assigned_to_name: str | None = None
    due_date: datetime | None = None
    repeat_rule: str | None = None

    @field_validator("repeat_rule")
    @classmethod
    def _valid_repeat(cls, value: str | None) -> str | None:
        if value is None:
            return None
        try:
            return normalize_repeat_rule(value)
        except ValueError:
            raise ValueError(
                "repeat_rule must be 'daily', 'weekly', or weekdays "
                "like 'mon,wed,fri'."
            ) from None


class QuickAddRead(BaseModel):
    events: list[EventDraft] = []
    tasks: list[TaskDraft] = []
    warnings: list[str] = []
