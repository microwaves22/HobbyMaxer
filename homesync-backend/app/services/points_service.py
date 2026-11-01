"""Point ledger: every balance change goes through here.

Balance update + ledger insert happen in one transaction so the audit trail
can never drift from the balance. (SQLite serializes writers, so a single
commit keeps concurrent redemptions consistent.)
"""

from sqlalchemy.orm import Session

from ..models import PointTransaction, User


def apply_points(
    db: Session,
    user: User,
    amount: int,
    reason: str,
    ref_type: str | None = None,
    ref_id: int | None = None,
) -> PointTransaction:
    user.points_balance += amount
    db.flush()
    txn = PointTransaction(
        family_id=user.family_id,
        user_id=user.id,
        amount=amount,
        balance_after=user.points_balance,
        reason=reason,
        ref_type=ref_type,
        ref_id=ref_id,
    )
    db.add(txn)
    db.flush()
    return txn
