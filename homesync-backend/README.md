# HomeSync Backend

Family organization API: chores, homework, points, rewards, and a shared calendar.

- Framework: FastAPI + SQLAlchemy 2.0 + SQLite
- Auth: parent email/password + JWT, child profiles via parent-PIN switching
- Evidence: multipart photo uploads stored in `uploads/` (private, git-ignored)

## Quickstart

Requires Python 3.10+.

### Docker (recommended)

```powershell
cd homesync-backend
copy .env.example .env
docker compose up --build
```

- API docs: http://127.0.0.1:8000/docs
- SQLite data persists in the `sqlite-data` volume; photos in `./uploads`.

### Local

```powershell
cd homesync-backend
uv venv
uv pip install -r requirements.txt
copy .env.example .env
uv run uvicorn app.main:app --reload
```

## Layout

```text
homesync-backend/
  app/
    core/        # config.py, database.py, security.py
    models/      # family, user, task, submission, reward (+ledger), event
    schemas/     # Pydantic request/response models
    routers/     # auth, families, tasks, rewards, calendar
    services/    # points_service (ledger), cleanup_service (retention)
    main.py      # app init, CORS, router wiring
  uploads/       # private chore-evidence files (30-day retention on approval)
  Dockerfile
  docker-compose.yml
```

## Endpoint summary

| Method + path | Who | Notes |
| --- | --- | --- |
| `POST /auth/register` | parent | `{email, password, display_name}` -> JWT + user |
| `POST /auth/login` | parent | OAuth2 form (`username`=email) -> JWT |
| `POST /auth/switch-profile` | device | `{user_id, pin}` (parent PIN) -> JWT for that profile |
| `GET /auth/me` | any | Current profile |
| `POST /families/` | parent | `{name, parent_pin}`; attaches caller |
| `GET /families/me` | parent | Family + members |
| `POST /families/{id}/children` | parent | `{display_name, mode: kids\|teen}` |
| `PATCH /families/{id}/children/{child_id}/mode` | parent | Kids/Teen toggle |
| `POST /tasks/` | parent | `{title, task_type, points_reward, requires_photo?, ...}` |
| `GET /tasks/` | member | Children see own/unassigned tasks |
| `POST /tasks/{id}/submit` | member | `multipart/form-data`: `photo` file + `note` |
| `PUT /tasks/{id}/approve` | parent | `{action: approve\|request_changes}`; approval mints points + ledger row, sets 30-day photo expiry |
| `GET /tasks/{id}/submissions` | member | Submission history |
| `POST /rewards/` | parent | `{name, cost_points, kind: avatar\|pet\|perk}` |
| `GET /rewards/` | member | Family catalog |
| `POST /rewards/{id}/redeem` | member | Spends points, writes ledger row |
| `GET /rewards/ledger/me` | member | Own point audit trail |
| `POST /calendar/events` | member | `{title, starts_at, ends_at?}` |
| `GET /calendar/events` | member | Family events |

## Key behaviors

- **Points ledger**: every earn/spend updates `points_balance` and inserts a
  `PointTransaction` in one commit (`reason`, `balance_after`, refs included).
- **Photo retention**: approving a submission sets `expires_at` = now + 30 days
  (`PHOTO_RETENTION_DAYS`); expired files are deleted on startup by
  `cleanup_service` and the DB reference is cleared.
- **Uploads**: files are stored under a UUID name (`task_<id>_<uuid>.<ext>`);
  only image extensions are accepted.
- **Shared devices**: kids never need passwords — `POST /auth/switch-profile`
  with the parent PIN issues a token for the child's profile.
