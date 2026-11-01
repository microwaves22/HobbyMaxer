# AGENTS.md

Muse Code reads this file as project rules when it runs in this directory.

## Project

- Name: HomeSync
- Backend: `homesync-backend/` (FastAPI + SQLAlchemy 2.0 + SQLite)

## Common Commands

- Docker: `cd homesync-backend && docker compose up --build`
- Local setup: `cd homesync-backend && uv venv && uv pip install -r requirements.txt`
- Local run: `cd homesync-backend && uv run uvicorn app.main:app --reload`
- Docs: http://127.0.0.1:8000/docs once running

## Project Layout

- `homesync-backend/app/core/`: config, database, security.
- `homesync-backend/app/models/`: family, user, task, submission, reward (+ledger), event.
- `homesync-backend/app/schemas/`: Pydantic request/response models.
- `homesync-backend/app/routers/`: auth, families, tasks, rewards, calendar.
- `homesync-backend/app/services/`: points ledger, photo-retention cleanup.
- `homesync-backend/uploads/`: private chore-evidence files (git-ignored).
