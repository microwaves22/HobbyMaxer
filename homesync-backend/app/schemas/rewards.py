"""Reward catalog and ledger schemas."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

RewardKind = Literal["avatar", "pet", "perk"]


class _FromORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class RewardCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    description: str | None = None
    cost_points: int = Field(ge=1)
    kind: RewardKind = "perk"


class RewardRead(_FromORM):
    id: int
    family_id: int
    name: str
    description: str | None
    cost_points: int
    kind: str
    created_at: datetime


class TransactionRead(_FromORM):
    id: int
    family_id: int
    user_id: int
    amount: int
    balance_after: int
    reason: str
    ref_type: str | None
    ref_id: int | None
    created_at: datetime
