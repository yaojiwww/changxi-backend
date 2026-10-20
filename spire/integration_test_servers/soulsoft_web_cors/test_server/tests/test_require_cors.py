"""
test_require_cors.py — requireCors() 三种重载行为验证

路由设置（见 CorsRoutes.cj）：
  /cors/require/default → requireCors()            使用全局默认策略（allowed.com）
  /cors/require/named   → requireCors("creds")     使用命名策略（creds.com + credentials）
  /cors/require/inline  → requireCors { inline }   内联策略（inline.com）

CORS 预检行为（与 ASP.NET Core 对齐）：
  OPTIONS + Origin + ACR-Method → 204，ACAO 存在与否取决于策略
  OPTIONS + Origin（无 ACR-Method）→ 405（不是预检）
  OPTIONS 无 Origin → 405（CORS 中间件不处理）
  普通请求带 Origin → 路由决定状态码，策略通过则加 ACAO
"""
from conftest import get, request


# ============================================================
# requireCors() — 无参重载，使用全局默认策略
# 策略：withOrigins(["https://allowed.com"]).allowAnyMethod().allowAnyHeader()
# ============================================================

class TestRequireCorsNoArg:
    """requireCors() — 无参重载"""

    PATH           = "/cors/require/default"
    ALLOWED_ORIGIN = "https://allowed.com"
    DENIED_ORIGIN  = "https://evil.com"

    def test_preflight_allowed_origin_returns_204_with_acao(self):
        """允许来源预检 → 204 + ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        assert r.headers["access-control-allow-origin"] == self.ALLOWED_ORIGIN

    def test_preflight_denied_origin_returns_204_without_acao(self):
        """拒绝来源预检 → 204 无 ACAO（浏览器侧被拒）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_preflight_no_origin_returns_405(self):
        """OPTIONS 无 Origin → CORS 中间件不处理 → 405"""
        r = request("OPTIONS", self.PATH)
        assert r.status_code == 405

    def test_preflight_origin_without_acr_method_returns_405(self):
        """OPTIONS + Origin 无 ACR-Method → 不是预检 → 405"""
        r = request("OPTIONS", self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 405

    def test_actual_request_allowed_origin_has_acao(self):
        """普通 GET + 允许来源 → 200 + ACAO"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" in r.headers
        assert r.headers["access-control-allow-origin"] == self.ALLOWED_ORIGIN

    def test_actual_request_denied_origin_no_acao(self):
        """普通 GET + 拒绝来源 → 200 无 ACAO"""
        r = get(self.PATH, headers={"Origin": self.DENIED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" not in r.headers

    def test_actual_request_no_origin_no_acao(self):
        """普通 GET 无 Origin → 200 无 CORS 头"""
        r = get(self.PATH)
        assert r.status_code == 200
        assert "access-control-allow-origin" not in r.headers

    def test_preflight_any_method_reflected(self):
        """allowAnyMethod — 预检 POST → ACAM 反射 POST"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "POST",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        assert r.headers.get("access-control-allow-methods") == "POST"

    def test_preflight_any_header_reflected(self):
        """allowAnyHeader — 预检自定义头 → ACAH 反射该头"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-My-Header",
        })
        assert r.status_code == 204
        assert "access-control-allow-headers" in r.headers
        assert "X-My-Header" in r.headers["access-control-allow-headers"]


# ============================================================
# requireCors("creds") — 命名策略重载
# 策略：withOrigins(["https://creds.com"]).allowAnyMethod().allowAnyHeader().allowCredentials()
# ============================================================

class TestRequireCorsNamed:
    """requireCors("creds") — 命名策略重载"""

    PATH           = "/cors/require/named"
    ALLOWED_ORIGIN = "https://creds.com"
    WRONG_ORIGIN   = "https://allowed.com"   # 在 default 策略中，但不在 creds 策略中

    def test_preflight_creds_origin_allowed(self):
        """creds.com 预检 → 204 + ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        assert r.headers["access-control-allow-origin"] == self.ALLOWED_ORIGIN

    def test_preflight_default_origin_denied_by_creds_policy(self):
        """default 策略的 allowed.com 不在 creds 策略中 → 无 ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.WRONG_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_actual_request_has_allow_credentials_header(self):
        """allowCredentials → 普通响应 ACAC: true"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-credentials" in r.headers
        assert r.headers["access-control-allow-credentials"] == "true"

    def test_preflight_has_allow_credentials_header(self):
        """allowCredentials → 预检响应 ACAC: true"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-credentials") == "true"

    def test_named_policy_not_confused_with_default(self):
        """命名策略独立于默认策略 — 两者来源不互通"""
        # creds.com 不在 default 策略中，因此 /cors/require/default 应拒绝它
        r = request("OPTIONS", "/cors/require/default", headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers, (
            "creds.com 不应被默认策略接受"
        )


# ============================================================
# requireCors(configurePolicy) — 内联策略重载
# 策略：withOrigins(["https://inline.com"]).allowAnyMethod().allowAnyHeader()（内联注册）
# ============================================================

class TestRequireCorsInline:
    """requireCors(configurePolicy) — 内联策略重载"""

    PATH           = "/cors/require/inline"
    ALLOWED_ORIGIN = "https://inline.com"
    DENIED_ORIGIN  = "https://allowed.com"   # 在其他策略中，但不在内联策略中

    def test_preflight_inline_origin_allowed(self):
        """inline.com 预检 → 204 + ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        assert r.headers["access-control-allow-origin"] == self.ALLOWED_ORIGIN

    def test_preflight_other_origin_denied_by_inline_policy(self):
        """其他来源不在内联策略中 → 无 ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_actual_request_inline_origin(self):
        """普通 GET + inline.com → 200 + ACAO"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" in r.headers

    def test_inline_policy_independent_from_named_policies(self):
        """内联策略与命名策略完全独立 — inline.com 不应被 default 路由接受"""
        r = request("OPTIONS", "/cors/require/default", headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers, (
            "inline.com 不应被默认策略接受"
        )

    def test_preflight_any_method_reflected_in_inline(self):
        """内联策略 allowAnyMethod — 预检 GET → ACAM 反射 GET（路由为 mapGet）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        assert r.headers.get("access-control-allow-methods") == "GET"
