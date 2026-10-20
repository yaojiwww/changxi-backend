"""
test_miniapi_basic.py — MiniAPI 基础授权测试（端口 5001）

覆盖场景：
  - 无授权端点直通（/health、/token）
  - allowAnonymous() 显式匿名端点（/public）
  - requireAuthorization() 默认策略（/protected、/userinfo）
  - 无效/缺失 Token 返回 401
  - Authorization 头格式校验
  - 认证通过后 Claims 可读取
"""

import pytest
from conftest import get, post, get_auth, obtain_token, URL_BASIC


# ═══ 健康检查 ════════════════════════════════════════════════════════════════

class TestHealthCheck:
    """健康检查端点 — 无授权约束，middleware 直通"""

    def test_health_returns_200(self):
        r = get(URL_BASIC, "/health")
        assert r.status_code == 200

    def test_health_returns_ok_text(self):
        r = get(URL_BASIC, "/health")
        assert r.text == "OK"


# ═══ 令牌生成（匿名） ════════════════════════════════════════════════════════

class TestTokenGeneration:
    """POST /token — 无 IAuthorizeData，匿名可访问"""

    def test_returns_200(self):
        r = post(URL_BASIC, "/token", json={})
        assert r.status_code == 200

    def test_response_has_required_fields(self):
        r = post(URL_BASIC, "/token", json={})
        data = r.json()
        assert "access_token" in data
        assert data["token_type"] == "Bearer"
        assert data["expires_in"] == 3600

    def test_token_is_valid_jwt_format(self):
        """JWT 应为 header.payload.signature 三段式"""
        token = post(URL_BASIC, "/token", json={}).json()["access_token"]
        assert len(token.split(".")) == 3

    def test_custom_username_accepted(self):
        r = post(URL_BASIC, "/token", json={"username": "alice", "role": "user"})
        assert r.status_code == 200
        assert "access_token" in r.json()

    def test_admin_role_accepted(self):
        r = post(URL_BASIC, "/token", json={"username": "admin", "role": "admin"})
        assert r.status_code == 200
        assert "access_token" in r.json()

    def test_empty_body_uses_defaults(self):
        """空 body 使用默认 username=test-user, role=user"""
        r = post(URL_BASIC, "/token", json={})
        assert r.status_code == 200

    def test_returns_json_content_type(self):
        r = post(URL_BASIC, "/token", json={})
        assert "application/json" in r.headers.get("content-type", "")


# ═══ allowAnonymous() 显式匿名端点 ══════════════════════════════════════════

class TestAllowAnonymousEndpoint:
    """GET /public — .allowAnonymous() 挂载 IAllowAnonymous，中间件跳过授权检查"""

    def test_accessible_without_token(self):
        """无 Token 时也应返回 200"""
        r = get(URL_BASIC, "/public")
        assert r.status_code == 200

    def test_accessible_with_valid_token(self):
        """携带有效 Token 也应返回 200（不应因 allowAnonymous 而拒绝）"""
        token = obtain_token(URL_BASIC)
        r = get_auth(URL_BASIC, "/public", token)
        assert r.status_code == 200

    def test_response_message(self):
        r = get(URL_BASIC, "/public")
        data = r.json()
        assert "message" in data
        assert "anonymous" in data["message"].lower()


# ═══ requireAuthorization() — /protected ════════════════════════════════════

class TestProtectedEndpoint:
    """GET /protected — .requireAuthorization() 挂载默认 Authorize()（需要已认证用户）"""

    def test_without_token_returns_401(self):
        r = get(URL_BASIC, "/protected")
        assert r.status_code == 401

    def test_with_valid_token_returns_200(self):
        token = obtain_token(URL_BASIC, username="testuser")
        r = get_auth(URL_BASIC, "/protected", token)
        assert r.status_code == 200

    def test_response_contains_username(self):
        token = obtain_token(URL_BASIC, username="alice")
        r = get_auth(URL_BASIC, "/protected", token)
        data = r.json()
        assert data.get("authenticated") is True
        assert "alice" in data.get("message", "")

    def test_invalid_token_returns_401(self):
        r = get_auth(URL_BASIC, "/protected", "invalid.token.here")
        assert r.status_code == 401

    def test_malformed_token_returns_401(self):
        r = get_auth(URL_BASIC, "/protected", "not-a-jwt-at-all")
        assert r.status_code == 401

    def test_returns_json_content_type(self):
        token = obtain_token(URL_BASIC)
        r = get_auth(URL_BASIC, "/protected", token)
        assert "application/json" in r.headers.get("content-type", "")


# ═══ requireAuthorization() — /userinfo ══════════════════════════════════════

class TestUserInfoEndpoint:
    """GET /userinfo — 认证通过后读取 context.user 全部 Claims"""

    def test_without_token_returns_401(self):
        r = get(URL_BASIC, "/userinfo")
        assert r.status_code == 401

    def test_with_valid_token_returns_200(self):
        token = obtain_token(URL_BASIC, username="bob", role="user")
        r = get_auth(URL_BASIC, "/userinfo", token)
        assert r.status_code == 200

    def test_response_contains_is_authenticated(self):
        token = obtain_token(URL_BASIC, username="bob")
        r = get_auth(URL_BASIC, "/userinfo", token)
        data = r.json()
        assert data.get("isAuthenticated") is True

    def test_response_contains_claims_array(self):
        token = obtain_token(URL_BASIC, username="carol", role="admin")
        r = get_auth(URL_BASIC, "/userinfo", token)
        data = r.json()
        assert "claims" in data
        assert isinstance(data["claims"], list)
        assert len(data["claims"]) > 0

    def test_claims_contain_name(self):
        """Claims 数组中应能找到 Name claim"""
        token = obtain_token(URL_BASIC, username="carol")
        r = get_auth(URL_BASIC, "/userinfo", token)
        claims = r.json()["claims"]
        name_claims = [c for c in claims if "name" in c.get("type", "").lower()]
        assert len(name_claims) > 0
        assert any(c["value"] == "carol" for c in name_claims)

    def test_claims_contain_role(self):
        """Claims 数组中应能找到 role claim"""
        token = obtain_token(URL_BASIC, username="dave", role="manager")
        r = get_auth(URL_BASIC, "/userinfo", token)
        claims = r.json()["claims"]
        role_claims = [c for c in claims if c.get("type") == "role"]
        assert len(role_claims) > 0
        assert role_claims[0]["value"] == "manager"


# ═══ Authorization 头格式校验 ════════════════════════════════════════════════

class TestAuthorizationHeaderFormat:
    """错误的 Authorization 头格式均应返回 401"""

    def test_no_bearer_prefix_returns_401(self):
        token = obtain_token(URL_BASIC)
        r = get(URL_BASIC, "/protected", headers={"Authorization": token})
        assert r.status_code == 401

    def test_basic_scheme_returns_401(self):
        r = get(URL_BASIC, "/protected", headers={"Authorization": "Basic dXNlcjpwYXNz"})
        assert r.status_code == 401

    def test_bearer_with_empty_token_returns_401(self):
        r = get(URL_BASIC, "/protected", headers={"Authorization": "Bearer "})
        assert r.status_code == 401

    def test_no_authorization_header_returns_401(self):
        r = get(URL_BASIC, "/protected")
        assert r.status_code == 401
