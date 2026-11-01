"""Environment-driven settings (no extra dependencies)."""

import os
from dataclasses import dataclass, field

from dotenv import load_dotenv

load_dotenv()


def _get_int(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except ValueError:
        return default


@dataclass(frozen=True)
class Settings:
    database_url: str = field(
        default_factory=lambda: os.getenv("DATABASE_URL", "sqlite:///./homesync.db")
    )
    secret_key: str = field(
        default_factory=lambda: os.getenv("SECRET_KEY", "dev-only-secret-change-me")
    )
    access_token_expire_minutes: int = field(
        default_factory=lambda: _get_int("ACCESS_TOKEN_EXPIRE_MINUTES", 1440)
    )
    uploads_dir: str = field(
        default_factory=lambda: os.getenv("UPLOADS_DIR", "uploads")
    )
    photo_retention_days: int = field(
        default_factory=lambda: _get_int("PHOTO_RETENTION_DAYS", 30)
    )


settings = Settings()
