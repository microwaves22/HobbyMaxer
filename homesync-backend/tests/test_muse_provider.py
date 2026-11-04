"""Muse quick-add provider: prompt, transport, and router fallback.

Run from homesync-backend/::

    pip install -r requirements-dev.txt
    pytest tests/test_muse_provider.py
"""

import json
import urllib.error
from datetime import datetime, timezone
from types import SimpleNamespace

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.main import app
from app.services import ai_provider
from app.services.ai_provider import (
    MuseQuickAddProvider,
    QuickAddProviderError,
    build_muse_prompt,
)

NOW = datetime(2026, 11, 4, 12, 0, tzinfo=timezone.utc)  # a Wednesday


class _FakeResponse:
    def __init__(self, payload):
        self._data = json.dumps(payload).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        return False

    def read(self):
        return self._data


def _chat(content):
    return {"choices": [{"message": {"content": content}}]}


def test_prompt_carries_roster_ids_and_message():
    prompt = build_muse_prompt(
        "Noah has soccer", [(3, "Noah"), (4, "Ava")], NOW
    )
    assert "Noah (id 3)" in prompt
    assert "Ava (id 4)" in prompt
    assert "Noah has soccer" in prompt
    assert NOW.isoformat() in prompt


def test_prompt_handles_empty_roster():
    prompt = build_muse_prompt("Mow the lawn", [], NOW)
    assert "Roster: none" in prompt


def test_muse_parse_posts_model_and_returns_json(monkeypatch):
    drafts = {
        "events": [
            {
                "title": "Soccer",
                "starts_at": "2026-11-05T17:00:00+00:00",
                "ends_at": "2026-11-05T18:00:00+00:00",
                "attendee_names": ["Noah"],
            }
        ],
        "tasks": [],
        "warnings": ["note"],
    }
    seen = {}

    def fake(request, timeout=None):
        seen["auth"] = request.get_header("Authorization")
        seen["body"] = json.loads(request.data.decode("utf-8"))
        return _FakeResponse(_chat(json.dumps(drafts)))

    monkeypatch.setattr(ai_provider.urllib.request, "urlopen", fake)
    out = MuseQuickAddProvider(
        api_key="k", api_url="https://example.test/v1", model="m"
    ).parse("Noah has soccer", [(3, "Noah")], NOW)

    assert out == drafts
    assert seen["auth"] == "Bearer k"
    assert seen["body"]["model"] == "m"
    assert "Noah has soccer" in seen["body"]["messages"][0]["content"]


def test_muse_parse_requires_key():
    with pytest.raises(QuickAddProviderError, match="not configured"):
        MuseQuickAddProvider(api_key="").parse("hi", [], NOW)


def test_muse_http_error_raises_provider_error(monkeypatch):
    def fake(request, timeout=None):
        raise urllib.error.HTTPError(
            "https://example.test", 401, "denied", None, None
        )

    monkeypatch.setattr(ai_provider.urllib.request, "urlopen", fake)
    with pytest.raises(QuickAddProviderError, match="HTTP 401"):
        MuseQuickAddProvider(api_key="k").parse("hi", [], NOW)


def test_muse_unreachable_raises_provider_error(monkeypatch):
    def fake(request, timeout=None):
        raise urllib.error.URLError("nope")

    monkeypatch.setattr(ai_provider.urllib.request, "urlopen", fake)
    with pytest.raises(QuickAddProviderError, match="unreachable"):
        MuseQuickAddProvider(api_key="k").parse("hi", [], NOW)


@pytest.mark.parametrize(
    "payload",
    [
        _chat(json.dumps([])),  # non-object JSON
        _chat("not json"),  # message is not JSON
        {"choices": []},  # no message content
        _chat(json.dumps({"events": {}, "tasks": []})),  # bad shape
    ],
)
def test_muse_bad_replies_raise_provider_error(monkeypatch, payload):
    monkeypatch.setattr(
        ai_provider.urllib.request,
        "urlopen",
        lambda request, timeout=None: _FakeResponse(payload),
    )
    with pytest.raises(QuickAddProviderError):
        MuseQuickAddProvider(api_key="k").parse("hi", [], NOW)


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
    client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Noah", "mode": "teen"},
        headers=_headers(mom_token),
    )
    client.post(
        f"/families/{family['id']}/children",
        json={"display_name": "Ava", "mode": "kids"},
        headers=_headers(mom_token),
    )
    return mom_token


def _quick_add(client, token, text):
    return client.post(
        "/ai/quick-add", json={"text": text}, headers=_headers(token)
    )


def test_router_falls_back_to_local_when_muse_fails(backend, monkeypatch):
    mom_token = _family(backend)

    class _FailingMuse:
        def parse(self, text, members, now):
            raise QuickAddProviderError("boom")

    monkeypatch.setattr(
        "app.routers.ai.MuseQuickAddProvider", _FailingMuse
    )
    monkeypatch.setattr(
        "app.routers.ai.settings", SimpleNamespace(meta_ai_api_key="k")
    )

    resp = _quick_add(
        backend, mom_token, "Ava needs to empty the dishwasher daily"
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["tasks"]) == 1
    assert any("offline parser" in warning for warning in body["warnings"])


def test_router_validates_muse_drafts_strictly(backend, monkeypatch):
    mom_token = _family(backend)

    class _StubMuse:
        def parse(self, text, members, now):
            return {
                "events": [
                    {
                        "title": "Soccer",
                        "starts_at": "2026-11-05T17:00:00+00:00",
                        "ends_at": "2026-11-05T18:00:00+00:00",
                        "attendee_names": ["Noah"],
                    }
                ],
                "tasks": [{"title": "Bad", "repeat_rule": "nonsense"}],
                "warnings": [],
            }

    monkeypatch.setattr("app.routers.ai.MuseQuickAddProvider", _StubMuse)
    monkeypatch.setattr(
        "app.routers.ai.settings", SimpleNamespace(meta_ai_api_key="k")
    )

    resp = _quick_add(backend, mom_token, "anything")

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["events"]) == 1
    assert body["tasks"] == []
    assert any("repeat_rule" in warning for warning in body["warnings"])
