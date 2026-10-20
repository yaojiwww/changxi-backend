"""
test_edge_cases.py — 边界场景与系统性验证

覆盖：
  1. allowAnyOrigin + allowCredentials 非法组合
     路由 /cors/error/any-origin-creds 使用绕过 build() 注册的非法策略，
     请求时 CorsService.evaluatePolicy() 抛出 IllegalArgumentException → 500。

  2. Vary: Origin 系统性覆盖
     varyByOrigin 逻辑（来自 CorsService.populateResult）：
       allowAnyOrigin（无 credentials）→ varyByOrigin = false → 无 Vary
       setIsOriginAllowed（custom-fn）  → varyByOrigin = true  → Vary: Origin
       setIsOriginAllowedToAllowWildcardSubdomains → varyByOrigin = true → Vary: Origin
"""
import pytest
from conftest import get, request


# ============================================================
# 1. allowAnyOrigin + allowCredentials 非法组合
# ============================================================

class TestIllegalPolicy:
    """allowAnyOrigin + allowCredentials 组合 → CorsService.evaluatePolicy 抛异常"""

    PATH = "/cors/error/any-origin-creds"

    def test_preflight_triggers_illegal_argument_exception(self):
        """OPTIONS + Origin → CorsService.evaluatePolicy 抛 IllegalArgumentException → 500
        conftest 钩子将 5xx 响应转为 AssertionError，断言错误信息含关键字。
        """
        with pytest.raises(AssertionError) as exc_info:
            request("OPTIONS", self.PATH, headers={
                "Origin": "https://any.com",
                "Access-Control-Request-Method": "GET",
            })
        error_msg = str(exc_info.value)
        assert "500" in error_msg, f"期望 500，信息：{error_msg}"
        assert (
            "wildcard" in error_msg.lower() or "credentials" in error_msg.lower()
        ), f"错误信息应含 'wildcard' 或 'credentials'，实际：{error_msg}"

    def test_actual_request_triggers_illegal_argument_exception(self):
        """普通 GET + Origin → 同样触发异常 → 500"""
        with pytest.raises(AssertionError) as exc_info:
            get(self.PATH, headers={"Origin": "https://any.com"})
        error_msg = str(exc_info.value)
        assert "500" in error_msg
        assert (
            "wildcard" in error_msg.lower() or "credentials" in error_msg.lower()
        )

    def test_no_origin_no_cors_processing_returns_200(self):
        """无 Origin → CORS 中间件不处理，请求正常到达 handler → 200"""
        r = get(self.PATH)
        assert r.status_code == 200


# ============================================================
# 2. Vary: Origin 系统性覆盖
#
# varyByOrigin 规则（CorsService.populateResult）：
#   allowAnyOrigin 分支：varyByOrigin = policy.supportsCredentials
#   其他分支：          varyByOrigin = origins.size > 1 || !isDefaultIsOriginAllowed
# ============================================================

class TestVaryOriginSystematic:
    """Vary: Origin 响应头系统性验证"""

    ALLOWED_ORIGIN = "https://allowed.com"

    def test_allow_any_origin_no_vary(self):
        """allowAnyOrigin（无 credentials）→ varyByOrigin = false → 无 Vary: Origin
        ACAO 恒为 *，响应不随来源变化，缓存无需区分。
        """
        r = get("/cors/origins/any", headers={"Origin": "https://random.com"})
        assert r.status_code == 200
        vary = r.headers.get("vary", "")
        assert "Origin" not in vary, (
            f"allowAnyOrigin 无凭证策略不应有 Vary: Origin，实际 Vary: {vary}"
        )

    def test_custom_fn_origin_has_vary(self):
        """setIsOriginAllowed（自定义函数）→ isDefaultIsOriginAllowed=false
        → varyByOrigin = true → Vary: Origin 存在
        """
        r = get("/cors/origins/custom-fn", headers={"Origin": "https://api.trusted.io"})
        assert r.status_code == 200
        vary = r.headers.get("vary", "")
        assert "Origin" in vary, (
            f"自定义来源函数策略应有 Vary: Origin，实际 Vary: {vary}"
        )

    def test_wildcard_subdomain_has_vary(self):
        """setIsOriginAllowedToAllowWildcardSubdomains → isDefaultIsOriginAllowed=false
        → varyByOrigin = true → Vary: Origin 存在
        """
        r = get("/cors/origins/wildcard-sub", headers={"Origin": "https://sub.example.com"})
        assert r.status_code == 200
        vary = r.headers.get("vary", "")
        assert "Origin" in vary, (
            f"通配子域名策略应有 Vary: Origin，实际 Vary: {vary}"
        )

    def test_vary_present_in_preflight_custom_fn(self):
        """自定义函数策略预检响应也含 Vary: Origin"""
        r = request("OPTIONS", "/cors/origins/custom-fn", headers={
            "Origin": "https://api.trusted.io",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        vary = r.headers.get("vary", "")
        assert "Origin" in vary, (
            f"预检响应（自定义函数策略）应有 Vary: Origin，实际 Vary: {vary}"
        )

    def test_vary_present_in_preflight_wildcard_subdomain(self):
        """通配子域名策略预检响应也含 Vary: Origin"""
        r = request("OPTIONS", "/cors/origins/wildcard-sub", headers={
            "Origin": "https://sub.example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        vary = r.headers.get("vary", "")
        assert "Origin" in vary, (
            f"预检响应（通配子域名策略）应有 Vary: Origin，实际 Vary: {vary}"
        )
