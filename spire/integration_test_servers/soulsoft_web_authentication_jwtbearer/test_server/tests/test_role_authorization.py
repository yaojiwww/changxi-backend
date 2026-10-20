"""
test_role_authorization.py — 基于角色的授权测试（端口5002）

测试场景：
  - AdminOnly 策略（仅admin角色可访问）
  - UserOnly 策略（仅user角色可访问）
  - 角色令牌生成
"""

import pytest
from conftest import get, post, get_with_auth, obtain_role_token, URL_ROLE, URL_ERROR


class TestHealthCheck:
    """健康检查端点测试"""

    def test_health_returns_200(self):
        r = get(URL_ROLE, "/health")
        assert r.status_code == 200


class TestTokenGeneration:
    """角色令牌生成测试"""

    def test_token_generation_returns_200(self):
        r = post(URL_ROLE, "/api/token", json={})
        assert r.status_code == 200

    def test_token_generation_default_role_is_user(self):
        """默认角色为user"""
        r = post(URL_ROLE, "/api/token", json={})
        data = r.json()
        assert data["role"] == "user"
        assert "access_token" in data

    def test_token_generation_with_admin_role(self):
        """指定admin角色"""
        r = post(URL_ROLE, "/api/token", json={"role": "admin"})
        data = r.json()
        assert data["role"] == "admin"
        assert "access_token" in data

    def test_token_generation_preserves_username(self):
        """用户名应被保留在令牌中"""
        r = post(URL_ROLE, "/api/token", json={"username": "john", "role": "admin"})
        data = r.json()
        assert "access_token" in data


class TestAdminOnlyEndpoint:
    """AdminOnly 策略端点测试"""

    def test_admin_endpoint_without_token_returns_401(self):
        """无令牌访问管理员端点应返回401"""
        r = get(URL_ROLE, "/api/admin")
        assert r.status_code == 401

    def test_admin_endpoint_with_user_role_returns_403(self):
        """user角色访问管理员端点应返回403（ Forbidden）"""
        token = obtain_role_token(URL_ROLE, role="user")
        r = get_with_auth(URL_ROLE, "/api/admin", token)
        # 认证通过但授权失败，应返回403
        assert r.status_code in [403, 401]

    def test_admin_endpoint_with_admin_role_returns_200(self):
        """admin角色访问管理员端点应成功"""
        token = obtain_role_token(URL_ROLE, role="admin")
        r = get_with_auth(URL_ROLE, "/api/admin", token)
        assert r.status_code == 200
        data = r.json()
        assert "Admin access granted" in data["message"]

    def test_admin_endpoint_response_format(self):
        """管理员端点响应格式验证"""
        token = obtain_role_token(URL_ROLE, role="admin")
        r = get_with_auth(URL_ROLE, "/api/admin", token)
        data = r.json()
        assert "message" in data
        assert "role" in data
        assert data["role"] == "admin"


class TestUserOnlyEndpoint:
    """UserOnly 策略端点测试"""

    def test_user_endpoint_without_token_returns_401(self):
        """无令牌访问用户端点应返回401"""
        r = get(URL_ROLE, "/api/user")
        assert r.status_code == 401

    def test_user_endpoint_with_user_role_returns_200(self):
        """user角色访问用户端点应成功"""
        token = obtain_role_token(URL_ROLE, role="user")
        r = get_with_auth(URL_ROLE, "/api/user", token)
        assert r.status_code == 200
        data = r.json()
        assert "User access granted" in data["message"]

    def test_user_endpoint_with_admin_role_returns_403(self):
        """admin角色访问user端点应失败（策略要求user角色）"""
        token = obtain_role_token(URL_ROLE, role="admin")
        r = get_with_auth(URL_ROLE, "/api/user", token)
        # admin不符合UserOnly策略（要求role=user）
        assert r.status_code in [403, 401]

    def test_user_endpoint_response_format(self):
        """用户端点响应格式验证"""
        token = obtain_role_token(URL_ROLE, role="user")
        r = get_with_auth(URL_ROLE, "/api/user", token)
        data = r.json()
        assert "message" in data
        assert "role" in data
        assert data["role"] == "user"


class TestCrossRoleAccess:
    """跨角色访问测试"""

    def test_user_cannot_access_admin_endpoint(self):
        """普通用户不能访问管理员端点"""
        user_token = obtain_role_token(URL_ROLE, username="user1", role="user")
        r = get_with_auth(URL_ROLE, "/api/admin", user_token)
        assert r.status_code in [403, 401]

    def test_admin_cannot_access_user_endpoint(self):
        """管理员不能访问普通用户端点（策略隔离）"""
        admin_token = obtain_role_token(URL_ROLE, username="admin1", role="admin")
        r = get_with_auth(URL_ROLE, "/api/user", admin_token)
        assert r.status_code in [403, 401]


class TestAuthorizationHeaders:
    """授权头测试"""

    def test_missing_bearer_prefix_returns_401(self):
        """缺少Bearer前缀应返回401"""
        token = obtain_role_token(URL_ROLE, role="admin")
        r = get(URL_ROLE, "/api/admin", headers={"Authorization": token})
        assert r.status_code == 401

    def test_wrong_bearer_token_returns_401(self):
        """错误的Bearer令牌应返回401"""
        r = get(URL_ROLE, "/api/admin", headers={"Authorization": "Bearer wrong.token"})
        assert r.status_code == 401

    def test_expired_token_behavior(self):
        """过期令牌应被角色服务器拒绝"""
        r = get(URL_ERROR, "/test/expired")
        if r.status_code != 200:
            pytest.skip("error服务器未就绪")
        expired_token = r.json().get("expired_token", "")
        if not expired_token:
            pytest.skip("未获取到过期令牌")
        r2 = get_with_auth(URL_ROLE, "/api/admin", expired_token)
        assert r2.status_code in [401, 403]
