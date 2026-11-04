"""Load balance: per-parent workload shares over the trailing 7 days.

Run from homesync-backend/::

    pip install -r requirements-dev.txt
    pytest
"""

from datetime import datetime, timedelta, timezone

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.main import app
from app.models import Task


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


def _create_family(client, token, pin="4321"):
    resp = client.post(
        "/families/",
        json={"name": "The Fam", "parent_pin": pin},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _add_child(client, token, family_id, name="Kid"):
    resp = client.post(
        f"/families/{family_id}/children",
        json={"display_name": name, "mode": "kids"},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _child_token(client, child_id, pin="4321"):
    resp = client.post(
        "/auth/switch-profile", json={"user_id": child_id, "pin": pin}
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["access_token"]


def _create_task(client, token, title, assignee_id):
    resp = client.post(
        "/tasks/",
        json={"title": title, "assigned_to_user_id": assignee_id},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _submit(client, token, task_id):
    resp = client.post(
        f"/tasks/{task_id}/submit",
        data={"note": "done"},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _approve(client, token, task_id):
    resp = client.put(
        f"/tasks/{task_id}/approve",
        json={"action": "approve"},
        headers=_headers(token),
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def _add_event(client, token, title):
    resp = client.post(
        "/calendar/events",
        json={"title": title, "starts_at": "2026-12-01T10:00:00Z"},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def test_load_balance_splits_two_parents(backend):
    client, _ = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    dad_token, _ = _register(client, "dad@example.com", "Dad")
    joined = client.post(
        "/families/join",
        json={"code": family["invite_code"]},
        headers=_headers(dad_token),
    )
    assert joined.status_code == 200, joined.text
    child = _add_child(client, mom_token, family["id"], "Maya")
    kid_token = _child_token(client, child["id"])

    # Mom: 2 created + 2 approvals + 2 events = 6.
    # Dad: 1 created + 1 approval + 1 event = 3.
    tasks = [
        _create_task(client, mom_token, "t1", child["id"]),
        _create_task(client, mom_token, "t2", child["id"]),
        _create_task(client, dad_token, "t3", child["id"]),
    ]
    for task in tasks:
        _submit(client, kid_token, task["id"])
    _approve(client, mom_token, tasks[0]["id"])
    _approve(client, mom_token, tasks[1]["id"])
    _approve(client, dad_token, tasks[2]["id"])
    _add_event(client, mom_token, "e1")
    _add_event(client, mom_token, "e2")
    _add_event(client, dad_token, "e3")

    resp = client.get("/families/load-balance", headers=_headers(mom_token))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["window_days"] == 7
    assert body["total"] == 9
    shares = {s["display_name"]: s for s in body["shares"]}
    assert set(shares) == {"Mom", "Dad"}
    assert shares["Mom"]["tasks_created"] == 2
    assert shares["Mom"]["approvals"] == 2
    assert shares["Mom"]["events_added"] == 2
    assert shares["Mom"]["score"] == 6
    assert shares["Mom"]["percent"] == 67
    assert shares["Dad"]["score"] == 3
    assert shares["Dad"]["percent"] == 33


def test_load_balance_ignores_stale_activity(backend):
    client, testing_session = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    child = _add_child(client, mom_token, family["id"], "Maya")
    task = _create_task(client, mom_token, "old", child["id"])

    db = testing_session()
    try:
        row = db.query(Task).filter_by(id=task["id"]).one()
        row.created_at = datetime.now(timezone.utc) - timedelta(days=8)
        db.commit()
    finally:
        db.close()

    resp = client.get("/families/load-balance", headers=_headers(mom_token))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["total"] == 0
    assert body["shares"][0]["percent"] == 0


def test_load_balance_requires_family_parent(backend):
    client, _ = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")

    resp = client.get("/families/load-balance", headers=_headers(mom_token))
    assert resp.status_code == 404

    family = _create_family(client, mom_token)
    child = _add_child(client, mom_token, family["id"], "Maya")
    kid_token = _child_token(client, child["id"])
    resp = client.get("/families/load-balance", headers=_headers(kid_token))
    assert resp.status_code == 403
