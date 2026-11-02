"""User and child-profile schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

UserRole = Literal["parent", "child"]
UserMode = Literal["kids", "teen"]


class _FromORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class ChildCreate(BaseModel):
    display_name: str = Field(min_length=1, max_length=255)
    mode: UserMode


class ChildModeUpdate(BaseModel):
    mode: UserMode


class UserRead(_FromORM):
    id: int
    family_id: int | None
    email: str | None
    display_name: str
    role: str
    mode: str | None
    points_balance: int
    created_at: datetime
