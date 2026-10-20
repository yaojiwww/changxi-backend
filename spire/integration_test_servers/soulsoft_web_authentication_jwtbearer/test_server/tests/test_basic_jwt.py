"""
test_basic_jwt.py — 基础JWT认证测试（端口5001）

测试场景：
  - 令牌生成端点
  - 受保护端点认证
  - 用户信息获取
  - 令牌验证诊断
"""

import pytest
from conftest import get, post, get_with_auth, post_with_auth, obtain_token, URL_BASIC


class TestHealthCheck:
    """健康检查端点测试"""

    def test_health_returns_200(self):
        r = get(URL_BASIC, "/health")
        assert r.status_code == 200

    def test_health_returns_ok(self):
        r = get(URL_BASIC, "/health")
        assert r.text == "OK"


class TestTokenGeneration:
    """令牌生成端点测试"""

    def test_token_generation_returns_200(self):
        r = post(URL_BASIC, "/token", json={})
        assert r.status_code == 200

    def test_token_generation_with_defaults(self):
        r = post(URL_BASIC, "/token", json={})
        data = r.json()
        assert "access_token" in data
        assert data["token_type"] == "Bearer"
        assert data["expires_in"] == 3600

    def test_token_generation_with_username(self):
        r = post(URL_BASIC, "/token", json={"username": "alice"})
        data = r.json()
        assert "access_token" in data

    def test_token_generation_with_role(self):
        r = post(URL_BASIC, "/token", json={"role": "admin"})
        data = r.json()
        assert "access_token" in data

    def test_token_has_three_parts(self):
        """JWT令牌应包含三个部分：header.payload.signature"""
        r = post(URL_BASIC, "/token", json={})
        token = r.json()["access_token"]
        parts = token.split(".")
        assert len(parts) == 3


class TestProtectedEndpoint:
    """受保护端点测试"""

    def test_protected_without_token_returns_401(self):
        """无令牌访问受保护端点应返回401"""
        r = get(URL_BASIC, "/protected")
        assert r.status_code == 401

    def test_protected_with_valid_token_returns_200(self):
        """携带有效令牌应能访问"""
        token = obtain_token(URL_BASIC, username="testuser")
        r = get_with_auth(URL_BASIC, "/protected", token)
        assert r.status_code == 200

    def test_protected_returns_authenticated_message(self):
        """受保护端点应返回认证成功消息"""
        token = obtain_token(URL_BASIC, username="testuser")
        r = get_with_auth(URL_BASIC, "/protected", token)
        data = r.json()
        assert data["authenticated"] is True
        assert "testuser" in data["message"]

    def test_protected_with_invalid_token_returns_401(self):
        """携带无效令牌应返回401"""
        r = get_with_auth(URL_BASIC, "/protected", "invalid.token.here")
        assert r.status_code == 401

    def test_protected_with_malformed_token_returns_401(self):
        """携带格式错误的令牌应返回401"""
        r = get_with_auth(URL_BASIC, "/protected", "not-a-valid-jwt")
        assert r.status_code == 401


class TestUserInfoEndpoint:
    """用户信息端点测试"""

    def test_userinfo_without_token_returns_401(self):
        """无令牌访问用户信息端点应返回401"""
        r = get(URL_BASIC, "/userinfo")
        assert r.status_code == 401

    def test_userinfo_with_valid_token_returns_claims(self):
        """携带有效令牌应返回用户声明"""
        token = obtain_token(URL_BASIC, username="alice", role="admin")
        r = get_with_auth(URL_BASIC, "/userinfo", token)
        assert r.status_code == 200
        data = r.json()
        # 验证声明中包含用户名和角色
        assert "name" in data or "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" in data

    def test_userinfo_contains_name_claim(self):
        """用户信息应包含name声明"""
        token = obtain_token(URL_BASIC, username="bob")
        r = get_with_auth(URL_BASIC, "/userinfo", token)
        assert r.status_code == 200
        data = r.json()
        # 检查name声明（可能是简写或完整URI）
        name_value = data.get("name") or data.get("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")
        assert name_value == "bob"


class TestTokenValidation:
    """令牌验证端点测试（无需认证）"""

    def test_validate_valid_token(self):
        """验证有效令牌应返回有效"""
        token = obtain_token(URL_BASIC)
        r = post(URL_BASIC, "/validate", json={"token": token})
        assert r.status_code == 200
        data = r.json()
        assert data["valid"] is True

    def test_validate_invalid_token(self):
        """验证无效令牌应返回无效"""
        r = post(URL_BASIC, "/validate", json={"token": "invalid.token.here"})
        # 验证端点对于无效令牌也返回200，但valid=false
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False

    def test_validate_empty_token(self):
        """验证空令牌应返回无效"""
        r = post(URL_BASIC, "/validate", json={"token": ""})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False

    def test_validate_missing_token_field(self):
        """请求中缺少token字段，空字符串应被视为无效令牌"""
        r = post(URL_BASIC, "/validate", json={})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False


class TestTokenClaims:
    """令牌声明验证"""

    def test_token_contains_name_claim(self):
        """生成的令牌应包含name声明，通过/userinfo端点验证"""
        token = obtain_token(URL_BASIC, username="testuser")
        r = get_with_auth(URL_BASIC, "/userinfo", token)
        assert r.status_code == 200
        data = r.json()
        name_value = (
            data.get("name")
            or data.get("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")
        )
        assert name_value == "testuser"

    def test_token_validate_returns_valid_true(self):
        """有效令牌调用/validate应返回valid=true"""
        token = obtain_token(URL_BASIC, username="testuser")
        r = post(URL_BASIC, "/validate", json={"token": token})
        assert r.status_code == 200
        assert r.json()["valid"] is True

    def test_token_contains_role_claim(self):
        """生成的令牌应包含role声明"""
        token = obtain_token(URL_BASIC, username="user", role="manager")
        # 获取用户信息验证role
        r = get_with_auth(URL_BASIC, "/userinfo", token)
        assert r.status_code == 200
        data = r.json()
        # 检查role声明
        role_value = data.get("role")
        assert role_value == "manager"


class TestAuthorizationHeaderFormat:
    """Authorization 头格式测试（缺少前缀/错误 scheme）"""

    def test_no_bearer_prefix_returns_401(self):
        """直接发送令牌（无 Bearer 前缀）应返回 401"""
        token = obtain_token(URL_BASIC)
        r = get(URL_BASIC, "/protected", headers={"Authorization": token})
        assert r.status_code == 401

    def test_basic_scheme_returns_401(self):
        """使用 Basic 认证方案应返回 401（服务器仅接受 Bearer）"""
        r = get(URL_BASIC, "/protected", headers={"Authorization": "Basic dXNlcjpwYXNz"})
        assert r.status_code == 401

    def test_bearer_without_token_returns_401(self):
        """Authorization: Bearer 后无令牌应返回 401"""
        r = get(URL_BASIC, "/protected", headers={"Authorization": "Bearer "})
        assert r.status_code == 401

    def test_no_authorization_header_returns_401(self):
        """完全不带 Authorization 头应返回 401"""
        r = get(URL_BASIC, "/protected")
        assert r.status_code == 401


class TestContentType:
    """响应 Content-Type 验证"""

    def test_token_endpoint_returns_json_content_type(self):
        """令牌端点应返回 application/json"""
        r = post(URL_BASIC, "/token", json={})
        assert r.status_code == 200
        assert "application/json" in r.headers.get("content-type", "")

    def test_protected_endpoint_returns_json_content_type(self):
        """受保护端点应返回 application/json"""
        token = obtain_token(URL_BASIC)
        r = get_with_auth(URL_BASIC, "/protected", token)
        assert r.status_code == 200
        assert "application/json" in r.headers.get("content-type", "")

    def test_validate_endpoint_returns_json_content_type(self):
        """验证端点应返回 application/json"""
        token = obtain_token(URL_BASIC)
        r = post(URL_BASIC, "/validate", json={"token": token})
        assert r.status_code == 200
        assert "application/json" in r.headers.get("content-type", "")
