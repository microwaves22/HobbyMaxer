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
    streak_bonus_points: int = field(
        default_factory=lambda: _get_int("STREAK_BONUS_POINTS", 10)
    )
    co_parent_invite_hours: int = field(
        default_factory=lambda: _get_int("CO_PARENT_INVITE_HOURS", 48)
    )
    meta_ai_api_key: str | None = field(
        default_factory=lambda: os.getenv("META_AI_API_KEY") or None
    )
    meta_ai_api_url: str = field(
        default_factory=lambda: os.getenv(
            "META_AI_API_URL", "https://api.llama.com/v1/chat/completions"
        )
    )
    meta_ai_model: str = field(
        default_factory=lambda: os.getenv(
            "META_AI_MODEL", "Llama-4-Maverick-17B-128E-Instruct-FP8"
        )
    )
    photo_retention_days: int = field(
        default_factory=lambda: _get_int("PHOTO_RETENTION_DAYS", 30)
    )


settings = Settings()
