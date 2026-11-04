"""Double-approval prevention: second review returns 409 naming the approver.

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


def _create_family(client, token, name="The Fam", pin="4321"):
    resp = client.post(
        "/families/",
        json={"name": name, "parent_pin": pin},
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


def _create_task(client, token, assignee_id, points=15):
    resp = client.post(
        "/tasks/",
        json={
            "title": "Take out trash",
            "points_reward": points,
            "assigned_to_user_id": assignee_id,
        },
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _submit(client, token, task_id, note="done"):
    resp = client.post(
        f"/tasks/{task_id}/submit",
        data={"note": note},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _approve(client, token, task_id, action="approve"):
    return client.put(
        f"/tasks/{task_id}/approve",
        json={"action": action},
        headers=_headers(token),
    )


def _balances(client, token):
    roster = client.get("/families/me", headers=_headers(token)).json()
    return {m["display_name"]: m["points_balance"] for m in roster["members"]}


def _approved_setup(client):
    """Family with a kid, a submitted task, and Mom's approval done."""
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    child = _add_child(client, mom_token, family["id"], "Maya")
    task = _create_task(client, mom_token, child["id"])
    kid_token = _child_token(client, child["id"])
    _submit(client, kid_token, task["id"])
    first = _approve(client, mom_token, task["id"])
    assert first.status_code == 200, first.text
    return mom_token, family, task


def test_second_approval_returns_409_with_approver(backend):
    mom_token, family, task = _approved_setup(backend)

    dad_token, _ = _register(backend, "dad@example.com", "Dad")
    joined = backend.post(
        "/families/join",
        json={"code": family["invite_code"]},
        headers=_headers(dad_token),
    )
    assert joined.status_code == 200, joined.text

    second = _approve(backend, dad_token, task["id"])

    assert second.status_code == 409, second.text
    detail = second.json()["detail"]
    assert "Already approved by Mom at " in detail
    # Points minted exactly once.
    assert _balances(backend, mom_token)["Maya"] == 15


def test_request_changes_after_approval_returns_409(backend):
    mom_token, _, task = _approved_setup(backend)

    resp = _approve(backend, mom_token, task["id"], action="request_changes")

    assert resp.status_code == 409, resp.text
    assert "Already approved by Mom at " in resp.json()["detail"]


def test_approve_without_submission_stays_404(backend):
    mom_token, _ = _register(backend, "mom@example.com", "Mom")
    family = _create_family(backend, mom_token)
    child = _add_child(backend, mom_token, family["id"], "Maya")
    task = _create_task(backend, mom_token, child["id"])

    resp = _approve(backend, mom_token, task["id"])

    assert resp.status_code == 404, resp.text
    assert resp.json()["detail"] == "No pending submission for this task."
