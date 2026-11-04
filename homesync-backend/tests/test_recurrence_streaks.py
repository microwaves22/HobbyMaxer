"""Recurring chores and positive-reinforcement streaks.

Run from homesync-backend/::

    pip install -r requirements-dev.txt
    pytest
"""

from datetime import date, datetime, timedelta, timezone


def _utc_today():
    return datetime.now(timezone.utc).date()

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.main import app
from app.models import PointTransaction, User


@pytest.fixture()
def backend(tmp_path, monkeypatch):
    """App client on an isolated in-memory database."""
    monkeypatch.chdir(tmp_path)
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    testing_session = sessionmaker(
        autocommit=False, autoflush=False, bind=engine
    )
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = testing_session()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    try:
        with TestClient(app) as test_client:
            yield test_client, testing_session
    finally:
        app.dependency_overrides.clear()


def _register(client, email, display_name="Parent"):
    resp = client.post(
        "/auth/register",
        json={
            "email": email,
            "password": "secret123",
            "display_name": display_name,
        },
    )
    assert resp.status_code == 201, resp.text
    body = resp.json()
    return body["access_token"], body["user"]


def _headers(token):
    return {"Authorization": f"Bearer {token}"}


def _setup(client):
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = client.post(
        "/families/",
        json={"name": "The Fam", "parent_pin": "4321"},
        headers=_headers(mom_token),
    ).json()
    child = client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Maya", "mode": "kids"},
        headers=_headers(mom_token),
    ).json()
    switch = client.post(
        "/auth/switch-profile",
        json={"user_id": child["id"], "pin": "4321"},
    )
    return mom_token, switch.json()["access_token"], child["id"]


def _create_task(client, token, assignee_id, **overrides):
    payload = {"title": "Trash", "assigned_to_user_id": assignee_id}
    payload.update(overrides)
    resp = client.post("/tasks/", json=payload, headers=_headers(token))
    return resp


def _submit_and_approve(client, kid_token, mom_token, task_id):
    sub = client.post(
        f"/tasks/{task_id}/submit",
        data={"note": "done"},
        headers=_headers(kid_token),
    )
    assert sub.status_code == 201, sub.text
    review = client.put(
        f"/tasks/{task_id}/approve",
        json={"action": "approve"},
        headers=_headers(mom_token),
    )
    assert review.status_code == 200, review.text
    return review.json()


def _balance(client, mom_token, name="Maya"):
    roster = client.get("/families/me", headers=_headers(mom_token)).json()
    return next(
        m["points_balance"] for m in roster["members"] if m["display_name"] == name
    )


def test_daily_repeat_spawns_next_instance(backend):
    client, _ = backend
    mom_token, kid_token, kid_id = _setup(client)
    created = _create_task(
        client,
        mom_token,
        kid_id,
        points_reward=10,
        due_date="2026-11-04T18:00:00Z",
        repeat_rule="daily",
    )
    assert created.status_code == 201, created.text
    task = created.json()
    assert task["repeat_rule"] == "daily"

    _submit_and_approve(client, kid_token, mom_token, task["id"])

    tasks = client.get("/tasks/", headers=_headers(mom_token)).json()
    by_status = {t["status"] for t in tasks}
    assert by_status == {"approved", "open"}
    spawned = next(t for t in tasks if t["status"] == "open")
    assert spawned["repeat_rule"] == "daily"
    assert spawned["assigned_to_user_id"] == kid_id
    assert spawned["points_reward"] == 10
    assert spawned["due_date"].startswith("2026-11-05T18:00")


def test_weekly_and_weekday_repeats(backend):
    client, _ = backend
    mom_token, kid_token, kid_id = _setup(client)

    weekly = _create_task(
        client,
        mom_token,
        kid_id,
        due_date="2026-11-04T09:00:00Z",  # a Wednesday
        repeat_rule="weekly",
    )
    assert weekly.status_code == 201, weekly.text
    _submit_and_approve(client, kid_token, mom_token, weekly.json()["id"])

    weekdays = _create_task(
        client,
        mom_token,
        kid_id,
        due_date="2026-11-04T09:00:00Z",  # Wednesday -> next Mon
        repeat_rule="mon,wed",
    )
    assert weekdays.json()["repeat_rule"] == "mon,wed"
    _submit_and_approve(client, kid_token, mom_token, weekdays.json()["id"])

    tasks = client.get("/tasks/", headers=_headers(mom_token)).json()
    spawned = sorted(
        [t for t in tasks if t["status"] == "open"],
        key=lambda t: t["due_date"],
    )
    assert spawned[0]["due_date"].startswith("2026-11-09T09:00")
    assert spawned[1]["due_date"].startswith("2026-11-11T09:00")


def test_invalid_repeat_rule_rejected(backend):
    client, _ = backend
    mom_token, _, kid_id = _setup(client)

    resp = _create_task(client, mom_token, kid_id, repeat_rule="sometimes")
    assert resp.status_code == 422

    resp = _create_task(client, mom_token, kid_id, repeat_rule="mon,funday")
    assert resp.status_code == 422


def test_one_shot_and_request_changes_spawn_nothing(backend):
    client, _ = backend
    mom_token, kid_token, kid_id = _setup(client)
    task = _create_task(client, mom_token, kid_id, repeat_rule="daily").json()
    sub = client.post(
        f"/tasks/{task['id']}/submit",
        data={"note": "done"},
        headers=_headers(kid_token),
    )
    assert sub.status_code == 201
    resp = client.put(
        f"/tasks/{task['id']}/approve",
        json={"action": "request_changes", "note": "redo"},
        headers=_headers(mom_token),
    )
    assert resp.status_code == 200, resp.text

    tasks = client.get("/tasks/", headers=_headers(mom_token)).json()
    assert len(tasks) == 1

    plain = _create_task(client, mom_token, kid_id).json()
    _submit_and_approve(client, kid_token, mom_token, plain["id"])
    tasks = client.get("/tasks/", headers=_headers(mom_token)).json()
    assert len(tasks) == 2


def _set_streak(testing_session, user_id, count, last_day):
    db = testing_session()
    try:
        user = db.get(User, user_id)
        user.streak_count = count
        user.streak_last_day = last_day
        db.commit()
    finally:
        db.close()


def _streak(testing_session, user_id):
    db = testing_session()
    try:
        user = db.get(User, user_id)
        return user.streak_count, user.streak_last_day
    finally:
        db.close()


def test_fifth_day_awards_streak_bonus(backend):
    client, testing_session = backend
    mom_token, kid_token, kid_id = _setup(client)
    _set_streak(testing_session, kid_id, 4, _utc_today() - timedelta(days=1))

    task = _create_task(client, mom_token, kid_id, points_reward=10).json()
    _submit_and_approve(client, kid_token, mom_token, task["id"])

    count, last_day = _streak(testing_session, kid_id)
    assert count == 5
    assert last_day == _utc_today()
    assert _balance(client, mom_token) == 20

    db = testing_session()
    try:
        bonus = (
            db.query(PointTransaction)
            .filter(
                PointTransaction.user_id == kid_id,
                PointTransaction.reason == "streak_bonus",
            )
            .one()
        )
        assert bonus.amount == 10
    finally:
        db.close()


def test_gap_resets_streak_without_bonus(backend):
    client, testing_session = backend
    mom_token, kid_token, kid_id = _setup(client)
    _set_streak(testing_session, kid_id, 4, _utc_today() - timedelta(days=3))

    task = _create_task(client, mom_token, kid_id, points_reward=10).json()
    _submit_and_approve(client, kid_token, mom_token, task["id"])

    count, _ = _streak(testing_session, kid_id)
    assert count == 1
    assert _balance(client, mom_token) == 10


def test_same_day_approvals_keep_streak(backend):
    client, testing_session = backend
    mom_token, kid_token, kid_id = _setup(client)
    _set_streak(testing_session, kid_id, 4, _utc_today() - timedelta(days=1))

    first = _create_task(client, mom_token, kid_id, points_reward=10).json()
    _submit_and_approve(client, kid_token, mom_token, first["id"])
    second = _create_task(client, mom_token, kid_id, points_reward=10).json()
    _submit_and_approve(client, kid_token, mom_token, second["id"])

    count, _ = _streak(testing_session, kid_id)
    assert count == 5
    # Two rewards plus a single streak bonus.
    assert _balance(client, mom_token) == 30


def test_sixth_day_earns_no_bonus(backend):
    client, testing_session = backend
    mom_token, kid_token, kid_id = _setup(client)
    _set_streak(testing_session, kid_id, 5, _utc_today() - timedelta(days=1))

    task = _create_task(client, mom_token, kid_id, points_reward=10).json()
    _submit_and_approve(client, kid_token, mom_token, task["id"])

    count, _ = _streak(testing_session, kid_id)
    assert count == 6
    assert _balance(client, mom_token) == 10
