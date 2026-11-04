"""Child auth: PIN-free child switching, child login, child PINs.

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


def _setup(client, pin="4321"):
    mom_token, mom = _register(client, "mom@example.com", "Mom")
    family = client.post(
        "/families/",
        json={"name": "The Fam", "parent_pin": pin},
        headers=_headers(mom_token),
    ).json()
    child = client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Maya", "mode": "kids"},
        headers=_headers(mom_token),
    ).json()
    return mom_token, mom, family, child


def _switch(client, user_id, pin=None):
    body = {"user_id": user_id}
    if pin is not None:
        body["pin"] = pin
    return client.post("/auth/switch-profile", json=body)


def _child_login(client, user_id, pin=None):
    body = {"user_id": user_id}
    if pin is not None:
        body["child_pin"] = pin
    return client.post("/auth/child-login", json=body)


def _set_pin(client, token, family_id, child_id, pin):
    return client.patch(
        f"/families/{family_id}/children/{child_id}/pin",
        json={"child_pin": pin},
        headers=_headers(token),
    )


def test_switch_to_child_without_pin_is_open(backend):
    mom_token, _, _, child = _setup(backend)

    resp = _switch(backend, child["id"])

    assert resp.status_code == 200, resp.text
    assert resp.json()["user"]["id"] == child["id"]


def test_switch_to_child_with_pin_requires_it(backend):
    mom_token, _, family, child = _setup(backend)
    created = _set_pin(
        backend, mom_token, family["id"], child["id"], "2468"
    )
    assert created.status_code == 200, created.text

    assert _switch(backend, child["id"]).status_code == 401
    assert _switch(backend, child["id"], pin="0000").status_code == 401
    # The parent PIN never grants child access.
    assert _switch(backend, child["id"], pin="4321").status_code == 401

    resp = _switch(backend, child["id"], pin="2468")
    assert resp.status_code == 200, resp.text
    assert resp.json()["user"]["display_name"] == "Maya"


def test_switch_to_parent_still_needs_parent_pin(backend):
    mom_token, mom, _, _ = _setup(backend)

    assert _switch(backend, mom["id"]).status_code == 401
    assert _switch(backend, mom["id"], pin="0000").status_code == 401

    resp = _switch(backend, mom["id"], pin="4321")
    assert resp.status_code == 200, resp.text


def test_child_login_flow(backend):
    mom_token, _, family, child = _setup(backend)

    open_resp = _child_login(backend, child["id"])
    assert open_resp.status_code == 200, open_resp.text
    assert open_resp.json()["user"]["role"] == "child"

    _set_pin(backend, mom_token, family["id"], child["id"], "2468")
    assert _child_login(backend, child["id"]).status_code == 401
    assert _child_login(backend, child["id"], pin="0000").status_code == 401

    resp = _child_login(backend, child["id"], pin="2468")
    assert resp.status_code == 200, resp.text
    assert resp.json()["user"]["id"] == child["id"]


def test_child_login_rejects_non_children(backend):
    mom_token, mom, _, _ = _setup(backend)

    assert _child_login(backend, mom["id"], pin="4321").status_code == 404
    assert _child_login(backend, 99999, pin="4321").status_code == 404


def test_set_and_clear_child_pin(backend):
    mom_token, _, family, child = _setup(backend)

    resp = _set_pin(backend, mom_token, family["id"], child["id"], "2468")
    assert resp.status_code == 200, resp.text
    roster = backend.get("/families/me", headers=_headers(mom_token)).json()
    maya = next(m for m in roster["members"] if m["id"] == child["id"])
    assert maya["has_child_pin"] is True
    assert _switch(backend, child["id"]).status_code == 401

    cleared = _set_pin(backend, mom_token, family["id"], child["id"], None)
    assert cleared.status_code == 200, cleared.text
    roster = backend.get("/families/me", headers=_headers(mom_token)).json()
    maya = next(m for m in roster["members"] if m["id"] == child["id"])
    assert maya["has_child_pin"] is False
    assert _switch(backend, child["id"]).status_code == 200


def test_set_pin_guards(backend):
    mom_token, _, family, child = _setup(backend)

    outsider_token, _ = _register(backend, "zed@example.com", "Zed")
    resp = _set_pin(
        backend, outsider_token, family["id"], child["id"], "2468"
    )
    assert resp.status_code == 404

    kid_token = _switch(backend, child["id"]).json()["access_token"]
    resp = _set_pin(backend, kid_token, family["id"], child["id"], "2468")
    assert resp.status_code == 403

    resp = _set_pin(backend, mom_token, family["id"], child["id"], "12")
    assert resp.status_code == 422
