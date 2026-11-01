"""Family schemas."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from .users import UserRead


class FamilyCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    parent_pin: str = Field(min_length=4, max_length=16)


class FamilyRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    created_at: datetime


class FamilyWithMembers(FamilyRead):
    members: list[UserRead] = []
