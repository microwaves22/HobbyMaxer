"""Data retention: auto-delete expired approved submission photos.

Runs on app startup (see main.py lifespan). Only deletes files that resolve
inside the uploads directory; always clears the DB reference so a missing
file can never block the sweep.
"""

from datetime import datetime, timezone
from pathlib import Path

from sqlalchemy.orm import Session

from ..models import TaskSubmission


def delete_expired_photos(db: Session, uploads_dir: str) -> dict:
    now = datetime.now(timezone.utc)
    expired = (
        db.query(TaskSubmission)
        .filter(
            TaskSubmission.status == "approved",
            TaskSubmission.expires_at.isnot(None),
            TaskSubmission.expires_at <= now,
            TaskSubmission.photo_path.isnot(None),
        )
        .all()
    )
    base = Path(uploads_dir).resolve()
    deleted_files = 0
    for sub in expired:
        assert sub.photo_path is not None
        try:
            candidate = (base / Path(sub.photo_path).name).resolve()
            if candidate.is_relative_to(base) and candidate.is_file():
                candidate.unlink()
                deleted_files += 1
        except OSError:
            pass
        sub.photo_path = None
    db.commit()
    return {"expired_submissions": len(expired), "deleted_files": deleted_files}
