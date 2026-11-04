"""In-app notifications: triggers, preferences, and read flows.

Run from homesync-backend/::

    pip install -r requirements-dev.txt
    pytest
"""

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


def _notifications(client, token, unread_only=False):
    path = "/notifications" + ("?unread_only=true" if unread_only else "")
    resp = client.get(path, headers=_headers(token))
    assert resp.status_code == 200, resp.text
    return resp.json()


def _two_parent_family(client):
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    dad_token, _ = _register(client, "dad@example.com", "Dad")
    joined = client.post(
        "/families/join",
        json={"code": family["invite_code"]},
        headers=_headers(dad_token),
    )
    assert joined.status_code == 200, joined.text
    # Clear the join notification so each test starts clean.
    client.post("/notifications/read-all", headers=_headers(mom_token))
    return mom_token, dad_token, family


def test_review_needed_notifies_other_parent(backend):
    mom_token, dad_token, family = _two_parent_family(backend)
    child = _add_child(backend, mom_token, family["id"], "Maya")
    kid_token = _child_token(backend, child["id"])
    task = _create_task(backend, mom_token, "Trash", child["id"])
    _submit(backend, kid_token, task["id"])

    dad_notes = _notifications(backend, dad_token, unread_only=True)

    assert len(dad_notes) == 1
    assert dad_notes[0]["type"] == "review_needed"
    assert "Trash" in dad_notes[0]["title"]
    assert dad_notes[0]["is_read"] is False
    # Both co-parents are notified; only the actor (the kid) is excluded.
    mom_notes = _notifications(backend, mom_token, unread_only=True)
    assert len(mom_notes) == 1
    assert mom_notes[0]["type"] == "review_needed"


def test_approved_notifies_other_parent(backend):
    mom_token, dad_token, family = _two_parent_family(backend)
    child = _add_child(backend, mom_token, family["id"], "Maya")
    kid_token = _child_token(backend, child["id"])
    task = _create_task(backend, mom_token, "Trash", child["id"])
    _submit(backend, kid_token, task["id"])
    backend.post("/notifications/read-all", headers=_headers(dad_token))
    backend.post("/notifications/read-all", headers=_headers(mom_token))
    _approve(backend, mom_token, task["id"])

    dad_notes = _notifications(backend, dad_token, unread_only=True)

    assert len(dad_notes) == 1
    assert dad_notes[0]["type"] == "approved"
    assert "Mom" in dad_notes[0]["title"]
    assert _notifications(backend, mom_token, unread_only=True) == []


def test_member_joined_notifies_existing_parent(backend):
    mom_token, _ = _register(backend, "mom@example.com", "Mom")
    family = _create_family(backend, mom_token)
    dad_token, _ = _register(backend, "dad@example.com", "Dad")

    joined = backend.post(
        "/families/join",
        json={"code": family["invite_code"]},
        headers=_headers(dad_token),
    )
    assert joined.status_code == 200, joined.text

    mom_notes = _notifications(backend, mom_token, unread_only=True)
    assert len(mom_notes) == 1
    assert mom_notes[0]["type"] == "member_joined"
    assert "Dad" in mom_notes[0]["title"]
    assert _notifications(backend, dad_token, unread_only=True) == []


def test_disabled_type_is_skipped(backend):
    mom_token, dad_token, family = _two_parent_family(backend)
    updated = backend.put(
        "/families/me/preferences",
        json={"review_needed": False},
        headers=_headers(mom_token),
    )
    assert updated.status_code == 200, updated.text
    child = _add_child(backend, mom_token, family["id"], "Maya")
    kid_token = _child_token(backend, child["id"])
    task = _create_task(backend, mom_token, "Trash", child["id"])
    _submit(backend, kid_token, task["id"])

    assert _notifications(backend, dad_token, unread_only=True) == []

    _approve(backend, mom_token, task["id"])
    dad_notes = _notifications(backend, dad_token, unread_only=True)
    assert len(dad_notes) == 1
    assert dad_notes[0]["type"] == "approved"


def test_preferences_default_and_merge(backend):
    mom_token, _, _ = _two_parent_family(backend)

    prefs = backend.get(
        "/families/me/preferences", headers=_headers(mom_token)
    )
    assert prefs.status_code == 200, prefs.text
    assert prefs.json() == {
        "review_needed": True,
        "approved": True,
        "member_joined": True,
    }

    updated = backend.put(
        "/families/me/preferences",
        json={"approved": False},
        headers=_headers(mom_token),
    )
    assert updated.status_code == 200, updated.text
    assert updated.json() == {
        "review_needed": True,
        "approved": False,
        "member_joined": True,
    }


def test_preferences_require_family_parent(backend):
    mom_token, _ = _register(backend, "mom@example.com", "Mom")
    resp = backend.get("/families/me/preferences", headers=_headers(mom_token))
    assert resp.status_code == 404

    family = _create_family(backend, mom_token)
    child = _add_child(backend, mom_token, family["id"], "Maya")
    kid_token = _child_token(backend, child["id"])
    resp = backend.get("/families/me/preferences", headers=_headers(kid_token))
    assert resp.status_code == 403


def test_read_flows(backend):
    mom_token, dad_token, family = _two_parent_family(backend)
    child = _add_child(backend, mom_token, family["id"], "Maya")
    kid_token = _child_token(backend, child["id"])
    task = _create_task(backend, mom_token, "Trash", child["id"])
    _submit(backend, kid_token, task["id"])
    _approve(backend, mom_token, task["id"])

    all_notes = _notifications(backend, dad_token)
    assert len(all_notes) == 2

    first = backend.put(
        f"/notifications/{all_notes[0]['id']}/read",
        headers=_headers(dad_token),
    )
    assert first.status_code == 200, first.text
    assert first.json()["is_read"] is True
    assert len(_notifications(backend, dad_token, unread_only=True)) == 1

    # Another parent's notification is not readable.
    forbidden = backend.put(
        f"/notifications/{all_notes[1]['id']}/read",
        headers=_headers(mom_token),
    )
    assert forbidden.status_code == 404

    cleared = backend.post(
        "/notifications/read-all", headers=_headers(dad_token)
    )
    assert cleared.status_code == 200, cleared.text
    assert cleared.json()["marked_read"] == 1
    assert _notifications(backend, dad_token, unread_only=True) == []
    assert len(_notifications(backend, dad_token)) == 2
