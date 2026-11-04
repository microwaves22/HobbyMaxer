"""SQLAlchemy 2.0 engine, session factory, and declarative base."""

from collections.abc import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from .config import settings


class Base(DeclarativeBase):
    pass


connect_args = {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}
engine = create_engine(settings.database_url, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def ensure_schema() -> None:
    """Idempotent SQLite-only migration for pre-existing databases.

    `Base.metadata.create_all` creates tables but never adds columns, so
    databases created before `families.invite_code` existed are patched
    here (fresh databases already have the column and are untouched).
    """
    if not settings.database_url.startswith("sqlite"):
        return
    with engine.begin() as conn:
        cols = [row[1] for row in conn.execute(text("PRAGMA table_info(families)")).all()]
        if "invite_code" not in cols:
            conn.execute(text("ALTER TABLE families ADD COLUMN invite_code VARCHAR(6)"))
            conn.execute(
                text("CREATE UNIQUE INDEX IF NOT EXISTS ix_families_invite_code "
                "ON families (invite_code)")
            )
        if "notification_prefs" not in cols:
            conn.execute(
                text("ALTER TABLE families ADD COLUMN notification_prefs JSON")
            )
        task_cols = [
            row[1]
            for row in conn.execute(text("PRAGMA table_info(tasks)")).all()
        ]
        if "repeat_rule" not in task_cols:
            conn.execute(
                text("ALTER TABLE tasks ADD COLUMN repeat_rule VARCHAR(32)")
            )
        user_cols = [
            row[1]
            for row in conn.execute(text("PRAGMA table_info(users)")).all()
        ]
        if "streak_count" not in user_cols:
            conn.execute(
                text("ALTER TABLE users ADD COLUMN streak_count INTEGER DEFAULT 0")
            )
        if "streak_last_day" not in user_cols:
            conn.execute(text("ALTER TABLE users ADD COLUMN streak_last_day DATE")
            )
        if "child_pin_hashed" not in user_cols:
            conn.execute(
                text("ALTER TABLE users ADD COLUMN child_pin_hashed VARCHAR(255)")
            )
    # Backfill codes for rows predating the column (imported lazily to
    # avoid a core -> models dependency at import time).
    from ..models import Family
    from ..models.family import new_invite_code

    db = SessionLocal()
    try:
        missing = db.query(Family).filter(Family.invite_code.is_(None)).all()
        for family in missing:
            family.invite_code = new_invite_code()
        if missing:
            db.commit()
    finally:
        db.close()
