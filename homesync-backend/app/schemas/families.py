"""Family schemas."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from .users import UserRead


class FamilyCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    parent_pin: str = Field(min_length=4, max_length=16)


class FamilyJoin(BaseModel):
    code: str = Field(min_length=6, max_length=9)


class FamilyRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    invite_code: str
    created_at: datetime


class FamilyInviteRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    family_id: int
    code: str
    role: str
    expires_at: datetime
    created_at: datetime


class LoadShare(BaseModel):
    user_id: int
    display_name: str
    tasks_created: int
    approvals: int
    events_added: int
    score: int
    percent: int


class LoadBalanceRead(BaseModel):
    window_days: int
    total: int
    shares: list[LoadShare] = []


class FamilyWithMembers(FamilyRead):
    members: list[UserRead] = []
