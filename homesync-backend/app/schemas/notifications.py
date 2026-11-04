"""Notification and preference schemas."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class NotificationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    type: str
    title: str
    body: str | None
    ref_type: str | None
    ref_id: int | None
    is_read: bool
    created_at: datetime


class ReadAllResult(BaseModel):
    marked_read: int


class NotificationPrefs(BaseModel):
    review_needed: bool = True
    approved: bool = True
    member_joined: bool = True


class NotificationPrefsUpdate(BaseModel):
    review_needed: bool | None = None
    approved: bool | None = None
    member_joined: bool | None = None
