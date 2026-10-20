"""
test_disable_cors.py — DisableCors / IDisableCors 元数据行为验证

路由设置（见 CorsRoutes.cj）：
  /cors/disabled/endpoint → GET + withMetadata([DisableCors()])

CorsMiddleware 检测到 IDisableCors 元数据后的行为：
  OPTIONS + Origin + ACR-Method（CORS 预检）→ 204，不附加任何 CORS 响应头
  普通请求 + Origin                          → 200，不附加任何 CORS 响应头（传递给 next）
  普通请求无 Origin                          → 200，正常响应（CORS 中间件无动作）

对比：无 requireCors 的普通路由（/cors/disable/no-policy）仍走全局默认策略，
而 DisableCors 端点完全屏蔽 CORS 处理，预检也不返回 ACAO。
"""
from conftest import get, request


PATH           = "/cors/disabled/endpoint"
ALLOWED_ORIGIN = "https://allowed.com"   # 在默认策略白名单中，但 DisableCors 端点不理会策略
DENIED_ORIGIN  = "https://evil.com"


class TestDisableCorsEndpoint:
    """DisableCors 元数据：完全屏蔽 CORS 处理"""

    # ── 预检请求 ─────────────────────────────────────────────────────────────

    def test_preflight_allowed_origin_no_acao(self):
        """DisableCors 端点 + 允许来源预检 → 204，无 ACAO（CORS 被禁用）"""
        r = request("OPTIONS", PATH, headers={
            "Origin": ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" not in r.headers, (
            "DisableCors 端点预检不应有 ACAO 头"
        )

    def test_preflight_denied_origin_no_acao(self):
        """DisableCors 端点 + 拒绝来源预检 → 204，无 ACAO"""
        r = request("OPTIONS", PATH, headers={
            "Origin": DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" not in r.headers

    def test_preflight_no_acam_header(self):
        """预检无 ACAM 头 → 204，无 ACAO"""
        r = request("OPTIONS", PATH, headers={
            "Origin": ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert "access-control-allow-methods" not in r.headers

    def test_preflight_no_acah_header(self):
        """预检无 ACAH 头"""
        r = request("OPTIONS", PATH, headers={
            "Origin": ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-My-Header",
        })
        assert r.status_code == 204
        assert "access-control-allow-headers" not in r.headers

    # ── 普通请求（非预检）────────────────────────────────────────────────────

    def test_actual_request_with_allowed_origin_no_acao(self):
        """DisableCors 端点 + 普通 GET + 允许来源 → 200，无 ACAO"""
        r = get(PATH, headers={"Origin": ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" not in r.headers, (
            "DisableCors 端点普通请求不应有 ACAO 头"
        )

    def test_actual_request_no_origin_returns_200(self):
        """无 Origin → CORS 中间件无动作，正常响应 200"""
        r = get(PATH)
        assert r.status_code == 200
        assert "access-control-allow-origin" not in r.headers

    # ── 与普通无策略路由对比 ─────────────────────────────────────────────────

    def test_contrast_no_policy_route_still_uses_default_policy(self):
        """对照：/cors/disable/no-policy（无 requireCors）+ 允许来源 → 仍有 ACAO
        说明 DisableCors 与"无策略路由"行为不同：后者走全局默认策略。
        """
        r = get("/cors/disable/no-policy", headers={"Origin": ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" in r.headers, (
            "无 requireCors 的普通路由仍应有 ACAO（走默认策略），"
            "以与 DisableCors 端点形成对比"
        )
