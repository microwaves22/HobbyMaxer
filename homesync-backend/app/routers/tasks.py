"""Tasks: parent creation, child photo submissions, parent review."""

import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..core.security import get_current_user, require_family_member, require_parent
from ..models import Family, Task, TaskSubmission, User
from ..models.task import next_repeat_date
from ..schemas.tasks import ReviewRequest, SubmissionRead, TaskCreate, TaskRead
from ..services.notification_service import notify_parents
from ..services.points_service import apply_points

router = APIRouter(prefix="/tasks", tags=["tasks"])

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".heic"}


def _family_task_or_404(db: Session, user: User, task_id: int) -> Task:
    task = (
        db.query(Task)
        .filter(Task.id == task_id, Task.family_id == user.family_id)
        .first()
    )
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found.")
    return task


@router.post("/", response_model=TaskRead, status_code=201)
def create_task(
    payload: TaskCreate,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    if parent.family_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Create a family first.",
        )
    if payload.assigned_to_user_id is not None:
        assignee = (
            db.query(User)
            .filter(
                User.id == payload.assigned_to_user_id,
                User.family_id == parent.family_id,
            )
            .first()
        )
        if assignee is None:
            raise HTTPException(status_code=404, detail="Assignee not found.")
    task = Task(
        family_id=parent.family_id,
        created_by_user_id=parent.id,
        status="open",
        **payload.model_dump(),
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@router.get("/", response_model=list[TaskRead])
def list_tasks(
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    query = (
        db.query(Task)
        .filter(Task.family_id == member.family_id)
        .order_by(Task.id)
    )
    if member.role == "child":
        query = query.filter(
            (Task.assigned_to_user_id == member.id)
            | (Task.assigned_to_user_id.is_(None))
        )
    return query.all()


@router.get("/{task_id}", response_model=TaskRead)
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    return _family_task_or_404(db, member, task_id)


@router.post("/{task_id}/submit", response_model=SubmissionRead, status_code=201)
def submit_task(
    task_id: int,
    note: str | None = Form(default=None),
    photo: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    member: User = Depends(get_current_user),
):
    task = _family_task_or_404(db, member, task_id)
    if task.requires_photo and photo is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This task requires a photo.",
        )
    photo_path = None
    if photo is not None:
        ext = Path(photo.filename or "").suffix.lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported file type: {ext or 'unknown'}.",
            )
        uploads = Path(settings.uploads_dir)
        uploads.mkdir(parents=True, exist_ok=True)
        filename = f"task_{task.id}_{uuid.uuid4().hex}{ext}"
        data = photo.file.read()
        (uploads / filename).write_bytes(data)
        photo_path = filename
    submission = TaskSubmission(
        task_id=task.id,
        submitted_by_user_id=member.id,
        status="pending",
        photo_path=photo_path,
        note=note,
    )
    task.status = "pending_review"
    notify_parents(
        db,
        db.get(Family, task.family_id),
        exclude_user_id=member.id,
        kind="review_needed",
        title=f"{member.display_name} submitted '{task.title}' for review.",
        ref_type="task",
        ref_id=task.id,
    )
    db.add(submission)
    db.commit()
    db.refresh(submission)
    return submission


def _format_review_time(reviewed_at) -> str | None:
    """12-hour wall time (`6:42 PM UTC`) for a review timestamp."""
    if reviewed_at is None:
        return None
    hour = reviewed_at.hour % 12 or 12
    meridiem = "PM" if reviewed_at.hour >= 12 else "AM"
    return f"{hour}:{reviewed_at.minute:02d} {meridiem} UTC"


def _raise_not_pending(db: Session, task: Task) -> None:
    """409 naming the approver when already approved, else the legacy 404."""
    approved = (
        db.query(TaskSubmission)
        .filter(
            TaskSubmission.task_id == task.id,
            TaskSubmission.status == "approved",
        )
        .order_by(TaskSubmission.id.desc())
        .first()
    )
    if approved is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No pending submission for this task.",
        )
    name = "another parent"
    if approved.reviewed_by_user_id is not None:
        reviewer = db.get(User, approved.reviewed_by_user_id)
        if reviewer is not None:
            name = reviewer.display_name
    when = _format_review_time(approved.reviewed_at)
    detail = (
        f"Already approved by {name} at {when}."
        if when is not None
        else f"Already approved by {name}."
    )
    raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detail)


def _advance_streak(
    db: Session, earner: User, now: datetime, submission_id: int
) -> None:
    """Extend the earner's UTC-day streak, minting milestone bonuses.

    Same-day repeats hold the count; a gap day resets to 1 (losing the
    run is the only consequence — never a penalty); every 5th day
    mints STREAK_BONUS_POINTS through the ledger.
    """
    day = now.date()
    last = earner.streak_last_day
    if last is not None and day <= last:
        return
    count = earner.streak_count + 1 if last == day - timedelta(days=1) else 1
    earner.streak_count = count
    earner.streak_last_day = day
    if count % 5 == 0:
        apply_points(
            db,
            earner,
            settings.streak_bonus_points,
            "streak_bonus",
            ref_type="submission",
            ref_id=submission_id,
        )


def _spawn_next_instance(db: Session, task: Task, now: datetime) -> None:
    """Create the next open instance of a repeating chore.

    Due just after the approved instance (its due date, else now); an
    unparseable rule skips the spawn instead of failing the approval.
    """
    anchor = task.due_date if task.due_date is not None else now
    try:
        due = next_repeat_date(task.repeat_rule or "", anchor)
    except ValueError:
        return
    db.add(
        Task(
            family_id=task.family_id,
            title=task.title,
            description=task.description,
            task_type=task.task_type,
            points_reward=task.points_reward,
            requires_photo=task.requires_photo,
            assigned_to_user_id=task.assigned_to_user_id,
            created_by_user_id=task.created_by_user_id,
            status="open",
            due_date=due,
            repeat_rule=task.repeat_rule,
        )
    )


@router.put("/{task_id}/approve", response_model=SubmissionRead)
def review_task(
    task_id: int,
    payload: ReviewRequest,
    db: Session = Depends(get_db),
    parent: User = Depends(require_parent),
):
    task = _family_task_or_404(db, parent, task_id)
    submission = (
        db.query(TaskSubmission)
        .filter(
            TaskSubmission.task_id == task.id,
            TaskSubmission.status == "pending",
        )
        .order_by(TaskSubmission.id.desc())
        .first()
    )
    if submission is None:
        _raise_not_pending(db, task)
    now = datetime.now(timezone.utc)
    approved = payload.action != "request_changes"
    target = "approved" if approved else "changes_requested"
    claim = {
        "status": target,
        "reviewed_by_user_id": parent.id,
        "reviewed_at": now,
    }
    if not approved and payload.note:
        claim["note"] = payload.note
    if approved and submission.photo_path:
        claim["expires_at"] = now + timedelta(days=settings.photo_retention_days)
    claimed = (
        db.query(TaskSubmission)
        .filter(
            TaskSubmission.id == submission.id,
            TaskSubmission.status == "pending",
        )
        .update(claim, synchronize_session="fetch")
    )
    if not claimed:
        # Lost a concurrent review: report the state that won.
        db.rollback()
        _raise_not_pending(db, task)
    if approved:
        earner = db.get(User, submission.submitted_by_user_id)
        if earner is not None and task.points_reward:
            apply_points(
                db,
                earner,
                task.points_reward,
                "task_approved",
                ref_type="submission",
                ref_id=submission.id,
            )
        notify_parents(
            db,
            db.get(Family, task.family_id),
            exclude_user_id=parent.id,
            kind="approved",
            title=f"{parent.display_name} approved '{task.title}'.",
            ref_type="task",
            ref_id=task.id,
        )
        if earner is not None:
            _advance_streak(db, earner, now, submission.id)
        if task.repeat_rule:
            _spawn_next_instance(db, task, now)
        task.status = "approved"
    else:
        task.status = "open"
    db.commit()
    db.refresh(submission)
    return submission


@router.get("/{task_id}/submissions", response_model=list[SubmissionRead])
def list_submissions(
    task_id: int,
    db: Session = Depends(get_db),
    member: User = Depends(require_family_member),
):
    _family_task_or_404(db, member, task_id)
    return (
        db.query(TaskSubmission)
        .filter(TaskSubmission.task_id == task_id)
        .order_by(TaskSubmission.id)
        .all()
    )
