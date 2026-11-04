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
| `POST /auth/switch-profile` | device | `{user_id, pin?}` -> JWT (parent targets need parent PIN; child targets need child PIN or none) |
| `POST /auth/child-login` | child | `{user_id, child_pin?}` -> JWT for that child profile |
| `GET /auth/me` | any | Current profile |
| `POST /families/` | parent | `{name, parent_pin}`; attaches caller |
| `POST /families/join` | any | `{code}` invite code -> join that family (family code keeps role; co-parent invite grants parent) |
| `POST /families/{id}/invites` | parent | Mint a single-use co-parent code (expires after `CO_PARENT_INVITE_HOURS`, default 48) |
| `GET /families/load-balance` | parent | Per-parent workload shares, trailing 7 days (tasks + approvals + events) |
| `GET /families/me/preferences` | parent | Notification preferences (per-type toggles) |
| `PUT /families/me/preferences` | parent | Merge notification preferences |
| `GET /notifications` | member | Own inbox, newest first (`?unread_only=true`, `?limit=`) |
| `PUT /notifications/{id}/read` | member | Mark one notification read |
| `POST /notifications/read-all` | member | Mark all own notifications read |
| `POST /ai/quick-add` | parent | `{text}` (typed or voice transcript) -> draft events/tasks + warnings (nothing saved; strict validation; Muse when `META_AI_API_KEY` is set, offline parser otherwise) |
| `GET /families/me` | parent | Family + members |
| `POST /families/{id}/children` | parent | `{display_name, mode: kids\|teen}` |
| `PATCH /families/{id}/children/{child_id}/mode` | parent | Kids/Teen toggle |
| `PATCH /families/{id}/children/{child_id}/pin` | parent | Set/clear (`null`) the child's login PIN |
| `POST /tasks/` | parent | `{title, task_type, points_reward, requires_photo?, ...}` |
| `GET /tasks/` | member | Children see own/unassigned tasks |
| `POST /tasks/{id}/submit` | member | `multipart/form-data`: `photo` file + `note` |
| `PUT /tasks/{id}/approve` | parent | `{action: approve\|request_changes}`; approval mints points + ledger row, sets 30-day photo expiry, advances streaks, spawns the next repeat; re-review returns 409 naming the approver |
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
- **Repeats & streaks**: tasks take `repeat_rule` (`daily`, `weekly`,
  or weekdays like `mon,wed,fri`); approval spawns the next open
  instance. Each approval extends the earner's UTC-day streak (gaps
  reset to zero, never a penalty); every 5th day mints
  `STREAK_BONUS_POINTS` (default 10) with a `streak_bonus` ledger row.
- **Shared devices**: kids log in directly via `POST /auth/child-login`
  with their own optional PIN (set by a parent); `POST
  /auth/switch-profile` to a child needs that PIN or nothing, never the
  parent PIN.
- **Co-parent invites**: a parent mints a single-use code that expires
  after `CO_PARENT_INVITE_HOURS` (default 48); the second parent
  registers/logs in and redeems it via `POST /families/join`, which
  attaches them with the parent role. Unknown, expired, and consumed
  codes all return 404.

## Tests

```powershell
cd homesync-backend
pip install -r requirements-dev.txt
pytest
```
