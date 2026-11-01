"""Calendar event schemas."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class EventCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    starts_at: datetime
    ends_at: datetime | None = None


class EventRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    family_id: int
    title: str
    description: str | None
    starts_at: datetime
    ends_at: datetime | None
    created_at: datetime
