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
    child_pin: str | None = Field(default=None, min_length=4, max_length=16)


class ChildModeUpdate(BaseModel):
    mode: UserMode


class ChildPinUpdate(BaseModel):
    child_pin: str | None = Field(default=None, min_length=4, max_length=16)


class UserRead(_FromORM):
    id: int
    family_id: int | None
    email: str | None
    display_name: str
    role: str
    mode: str | None
    points_balance: int
<<<<<<< HEAD
    streak_count: int
    has_child_pin: bool = False
=======
    avatar_url: str | None = None
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
    created_at: datetime
