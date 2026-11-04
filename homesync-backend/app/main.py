"""HomeSync FastAPI application entrypoint.

Local run (from homesync-backend/):  uvicorn app.main:app --reload
Docker run:                          docker compose up --build
"""

import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models  # noqa: F401 - register tables
from .core.config import settings
from .core.database import Base, SessionLocal, engine, ensure_schema
from .routers import ai, auth, calendar, families, notifications, rewards, tasks
from .services.cleanup_service import delete_expired_photos

logger = logging.getLogger("homesync")


@asynccontextmanager
async def lifespan(app: FastAPI):
    os.makedirs(settings.uploads_dir, exist_ok=True)
    Base.metadata.create_all(bind=engine)
    ensure_schema()
    try:
        db = SessionLocal()
        try:
            stats = delete_expired_photos(db, settings.uploads_dir)
            logger.info("Photo retention sweep: %s", stats)
        finally:
            db.close()
    except Exception:
        logger.exception("Photo retention sweep failed; continuing startup.")
    yield


app = FastAPI(title="HomeSync", version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai.router)
app.include_router(auth.router)
app.include_router(families.router)
app.include_router(notifications.router)
app.include_router(tasks.router)
app.include_router(rewards.router)
app.include_router(calendar.router)


@app.get("/", tags=["meta"])
def root():
    return {"name": "HomeSync", "version": "0.1.0", "docs": "/docs"}


@app.get("/health", tags=["meta"])
def health():
    return {"status": "ok"}
