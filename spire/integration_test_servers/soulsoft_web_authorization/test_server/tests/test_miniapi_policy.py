"""
test_miniapi_policy.py — MiniAPI 策略授权测试（端口 5002）

覆盖场景：
  - requireAuthorization(["NamedPolicy"]) — ClaimsAuthorizationRequirement
  - requireAuthorization(["RolePolicy"])  — RolesAuthorizationRequirement
  - requireAuthorization { inline }       — 内联策略配置
  - requireAuthorization(directPolicy)   — 直接传入 AuthorizationPolicy 对象
  - AssertionRequirement 自定义断言
  - 多要求策略（AND 语义）
  - 跨策略隔离（admin 不满足 UserOnly，反之亦然）
"""

import pytest
from conftest import get, post, get_auth, obtain_token, URL_POLICY


def token(username="test-user", role="user", **extra):
    return obtain_token(URL_POLICY, username=username, role=role, **extra)


# ═══ 健康检查 ════════════════════════════════════════════════════════════════

class TestHealthCheck:
    def test_health_returns_200(self):
        r = get(URL_POLICY, "/health")
        assert r.status_code == 200

    def test_health_anonymous(self):
        """健康检查无须任何 Token"""
        r = get(URL_POLICY, "/health")
        assert r.text == "OK"


# ═══ 令牌生成 ═══════════════════════════════════════════════════════════════

class TestTokenGeneration:
    """POST /token — 支持 role、department、seniority 额外 claims"""

    def test_basic_token(self):
        r = post(URL_POLICY, "/token", json={"username": "u1", "role": "user"})
        assert r.status_code == 200
        assert "access_token" in r.json()

    def test_token_with_extra_claims(self):
        r = post(URL_POLICY, "/token", json={
            "username": "u2", "role": "admin",
            "department": "engineering", "seniority": "senior"
        })
        assert r.status_code == 200
        assert "access_token" in r.json()

    def test_default_role_is_user(self):
        r = post(URL_POLICY, "/token", json={})
        assert r.status_code == 200


# ═══ 命名策略（ClaimsAuthorizationRequirement） ══════════════════════════════

class TestAdminOnlyPolicy:
    """GET /admin — requireAuthorization(["AdminOnly"]) — requireClaim("role", ["admin"])"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/admin").status_code == 401

    def test_user_role_returns_403(self):
        """user 角色不满足 AdminOnly 策略，应返回 403"""
        r = get_auth(URL_POLICY, "/admin", token(role="user"))
        assert r.status_code in (401, 403)

    def test_admin_role_returns_200(self):
        r = get_auth(URL_POLICY, "/admin", token(role="admin"))
        assert r.status_code == 200

    def test_response_message(self):
        r = get_auth(URL_POLICY, "/admin", token(role="admin"))
        assert "Admin access granted" in r.json()["message"]


class TestUserOnlyPolicy:
    """GET /user — requireAuthorization(["UserOnly"]) — requireClaim("role", ["user"])"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/user").status_code == 401

    def test_user_role_returns_200(self):
        r = get_auth(URL_POLICY, "/user", token(role="user"))
        assert r.status_code == 200

    def test_admin_role_returns_403(self):
        """admin 不满足 UserOnly 策略"""
        r = get_auth(URL_POLICY, "/user", token(role="admin"))
        assert r.status_code in (401, 403)

    def test_response_message(self):
        r = get_auth(URL_POLICY, "/user", token(role="user"))
        assert "User access granted" in r.json()["message"]


# ═══ 命名策略（RolesAuthorizationRequirement） ═══════════════════════════════

class TestAdminRolePolicy:
    """GET /admin-role — requireAuthorization(["AdminRole"]) — requireRole(["admin"])"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/admin-role").status_code == 401

    def test_user_role_returns_403(self):
        r = get_auth(URL_POLICY, "/admin-role", token(role="user"))
        assert r.status_code in (401, 403)

    def test_admin_role_returns_200(self):
        r = get_auth(URL_POLICY, "/admin-role", token(role="admin"))
        assert r.status_code == 200

    def test_response_message(self):
        r = get_auth(URL_POLICY, "/admin-role", token(role="admin"))
        assert "Admin role granted" in r.json()["message"]


# ═══ 内联策略（requireAuthorization { configure }） ══════════════════════════

class TestInlinePolicy:
    """GET /inline-claim — requireAuthorization { p => p.requireClaim("role", ["admin"]) }"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/inline-claim").status_code == 401

    def test_admin_passes_inline_policy(self):
        r = get_auth(URL_POLICY, "/inline-claim", token(role="admin"))
        assert r.status_code == 200

    def test_user_fails_inline_policy(self):
        r = get_auth(URL_POLICY, "/inline-claim", token(role="user"))
        assert r.status_code in (401, 403)

    def test_response_message(self):
        r = get_auth(URL_POLICY, "/inline-claim", token(role="admin"))
        assert "Inline claim policy passed" in r.json()["message"]


# ═══ 直接策略对象（requireAuthorization(policy)） ════════════════════════════

class TestDirectPolicyObject:
    """GET /direct-policy — requireAuthorization(AuthorizationPolicy 实例)"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/direct-policy").status_code == 401

    def test_admin_passes(self):
        r = get_auth(URL_POLICY, "/direct-policy", token(role="admin"))
        assert r.status_code == 200

    def test_user_fails(self):
        r = get_auth(URL_POLICY, "/direct-policy", token(role="user"))
        assert r.status_code in (401, 403)

    def test_response_message(self):
        r = get_auth(URL_POLICY, "/direct-policy", token(role="admin"))
        assert "Direct policy object passed" in r.json()["message"]


# ═══ Assertion 策略（AssertionRequirement） ══════════════════════════════════

class TestAssertionPolicy:
    """GET /senior-only — AssertionRequirement: admin 角色 AND seniority=senior"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/senior-only").status_code == 401

    def test_admin_without_seniority_fails(self):
        """admin 但无 seniority=senior，断言应拒绝"""
        r = get_auth(URL_POLICY, "/senior-only", token(role="admin"))
        assert r.status_code in (401, 403)

    def test_user_with_seniority_fails(self):
        """有 seniority=senior 但角色为 user，断言应拒绝"""
        t = obtain_token(URL_POLICY, username="u", role="user", seniority="senior")
        r = get_auth(URL_POLICY, "/senior-only", t)
        assert r.status_code in (401, 403)

    def test_admin_with_seniority_passes(self):
        """admin 且 seniority=senior，断言应通过"""
        t = obtain_token(URL_POLICY, username="senior-admin", role="admin", seniority="senior")
        r = get_auth(URL_POLICY, "/senior-only", t)
        assert r.status_code == 200

    def test_response_message(self):
        t = obtain_token(URL_POLICY, username="sa", role="admin", seniority="senior")
        r = get_auth(URL_POLICY, "/senior-only", t)
        assert "Senior assertion passed" in r.json()["message"]


# ═══ 多要求策略（AND 语义） ══════════════════════════════════════════════════

class TestMultiRequirementPolicy:
    """GET /multi-req — requireClaim("role", ["admin"]) AND requireClaim("department", ["engineering"])"""

    def test_without_token_returns_401(self):
        assert get(URL_POLICY, "/multi-req").status_code == 401

    def test_only_admin_role_fails(self):
        """只有 admin 角色，缺少 department=engineering"""
        r = get_auth(URL_POLICY, "/multi-req", token(role="admin"))
        assert r.status_code in (401, 403)

    def test_only_department_fails(self):
        """有 department=engineering 但不是 admin 角色"""
        t = obtain_token(URL_POLICY, role="user", department="engineering")
        r = get_auth(URL_POLICY, "/multi-req", t)
        assert r.status_code in (401, 403)

    def test_admin_with_engineering_dept_passes(self):
        """同时满足 admin 角色 AND engineering 部门"""
        t = obtain_token(URL_POLICY, role="admin", department="engineering")
        r = get_auth(URL_POLICY, "/multi-req", t)
        assert r.status_code == 200

    def test_response_message(self):
        t = obtain_token(URL_POLICY, role="admin", department="engineering")
        r = get_auth(URL_POLICY, "/multi-req", t)
        assert "Multi-requirement policy passed" in r.json()["message"]

    def test_wrong_department_fails(self):
        """admin 角色但 department=marketing，不满足 engineering 要求"""
        t = obtain_token(URL_POLICY, role="admin", department="marketing")
        r = get_auth(URL_POLICY, "/multi-req", t)
        assert r.status_code in (401, 403)


# ═══ 跨策略隔离 ══════════════════════════════════════════════════════════════

class TestPolicyCrossIsolation:
    """验证不同策略之间严格隔离，防止意外越权"""

    def test_admin_cannot_access_user_only(self):
        admin_token = token(role="admin")
        assert get_auth(URL_POLICY, "/user", admin_token).status_code in (401, 403)

    def test_user_cannot_access_admin_only(self):
        user_token = token(role="user")
        assert get_auth(URL_POLICY, "/admin", user_token).status_code in (401, 403)

    def test_user_cannot_access_admin_role_policy(self):
        user_token = token(role="user")
        assert get_auth(URL_POLICY, "/admin-role", user_token).status_code in (401, 403)

    def test_invalid_token_rejected_by_all_policies(self):
        for path in ["/admin", "/user", "/admin-role", "/inline-claim", "/direct-policy"]:
            r = get_auth(URL_POLICY, path, "bad.token.value")
            assert r.status_code == 401, f"路径 {path} 应拒绝无效令牌"
