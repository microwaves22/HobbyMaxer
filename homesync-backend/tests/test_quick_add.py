"""Meta AI quick-add: natural language to draft events and tasks.

Run from homesync-backend/::

    pip install -r requirements-dev.txt
    pytest
"""

from datetime import datetime

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.main import app


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
            yield test_client
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


def _family(client):
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = client.post(
        "/families/",
        json={"name": "The Fam", "parent_pin": "4321"},
        headers=_headers(mom_token),
    ).json()
    noah = client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Noah", "mode": "teen"},
        headers=_headers(mom_token),
    ).json()
    ava = client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Ava", "mode": "kids"},
        headers=_headers(mom_token),
    ).json()
    return mom_token, noah, ava


def _quick_add(client, token, text):
    return client.post(
        "/ai/quick-add", json={"text": text}, headers=_headers(token)
    )


def test_example_parses_event_and_task(backend):
    mom_token, noah, ava = _family(backend)

    resp = _quick_add(
        backend,
        mom_token,
        "Noah has soccer Thursday 5–6, and Ava needs to empty "
        "the dishwasher daily for 10 pts",
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["events"]) == 1
    assert len(body["tasks"]) == 1

    event = body["events"][0]
    assert "soccer" in event["title"].lower()
    starts = datetime.fromisoformat(event["starts_at"])
    ends = datetime.fromisoformat(event["ends_at"])
    assert starts.weekday() == 3  # Thursday
    assert (starts.hour, starts.minute) == (17, 0)
    assert (ends.hour, ends.minute) == (18, 0)
    assert event["attendee_names"] == ["Noah"]

    task = body["tasks"][0]
    assert "dishwasher" in task["title"].lower()
    assert task["assigned_to_user_id"] == ava["id"]
    assert task["points_reward"] == 10
    assert task["repeat_rule"] == "daily"


def test_homework_task_with_points_and_day(backend):
    mom_token, noah, _ = _family(backend)

    resp = _quick_add(
        backend, mom_token, "Noah needs to finish math homework Friday for 15"
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["events"] == []
    assert len(body["tasks"]) == 1
    task = body["tasks"][0]
    assert task["task_type"] == "homework"
    assert task["points_reward"] == 15
    assert task["assigned_to_user_id"] == noah["id"]
    due = datetime.fromisoformat(task["due_date"])
    assert due.weekday() == 4  # Friday


def test_unknown_person_warns_and_leaves_unassigned(backend):
    mom_token, _, _ = _family(backend)

    resp = _quick_add(backend, mom_token, "Zed needs to mow the lawn")

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["tasks"]) == 1
    assert body["tasks"][0]["assigned_to_user_id"] is None
    assert any("Zed" in warning for warning in body["warnings"])


def test_gibberish_returns_empty_with_warning(backend):
    mom_token, _, _ = _family(backend)

    resp = _quick_add(backend, mom_token, "asdf qwer zxcv")

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["events"] == []
    assert body["tasks"] == []
    assert len(body["warnings"]) >= 1


def test_quick_add_requires_family_parent(backend):
    mom_token, _, _ = _family(backend)
    child = backend.post(
        "/families/1/children",
        json={"display_name": "Kid", "mode": "kids"},
        headers=_headers(mom_token),
    ).json()
    switch = backend.post(
        "/auth/switch-profile", json={"user_id": child["id"]}
    )
    kid_token = switch.json()["access_token"]
    resp = _quick_add(backend, kid_token, "Mow the lawn")
    assert resp.status_code == 403

    stranger_token, _ = _register(backend, "zed@example.com", "Zed")
    resp = _quick_add(backend, stranger_token, "Mow the lawn")
    assert resp.status_code == 404

    resp = _quick_add(backend, mom_token, "")
    assert resp.status_code == 422


def test_drafts_save_nothing(backend):
    mom_token, _, _ = _family(backend)

    _quick_add(backend, mom_token, "Ava needs to empty the dishwasher")

    assert backend.get("/tasks/", headers=_headers(mom_token)).json() == []
    assert (
        backend.get("/calendar/events", headers=_headers(mom_token)).json()
        == []
    )
