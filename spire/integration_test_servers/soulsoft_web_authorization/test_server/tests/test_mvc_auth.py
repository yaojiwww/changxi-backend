"""
test_mvc_auth.py — MVC 控制器授权测试（端口 5003）

覆盖场景：
  TokenController（匿名）
    - POST /api/token — 无注解，匿名令牌生成

  PublicController（类级 @AllowAnonymous）
    - GET /health             — 无 Token 可访（绝对路径，脱离 api/public 前缀）
    - GET /api/public/info    — 无 Token 可访

  AuthController（类级 @Authorize）
    - GET /api/auth/me        — 继承类级 @Authorize，需要认证
    - GET /api/auth/protected — 继承类级 @Authorize，需要认证
    - GET /api/auth/anon      — 方法级 @AllowAnonymous 覆盖类级 @Authorize，匿名可访

  PolicyController（方法级 @Authorize["Policy"]）
    - GET /api/policy/admin      — @Authorize["AdminOnly"]，admin 角色可访
    - GET /api/policy/user       — @Authorize["UserOnly"]，user 角色可访
    - GET /api/policy/admin-role — @Authorize["AdminRole"]，requireRole，admin 可访
    - GET /api/policy/open       — 无注解，不触发授权检查
    - GET /api/policy/force-anon — 方法级 @AllowAnonymous，无类级约束时匿名可访
"""

import pytest
from conftest import get, post, get_auth, obtain_mvc_token, URL_MVC


def token(username="test-user", role="user", **extra):
    return obtain_mvc_token(username=username, role=role, **extra)


# ═══ TokenController — 匿名令牌生成 ══════════════════════════════════════════

class TestMvcTokenGeneration:
    """POST /api/token — 无 @Authorize 注解，匿名可访"""

    def test_returns_200_without_token(self):
        r = post(URL_MVC, "/api/token", json={})
        assert r.status_code == 200

    def test_response_has_access_token(self):
        r = post(URL_MVC, "/api/token", json={"username": "u1", "role": "admin"})
        data = r.json()
        assert "access_token" in data
        assert data["token_type"] == "Bearer"

    def test_extra_claims_accepted(self):
        """TokenController 应接受 department 和 seniority 额外 claims"""
        r = post(URL_MVC, "/api/token", json={
            "username": "eng", "role": "admin",
            "department": "engineering", "seniority": "senior"
        })
        assert r.status_code == 200
        assert "access_token" in r.json()

    def test_default_values_used_for_empty_body(self):
        r = post(URL_MVC, "/api/token", json={})
        assert r.status_code == 200


# ═══ PublicController — 类级 @AllowAnonymous ══════════════════════════════════

class TestPublicController:
    """类级 @AllowAnonymous — 所有 action 无须认证"""

    def test_health_without_token_returns_200(self):
        r = get(URL_MVC, "/health")
        assert r.status_code == 200

    def test_health_returns_ok(self):
        r = get(URL_MVC, "/health")
        assert r.text == "OK"

    def test_info_without_token_returns_200(self):
        r = get(URL_MVC, "/api/public/info")
        assert r.status_code == 200

    def test_info_response_indicates_anonymous_access(self):
        r = get(URL_MVC, "/api/public/info")
        data = r.json()
        assert "message" in data
        assert "anonymous" in data["message"].lower() or "PublicController" in data.get("controller", "")

    def test_info_still_accessible_with_token(self):
        """有效 Token 同样可以访问 @AllowAnonymous 端点"""
        r = get_auth(URL_MVC, "/api/public/info", token())
        assert r.status_code == 200


# ═══ AuthController — 类级 @Authorize ════════════════════════════════════════

class TestAuthControllerProtected:
    """类级 @Authorize — 继承到所有 action，未认证时返回 401"""

    def test_me_without_token_returns_401(self):
        r = get(URL_MVC, "/api/auth/me")
        assert r.status_code == 401

    def test_me_with_valid_token_returns_200(self):
        r = get_auth(URL_MVC, "/api/auth/me", token(username="alice"))
        assert r.status_code == 200

    def test_me_response_is_authenticated(self):
        r = get_auth(URL_MVC, "/api/auth/me", token(username="alice"))
        data = r.json()
        assert data.get("isAuthenticated") is True

    def test_me_response_contains_claims(self):
        r = get_auth(URL_MVC, "/api/auth/me", token(username="carol", role="admin"))
        data = r.json()
        assert "claims" in data
        assert isinstance(data["claims"], list)
        assert len(data["claims"]) > 0

    def test_protected_without_token_returns_401(self):
        r = get(URL_MVC, "/api/auth/protected")
        assert r.status_code == 401

    def test_protected_with_valid_token_returns_200(self):
        r = get_auth(URL_MVC, "/api/auth/protected", token(username="bob"))
        assert r.status_code == 200

    def test_protected_response_contains_username(self):
        r = get_auth(URL_MVC, "/api/auth/protected", token(username="dave"))
        data = r.json()
        assert data.get("authenticated") is True
        assert "dave" in data.get("message", "")

    def test_invalid_token_returns_401(self):
        r = get_auth(URL_MVC, "/api/auth/me", "bad.token.here")
        assert r.status_code == 401


class TestAuthControllerAllowAnonymousOverride:
    """方法级 @AllowAnonymous 覆盖类级 @Authorize"""

    def test_anon_action_accessible_without_token(self):
        """类上有 @Authorize，但此方法有 @AllowAnonymous，无 Token 也应 200"""
        r = get(URL_MVC, "/api/auth/anon")
        assert r.status_code == 200

    def test_anon_action_accessible_with_token(self):
        r = get_auth(URL_MVC, "/api/auth/anon", token())
        assert r.status_code == 200

    def test_anon_response_confirms_allow_anonymous(self):
        r = get(URL_MVC, "/api/auth/anon")
        data = r.json()
        assert data.get("accessible") is True


# ═══ PolicyController — 方法级 @Authorize["PolicyName"] ══════════════════════

class TestPolicyControllerAdminOnly:
    """GET /api/policy/admin — @Authorize["AdminOnly"] — requireClaim("role", ["admin"])"""

    def test_without_token_returns_401(self):
        assert get(URL_MVC, "/api/policy/admin").status_code == 401

    def test_user_role_returns_403(self):
        r = get_auth(URL_MVC, "/api/policy/admin", token(role="user"))
        assert r.status_code in (401, 403)

    def test_admin_role_returns_200(self):
        r = get_auth(URL_MVC, "/api/policy/admin", token(username="admin1", role="admin"))
        assert r.status_code == 200

    def test_response_has_policy_field(self):
        r = get_auth(URL_MVC, "/api/policy/admin", token(role="admin"))
        data = r.json()
        assert data.get("policy") == "AdminOnly"


class TestPolicyControllerUserOnly:
    """GET /api/policy/user — @Authorize["UserOnly"] — requireClaim("role", ["user"])"""

    def test_without_token_returns_401(self):
        assert get(URL_MVC, "/api/policy/user").status_code == 401

    def test_user_role_returns_200(self):
        r = get_auth(URL_MVC, "/api/policy/user", token(username="user1", role="user"))
        assert r.status_code == 200

    def test_admin_role_returns_403(self):
        r = get_auth(URL_MVC, "/api/policy/user", token(role="admin"))
        assert r.status_code in (401, 403)

    def test_response_has_policy_field(self):
        r = get_auth(URL_MVC, "/api/policy/user", token(role="user"))
        data = r.json()
        assert data.get("policy") == "UserOnly"


class TestPolicyControllerAdminRole:
    """GET /api/policy/admin-role — @Authorize["AdminRole"] — requireRole(["admin"])"""

    def test_without_token_returns_401(self):
        assert get(URL_MVC, "/api/policy/admin-role").status_code == 401

    def test_user_role_returns_403(self):
        r = get_auth(URL_MVC, "/api/policy/admin-role", token(role="user"))
        assert r.status_code in (401, 403)

    def test_admin_role_returns_200(self):
        r = get_auth(URL_MVC, "/api/policy/admin-role", token(role="admin"))
        assert r.status_code == 200

    def test_response_contains_role(self):
        r = get_auth(URL_MVC, "/api/policy/admin-role", token(role="admin"))
        data = r.json()
        assert "role" in data


class TestPolicyControllerOpenAction:
    """GET /api/policy/open — 无 @Authorize 注解，不触发授权检查"""

    def test_accessible_without_token(self):
        """无注解 action 无 IAuthorizeData，授权中间件直通"""
        r = get(URL_MVC, "/api/policy/open")
        assert r.status_code == 200

    def test_accessible_with_token(self):
        r = get_auth(URL_MVC, "/api/policy/open", token())
        assert r.status_code == 200

    def test_response_message(self):
        r = get(URL_MVC, "/api/policy/open")
        data = r.json()
        assert "message" in data


class TestPolicyControllerForceAnon:
    """GET /api/policy/force-anon — 方法级 @AllowAnonymous（无类级约束）"""

    def test_accessible_without_token(self):
        r = get(URL_MVC, "/api/policy/force-anon")
        assert r.status_code == 200

    def test_accessible_with_token(self):
        r = get_auth(URL_MVC, "/api/policy/force-anon", token())
        assert r.status_code == 200

    def test_response_accessible_field(self):
        r = get(URL_MVC, "/api/policy/force-anon")
        assert r.json().get("accessible") is True


# ═══ 跨 controller 授权边界 ═══════════════════════════════════════════════════

class TestMvcAuthorizationBoundary:
    """验证不同 controller/action 之间的授权边界正确性"""

    def test_auth_controller_protects_multiple_actions(self):
        """类级 @Authorize 应覆盖所有未显式 @AllowAnonymous 的 action"""
        for path in ["/api/auth/me", "/api/auth/protected"]:
            r = get(URL_MVC, path)
            assert r.status_code == 401, f"路径 {path} 应要求认证"

    def test_public_controller_exposes_all_actions(self):
        """类级 @AllowAnonymous 应使所有 action 匿名可访"""
        for path in ["/health", "/api/public/info"]:
            r = get(URL_MVC, path)
            assert r.status_code == 200, f"路径 {path} 应匿名可访"

    def test_policy_controller_enforces_per_action_policies(self):
        """方法级 @Authorize 应各自独立执行，不互相影响"""
        user_token = token(role="user")
        admin_token = token(role="admin")
        # user 可访问 /user，不可访问 /admin
        assert get_auth(URL_MVC, "/api/policy/user", user_token).status_code == 200
        assert get_auth(URL_MVC, "/api/policy/admin", user_token).status_code in (401, 403)
        # admin 可访问 /admin，不可访问 /user
        assert get_auth(URL_MVC, "/api/policy/admin", admin_token).status_code == 200
        assert get_auth(URL_MVC, "/api/policy/user", admin_token).status_code in (401, 403)

    def test_invalid_token_blocked_across_protected_endpoints(self):
        """无效令牌在所有受保护端点均应返回 401"""
        protected = [
            "/api/auth/me",
            "/api/auth/protected",
            "/api/policy/admin",
            "/api/policy/user",
            "/api/policy/admin-role",
        ]
        for path in protected:
            r = get_auth(URL_MVC, path, "invalid.token.signature")
            assert r.status_code == 401, f"路径 {path} 应拒绝无效令牌"
