"""Tasks: parent creation, child photo submissions, parent review."""

import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..core.security import get_current_user, require_family_member, require_parent
from ..models import Task, TaskSubmission, User
from ..schemas.tasks import ReviewRequest, SubmissionRead, TaskCreate, TaskRead
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
    db.add(submission)
    db.commit()
    db.refresh(submission)
    return submission


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
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No pending submission for this task.",
        )
    now = datetime.now(timezone.utc)
    if payload.action == "request_changes":
        submission.status = "changes_requested"
        submission.note = payload.note or submission.note
        submission.reviewed_by_user_id = parent.id
        submission.reviewed_at = now
        task.status = "open"
    else:
        submission.status = "approved"
        submission.reviewed_by_user_id = parent.id
        submission.reviewed_at = now
        if submission.photo_path:
            submission.expires_at = now + timedelta(
                days=settings.photo_retention_days
            )
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
        task.status = "approved"
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
