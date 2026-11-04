"""Co-parent invites: mint, redeem (parent grant), single-use, expiry.

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
from app.models import FamilyInvite


@pytest.fixture()
def backend(tmp_path, monkeypatch):
    """App client on an isolated in-memory database.

    Lifespan artifacts (dev database file, uploads dir) land in tmp_path.
    Yields (client, session_factory); the factory allows direct DB setup
    such as backdating an invite's expiry.
    """
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


def _create_family(client, token, name="The Fam", pin="4321"):
    resp = client.post(
        "/families/",
        json={"name": name, "parent_pin": pin},
        headers=_headers(token),
    )
    assert resp.status_code == 201, resp.text
    return resp.json()


def _as_aware(value: datetime) -> datetime:
    # SQLite drops tzinfo; interpret naive timestamps as UTC.
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


def test_create_invite_returns_code_with_48h_expiry(backend):
    client, _ = backend
    token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, token)

    before = datetime.now(timezone.utc)
    resp = client.post(
        f"/families/{family['id']}/invites", headers=_headers(token)
    )

    assert resp.status_code == 201, resp.text
    body = resp.json()
    assert body["family_id"] == family["id"]
    assert body["role"] == "parent"
    assert len(body["code"]) == 6
    expires = _as_aware(datetime.fromisoformat(body["expires_at"]))
    assert before + timedelta(hours=47, minutes=59) < expires
    assert expires <= before + timedelta(hours=48, minutes=1)


def test_invite_requires_family_parent(backend):
    client, _ = backend
    token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, token)

    outsider_token, _ = _register(client, "stranger@example.com", "Stranger")
    resp = client.post(
        f"/families/{family['id']}/invites", headers=_headers(outsider_token)
    )
    assert resp.status_code == 404

    child = client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Kid", "mode": "kids"},
        headers=_headers(token),
    )
    switch = client.post(
        "/auth/switch-profile",
        json={"user_id": child.json()["id"], "pin": "4321"},
    )
    child_token = switch.json()["access_token"]
    resp = client.post(
        f"/families/{family['id']}/invites", headers=_headers(child_token)
    )
    assert resp.status_code == 403


def test_redeem_assigns_parent_role_and_links_family(backend):
    client, _ = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    invite = client.post(
        f"/families/{family['id']}/invites", headers=_headers(mom_token)
    ).json()

    dad_token, _ = _register(client, "dad@example.com", "Dad")
    resp = client.post(
        "/families/join",
        json={"code": invite["code"]},
        headers=_headers(dad_token),
    )

    assert resp.status_code == 200, resp.text
    assert resp.json()["id"] == family["id"]
    me = client.get("/auth/me", headers=_headers(dad_token)).json()
    assert me["family_id"] == family["id"]
    assert me["role"] == "parent"
    roster = client.get("/families/me", headers=_headers(dad_token)).json()
    assert {m["display_name"] for m in roster["members"]} == {"Mom", "Dad"}


def test_invite_is_single_use(backend):
    client, _ = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    invite = client.post(
        f"/families/{family['id']}/invites", headers=_headers(mom_token)
    ).json()

    dad_token, _ = _register(client, "dad@example.com", "Dad")
    first = client.post(
        "/families/join",
        json={"code": invite["code"]},
        headers=_headers(dad_token),
    )
    assert first.status_code == 200, first.text

    grandpa_token, _ = _register(client, "grandpa@example.com", "Grandpa")
    second = client.post(
        "/families/join",
        json={"code": invite["code"]},
        headers=_headers(grandpa_token),
    )
    assert second.status_code == 404


def test_legacy_family_code_still_joins(backend):
    client, _ = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)

    dad_token, _ = _register(client, "dad@example.com", "Dad")
    resp = client.post(
        "/families/join",
        json={"code": family["invite_code"]},
        headers=_headers(dad_token),
    )

    assert resp.status_code == 200, resp.text
    me = client.get("/auth/me", headers=_headers(dad_token)).json()
    assert me["family_id"] == family["id"]
    assert me["role"] == "parent"


def test_expired_invite_rejected(backend):
    client, testing_session = backend
    mom_token, _ = _register(client, "mom@example.com", "Mom")
    family = _create_family(client, mom_token)
    invite = client.post(
        f"/families/{family['id']}/invites", headers=_headers(mom_token)
    ).json()

    db = testing_session()
    try:
        row = db.query(FamilyInvite).filter_by(code=invite["code"]).one()
        row.expires_at = datetime.now(timezone.utc) - timedelta(minutes=1)
        db.commit()
    finally:
        db.close()

    dad_token, _ = _register(client, "dad@example.com", "Dad")
    resp = client.post(
        "/families/join",
        json={"code": invite["code"]},
        headers=_headers(dad_token),
    )
    assert resp.status_code == 404
