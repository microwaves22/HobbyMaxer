"""Rewards: parent-managed catalog plus point redemptions."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import get_current_user, require_family_member, require_parent
from ..models import PointTransaction, Reward, User
from ..schemas.rewards import RewardCreate, RewardRead, TransactionRead
from ..services.points_service import apply_points

router = APIRouter(prefix="/rewards", tags=["rewards"])


@router.post("/", response_model=RewardRead, status_code=201)
def create_reward(
    payload: RewardCreate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Create a family first.",
        )
    reward = Reward(family_id=parent.family_id, **payload.model_dump())
    db.add(reward)
    db.commit()
    db.refresh(reward)
    return reward


@router.get("/", response_model=list[RewardRead])
def list_rewards(
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    return (
        db.query(Reward)
        .filter(Reward.family_id == member.family_id)
        .order_by(Reward.id)
        .all()
    )


@router.post("/{reward_id}/redeem", response_model=TransactionRead, status_code=201)
def redeem_reward(
    reward_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(get_current_user),
):
    reward = (
        db.query(Reward)
        .filter(
            Reward.id == reward_id,
            Reward.family_id == member.family_id,
        )
        .first()
    )
    if reward is None:
        raise HTTPException(status_code=404, detail="Reward not found.")
    if member.points_balance < reward.cost_points:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not enough points.",
        )
    txn = apply_points(
        db,
        member,
        -reward.cost_points,
        "reward_redeemed",
        ref_type="reward",
        ref_id=reward.id,
    )
    db.commit()
    db.refresh(txn)
    return txn


@router.get("/ledger/me", response_model=list[TransactionRead])
def my_ledger(
    db: Session = Depends(get_db),
    member: User = Depends(get_current_user),
):
    return (
        db.query(PointTransaction)
        .filter(PointTransaction.user_id == member.id)
        .order_by(PointTransaction.id.desc())
        .all()
    )
