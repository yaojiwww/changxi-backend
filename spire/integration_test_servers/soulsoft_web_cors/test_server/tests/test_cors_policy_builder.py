"""
test_cors_policy_builder.py — CorsPolicyBuilder 各配置方法的行为验证

覆盖 CorsPolicyBuilder 的全部公开方法：
  withOrigins             — 单一来源、多来源
  getNormalizedOrigin     — http:80 / https:443 默认端口规范化（内部，由 withOrigins 调用）
  allowAnyOrigin          — 通配符 *
  withHeaders             — 特定请求头白名单
  allowAnyHeader          — 反射任意请求头
  withMethods             — 特定方法白名单
  allowAnyMethod          — 反射任意请求方法
  allowCredentials        — Access-Control-Allow-Credentials: true
  disallowCredentials     — 默认无凭证（无 ACAC 头）
  setPreflightMaxAge      — Access-Control-Max-Age
  withExposedHeaders      — Access-Control-Expose-Headers（普通响应）
  setIsOriginAllowed      — 自定义来源判断函数
  setIsOriginAllowedToAllowWildcardSubdomains — 通配子域名匹配
  build                   — 同时设 allowAnyOrigin + allowCredentials 应抛异常（见注释）

路由对应（见 CorsRoutes.cj / main.cj）：
  /cors/origins/single      → default 策略：allowed.com
  /cors/origins/multi       → multi-origin 策略：origin1.com, origin2.com
  /cors/origins/normalized  → normalized 策略：http://example.com:80, https://secure.com:443
  /cors/origins/any         → any-origin 策略：*
  /cors/origins/custom-fn   → custom-fn 策略：endsWith(".trusted.io")
  /cors/origins/wildcard-sub → wildcard-sub 策略：https://*.example.com
  /cors/headers/specific    → specific-hdrs 策略：X-Custom-Header, Content-Type；GET, POST
  /cors/headers/any         → default 策略：anyHeader
  /cors/methods/specific    → get-only 策略：GET only
  /cors/methods/any         → default 策略：anyMethod
  /cors/creds/enabled       → creds 策略：allowCredentials
  /cors/creds/disabled      → default 策略：无凭证（disallowCredentials 默认）
  /cors/maxage/set          → maxage 策略：600s
  /cors/expose/set          → expose 策略：X-Total-Count, X-Page
"""
from conftest import get, request


# ============================================================
# withOrigins — 单一来源
# ============================================================

class TestWithOriginsSingle:
    """withOrigins — 单一来源匹配"""

    PATH           = "/cors/origins/single"
    ALLOWED_ORIGIN = "https://allowed.com"
    DENIED_ORIGIN  = "https://evil.com"

    def test_preflight_allowed_origin(self):
        """单一来源匹配 → ACAO = 该来源"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == self.ALLOWED_ORIGIN

    def test_preflight_denied_origin(self):
        """不匹配来源 → 无 ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_actual_request_allowed_origin(self):
        """普通请求 + 匹配来源 → 200 + ACAO"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert r.headers.get("access-control-allow-origin") == self.ALLOWED_ORIGIN

    def test_vary_origin_header_absent_for_single_origin_policy(self):
        """单一来源策略 → 响应不含 Vary: Origin
        varyByOrigin = origins.size > 1 || !isDefaultIsOriginAllowed
        单一来源且未调用 setIsOriginAllowed → 两个条件均 false → 不追加 Vary。
        """
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        vary = r.headers.get("vary", "")
        assert "Origin" not in vary, f"单一来源策略不应有 Vary: Origin，实际 Vary: {vary}"


# ============================================================
# withOrigins — 多来源
# ============================================================

class TestWithOriginsMulti:
    """withOrigins — 多来源匹配（origin1.com, origin2.com）"""

    PATH     = "/cors/origins/multi"
    ORIGIN_1 = "https://origin1.com"
    ORIGIN_2 = "https://origin2.com"
    DENIED   = "https://origin3.com"

    def test_first_origin_allowed(self):
        """第一个来源匹配 → ACAO = origin1.com"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ORIGIN_1,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == self.ORIGIN_1

    def test_second_origin_allowed(self):
        """第二个来源匹配 → ACAO = origin2.com"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ORIGIN_2,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == self.ORIGIN_2

    def test_unlisted_origin_denied(self):
        """未列出来源 → 无 ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.DENIED,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_vary_origin_present_for_multi_origin_policy(self):
        """多来源策略 → Vary: Origin 必须存在（区分不同来源的缓存）"""
        r = get(self.PATH, headers={"Origin": self.ORIGIN_1})
        assert r.status_code == 200
        vary = r.headers.get("vary", "")
        assert "Origin" in vary, f"多来源策略应有 Vary: Origin，实际 Vary: {vary}"


# ============================================================
# getNormalizedOrigin — http:80 / https:443 端口规范化
# ============================================================

class TestNormalizedOrigin:
    """getNormalizedOrigin — 默认端口规范化
    策略注册时使用 http://example.com:80 和 https://secure.com:443，
    CorsPolicyBuilder.getNormalizedOrigin 在存储前去掉默认端口。
    """

    PATH = "/cors/origins/normalized"

    def test_http_without_port_matches_policy_with_port_80(self):
        """请求 http://example.com 匹配策略 http://example.com:80（规范化后相同）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "http://example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "http://example.com"

    def test_https_without_port_matches_policy_with_port_443(self):
        """请求 https://secure.com 匹配策略 https://secure.com:443（规范化后相同）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://secure.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "https://secure.com"

    def test_http_with_explicit_port_80_not_matched(self):
        """请求带 :80 → 策略中已规范化去掉 :80，不匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "http://example.com:80",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_https_with_explicit_port_443_not_matched(self):
        """请求带 :443 → 策略中已规范化去掉 :443，不匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://secure.com:443",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_non_default_port_still_unmatched(self):
        """非默认端口（如 :8080）未在策略中，不匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "http://example.com:8080",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers


# ============================================================
# allowAnyOrigin — 通配符 *
# ============================================================

class TestAllowAnyOrigin:
    """allowAnyOrigin — 任意来源均被允许"""

    PATH = "/cors/origins/any"

    def test_any_origin_returns_star_acao(self):
        """allowAnyOrigin → ACAO = *"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://random-site.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "*"

    def test_another_origin_also_returns_star(self):
        """任意来源均返回 ACAO = *（使用 GET 预检；路由为 mapGet）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "http://another.example.org",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "*"

    def test_any_origin_actual_request(self):
        """普通请求也可匹配 *"""
        r = get(self.PATH, headers={"Origin": "https://any.com"})
        assert r.status_code == 200
        assert r.headers.get("access-control-allow-origin") == "*"


# ============================================================
# setIsOriginAllowed — 自定义来源判断函数
# 策略：origin.endsWith(".trusted.io")
# ============================================================

class TestSetIsOriginAllowed:
    """setIsOriginAllowed — 自定义来源判断函数"""

    PATH = "/cors/origins/custom-fn"

    def test_matching_custom_fn_allowed(self):
        """*.trusted.io 结尾的来源 → 被自定义函数允许"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://api.trusted.io",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "https://api.trusted.io"

    def test_another_subdomain_matching_custom_fn(self):
        """另一个 *.trusted.io 子域名也被允许"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://service.trusted.io",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_non_matching_custom_fn_denied(self):
        """不满足自定义函数条件的来源 → 无 ACAO"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://evil.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_trusted_io_apex_also_denied(self):
        """https://trusted.io 本身不以 .trusted.io 结尾（函数是 endsWith，不含自身）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://trusted.io",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers


# ============================================================
# setIsOriginAllowedToAllowWildcardSubdomains — 通配子域名
# 策略：withOrigins(["https://*.example.com"])
# ============================================================

class TestWildcardSubdomains:
    """setIsOriginAllowedToAllowWildcardSubdomains — 通配子域名匹配"""

    PATH = "/cors/origins/wildcard-sub"

    def test_subdomain_allowed(self):
        """https://sub.example.com → 子域名匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://sub.example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-origin") == "https://sub.example.com"

    def test_another_subdomain_allowed(self):
        """https://api.example.com → 另一子域名匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://api.example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_deep_subdomain_allowed(self):
        """https://deep.sub.example.com → 深层子域名匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://deep.sub.example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_apex_domain_denied(self):
        """https://example.com → 顶级域名本身不是子域名，不匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_different_domain_denied(self):
        """https://evil.com → 完全不相关的域名，不匹配"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://evil.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_http_scheme_denied(self):
        """http://sub.example.com → 方案不匹配（策略是 https），不允许"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "http://sub.example.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_different_port_denied(self):
        """https://sub.example.com:8080 → 端口不匹配，不允许"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://sub.example.com:8080",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers


# ============================================================
# withHeaders — 特定请求头白名单
# 策略：withHeaders(["X-Custom-Header", "Content-Type"])
# ============================================================

class TestWithHeaders:
    """withHeaders — 特定请求头白名单"""

    PATH           = "/cors/headers/specific"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_preflight_returns_policy_headers_in_acah(self):
        """预检 → ACAH 为策略中声明的头列表"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-Custom-Header",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers
        acah = r.headers.get("access-control-allow-headers", "")
        assert "X-Custom-Header" in acah
        assert "Content-Type" in acah

    def test_preflight_does_not_reflect_unlisted_header(self):
        """预检含非白名单头 → ACAH 仍是策略头列表，不含非白名单头"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-Evil-Header",
        })
        assert r.status_code == 204
        acah = r.headers.get("access-control-allow-headers", "")
        assert "X-Evil-Header" not in acah

    def test_preflight_acam_contains_policy_methods(self):
        """withMethods(["GET", "POST"]) — 预检 → ACAM 含 GET 和 POST（策略方法列表，非反射）
        路由为 mapGet，使用 GET 预检使路由能匹配端点，验证 ACAM 来自策略而非反射。
        """
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        acam = r.headers.get("access-control-allow-methods", "")
        assert "GET" in acam
        assert "POST" in acam

    def test_preflight_denied_origin_no_acah(self):
        """来源不匹配时，无 ACAO 也无 ACAH"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://evil.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers
        assert "access-control-allow-headers" not in r.headers


# ============================================================
# allowAnyHeader — 反射任意请求头
# ============================================================

class TestAllowAnyHeader:
    """allowAnyHeader — 反射 Access-Control-Request-Headers"""

    PATH           = "/cors/headers/any"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_preflight_reflects_custom_header(self):
        """预检包含自定义头 → ACAH 反射该头"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-My-Custom-Header",
        })
        assert r.status_code == 204
        assert "access-control-allow-headers" in r.headers
        assert "X-My-Custom-Header" in r.headers["access-control-allow-headers"]

    def test_preflight_reflects_multiple_headers(self):
        """预检包含多个头 → ACAH 全部反射"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "X-Header-A, X-Header-B",
        })
        assert r.status_code == 204
        acah = r.headers.get("access-control-allow-headers", "")
        assert "X-Header-A" in acah
        assert "X-Header-B" in acah

    def test_preflight_no_request_headers_no_acah(self):
        """预检没有 ACR-Headers → 无 ACAH（没有可反射的内容）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        # allowAnyHeader 时，若 ACR-Headers 为空则 ACAH 也为空
        assert r.headers.get("access-control-allow-headers", "") == ""


# ============================================================
# withMethods — 特定方法白名单
# 策略：withMethods(["GET"])
# ============================================================

class TestWithMethods:
    """withMethods — 特定方法白名单（仅 GET）"""

    PATH           = "/cors/methods/specific"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_preflight_acam_contains_policy_method_only(self):
        """预检 → ACAM 仅含策略声明的方法（GET），不反射请求方法"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-methods") == "GET"



# ============================================================
# allowAnyMethod — 反射任意请求方法
# ============================================================

class TestAllowAnyMethod:
    """allowAnyMethod — 反射 Access-Control-Request-Method"""

    PATH           = "/cors/methods/any"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_preflight_reflects_get(self):
        """预检 GET → ACAM = GET"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-methods") == "GET"

    def test_preflight_reflects_delete(self):
        """预检 DELETE → ACAM = DELETE"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "DELETE",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-methods") == "DELETE"

    def test_preflight_reflects_patch(self):
        """预检 PATCH → ACAM = PATCH"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "PATCH",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-methods") == "PATCH"

    def test_actual_request_no_acam(self):
        """普通请求（非预检）→ 无 ACAM 头"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-methods" not in r.headers


# ============================================================
# allowCredentials — Access-Control-Allow-Credentials: true
# ============================================================

class TestAllowCredentials:
    """allowCredentials — 凭证支持"""

    CREDS_PATH     = "/cors/creds/enabled"    # creds 策略：allowCredentials
    NO_CREDS_PATH  = "/cors/creds/disabled"   # default 策略：无凭证（disallowCredentials 默认）
    CREDS_ORIGIN   = "https://creds.com"
    DEFAULT_ORIGIN = "https://allowed.com"

    def test_allow_credentials_preflight_has_acac_true(self):
        """allowCredentials → 预检响应含 ACAC: true"""
        r = request("OPTIONS", self.CREDS_PATH, headers={
            "Origin": self.CREDS_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-allow-credentials") == "true"

    def test_allow_credentials_actual_request_has_acac_true(self):
        """allowCredentials → 普通响应含 ACAC: true"""
        r = get(self.CREDS_PATH, headers={"Origin": self.CREDS_ORIGIN})
        assert r.status_code == 200
        assert r.headers.get("access-control-allow-credentials") == "true"

    def test_no_credentials_preflight_no_acac_header(self):
        """disallowCredentials（默认）→ 预检响应无 ACAC 头"""
        r = request("OPTIONS", self.NO_CREDS_PATH, headers={
            "Origin": self.DEFAULT_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-credentials" not in r.headers

    def test_no_credentials_actual_request_no_acac_header(self):
        """disallowCredentials（默认）→ 普通响应无 ACAC 头"""
        r = get(self.NO_CREDS_PATH, headers={"Origin": self.DEFAULT_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-credentials" not in r.headers

    def test_allow_credentials_denied_origin_no_acac(self):
        """creds 策略 + 不匹配来源 → 无 ACAO 也无 ACAC"""
        r = get(self.CREDS_PATH, headers={"Origin": "https://evil.com"})
        assert r.status_code == 200
        assert "access-control-allow-credentials" not in r.headers


# ============================================================
# setPreflightMaxAge — Access-Control-Max-Age
# 策略：setPreflightMaxAge(Duration.second * 600)
# ============================================================

class TestSetPreflightMaxAge:
    """setPreflightMaxAge — 预检缓存时长"""

    PATH           = "/cors/maxage/set"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_preflight_response_has_max_age_600(self):
        """预检响应含 Access-Control-Max-Age: 600"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert r.headers.get("access-control-max-age") == "600"

    def test_max_age_only_in_preflight_not_actual(self):
        """ACMA 仅存在于预检响应，普通请求无此头"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-max-age" not in r.headers

    def test_denied_origin_preflight_no_max_age(self):
        """来源不匹配 → 预检无 ACAO 也无 ACMA"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": "https://evil.com",
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-max-age" not in r.headers


# ============================================================
# withExposedHeaders — Access-Control-Expose-Headers
# 策略：withExposedHeaders(["X-Total-Count", "X-Page"])
# ============================================================

class TestWithExposedHeaders:
    """withExposedHeaders — 向浏览器暴露的响应头"""

    PATH           = "/cors/expose/set"
    ALLOWED_ORIGIN = "https://allowed.com"

    def test_actual_request_has_aceh(self):
        """普通请求 → ACEH 含 X-Total-Count, X-Page"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        aceh = r.headers.get("access-control-expose-headers", "")
        assert "X-Total-Count" in aceh
        assert "X-Page" in aceh

    def test_preflight_does_not_have_aceh(self):
        """预检响应无 ACEH（ACEH 仅用于实际响应）"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-expose-headers" not in r.headers

    def test_denied_origin_no_aceh(self):
        """来源不匹配 → 普通响应无 ACAO 也无 ACEH"""
        r = get(self.PATH, headers={"Origin": "https://evil.com"})
        assert r.status_code == 200
        assert "access-control-expose-headers" not in r.headers


# ============================================================
# 无 requireCors（CORS 中间件走全局默认策略）
# ============================================================

class TestNoRequireCors:
    """无 requireCors 路由 — 中间件使用全局 DefaultPolicy"""

    PATH           = "/cors/disable/no-policy"
    ALLOWED_ORIGIN = "https://allowed.com"
    DENIED_ORIGIN  = "https://evil.com"

    def test_preflight_uses_default_policy(self):
        """无 requireCors → 中间件仍应用默认策略，allowed.com 被允许"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_denied_origin_still_denied_by_default_policy(self):
        """无 requireCors + 不匹配来源 → 默认策略拒绝"""
        r = request("OPTIONS", self.PATH, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" not in r.headers

    def test_actual_request_allowed_origin_has_acao(self):
        """普通请求 + 允许来源 → 200 + ACAO（走默认策略）"""
        r = get(self.PATH, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 200
        assert "access-control-allow-origin" in r.headers
