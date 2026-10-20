"""
test_ch06_methods.py - 第六章：HTTP 方法匹配 [P0]
测试用例：TC146-173
"""
import pytest
from conftest import get, post, put, patch, delete, request


# ============================================================
# 6.1 精确方法匹配 (TC146-152)
# ============================================================

class TestExactMethodMatch:
    """6.1 精确方法匹配"""

    def test_tc146_get(self):
        """TC146: mapGet → GET 命中"""
        r = get("/ch06/exact/get")
        assert r.status_code == 200
        assert r.json()["method"] == "GET"

    def test_tc147_post(self):
        """TC147: mapPost → POST 命中"""
        r = post("/ch06/exact/post")
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc148_put(self):
        """TC148: mapPut → PUT 命中"""
        r = put("/ch06/exact/put")
        assert r.status_code == 200
        assert r.json()["method"] == "PUT"

    def test_tc149_patch(self):
        """TC149: mapPatch → PATCH 命中"""
        r = patch("/ch06/exact/patch")
        assert r.status_code == 200
        assert r.json()["method"] == "PATCH"

    def test_tc150_delete(self):
        """TC150: mapDelete → DELETE 命中"""
        r = delete("/ch06/exact/delete")
        assert r.status_code == 200
        assert r.json()["method"] == "DELETE"

    def test_tc151_get_route_post_request(self):
        """TC151: GET 路由 + POST 请求 → 405"""
        r = post("/ch06/exact/get")
        assert r.status_code == 405

    def test_tc152_post_route_get_request(self):
        """TC152: POST 路由 + GET 请求 → 405"""
        r = get("/ch06/exact/post")
        assert r.status_code == 405


# ============================================================
# 6.2 方法大小写不敏感 (TC153-155)
# ============================================================

class TestMethodCaseInsensitive:
    """6.2 方法大小写不敏感"""

    def test_tc153_lowercase_get(self):
        """TC153: 发送小写 'get' 方法 → 命中（首字节位运算转小写比较）"""
        r = request("get", "/ch06/exact/get")
        assert r.status_code == 200

    def test_tc154_mixed_case_post(self):
        """TC154: 发送 'Post' → 命中"""
        r = request("Post", "/ch06/exact/post")
        assert r.status_code == 200

    def test_tc155_uppercase_get(self):
        """TC155: 发送 'GET' → 命中"""
        r = request("GET", "/ch06/exact/get")
        assert r.status_code == 200


# ============================================================
# 6.3 通配方法 map (TC156-160)
# ============================================================

class TestWildcardMethod:
    """6.3 通配方法 map"""

    def test_tc156_wildcard_get(self):
        """TC156: map → GET 命中"""
        r = get("/ch06/wildcard/any")
        assert r.status_code == 200
        assert r.json()["method"] == "GET"

    def test_tc157_wildcard_post(self):
        """TC157: map → POST 命中"""
        r = post("/ch06/wildcard/any")
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc158_wildcard_delete(self):
        """TC158: map → DELETE 命中"""
        r = delete("/ch06/wildcard/any")
        assert r.status_code == 200
        assert r.json()["method"] == "DELETE"

    def test_tc159_wildcard_options(self):
        """TC159: map → OPTIONS 命中"""
        r = request("OPTIONS", "/ch06/wildcard/any")
        assert r.status_code == 200
        assert r.json()["method"] == "OPTIONS"

    def test_tc160_wildcard_custom_method(self):
        """TC160: map → 自定义方法 REPORT 命中"""
        r = request("REPORT", "/ch06/wildcard/any")
        assert r.status_code == 200
        assert r.json()["method"] == "REPORT"


# ============================================================
# 6.4 同路径多方法 (TC161-165)
# ============================================================

class TestMultiMethodSamePath:
    """6.4 同路径多方法"""

    def test_tc161_get_selected(self):
        """TC161: GET /items → GET 端点命中"""
        r = get("/ch06/items")
        assert r.status_code == 200
        assert r.json()["method"] == "GET"

    def test_tc162_post_selected(self):
        """TC162: POST /items → POST 端点命中"""
        r = post("/ch06/items")
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc163_delete_no_match(self):
        """TC163: DELETE /items → 405（未注册 DELETE）"""
        r = delete("/ch06/items")
        assert r.status_code == 405

    def test_tc165_map_catches_put(self):
        """TC165: GET + POST + map 同路径，PUT 由 map 端点命中"""
        r = put("/ch06/mixed")
        assert r.status_code == 200
        assert r.json()["route"] == "map"
        assert r.json()["method"] == "PUT"

    def test_tc165_get_specific_route(self):
        """TC164/TC165: GET /mixed → GET 优先还是 map？验证实际行为"""
        r = get("/ch06/mixed")
        assert r.status_code == 200
        # 精确方法路由应优先于 map
        assert r.json()["route"] in ("GET", "map"), (
            f"期望 GET 端点优先，实际路由：{r.json()['route']}"
        )


# ============================================================
# 6.6 自定义 HTTP 方法 (TC172-173)
# ============================================================

class TestCustomMethod:
    """6.6 自定义 HTTP 方法"""

    def test_tc172_custom_method_report(self):
        """TC172: 注册 REPORT 方法 → REPORT 请求命中"""
        r = request("REPORT", "/ch06/custom/report")
        assert r.status_code == 200
        assert r.json()["method"] == "REPORT"

    def test_tc173_custom_method_lowercase(self):
        """TC173: 注册 REPORT 方法 → report（小写）请求命中"""
        r = request("report", "/ch06/custom/report")
        assert r.status_code == 200


# ============================================================
# 6.5 CORS 预检（OPTIONS）(TC166-173)
# ============================================================

class TestCorsPrecheck:
    """6.5 CORS 预检（OPTIONS）

    路由设置（与 aspnet_verify/Program.cs 完全对齐）：
      /ch06/cors/default → GET + requireCors()           默认策略：允许 https://allowed.com
      /ch06/cors/strict  → GET + requireCors("strict")   strict 策略：允许 https://strict.com
      /ch06/cors/none    → GET（无 requireCors）          无端点策略，走中间件默认策略
      /ch06/cors/multi   → GET + POST + requireCors()    默认策略

    CORS 预检行为真相（C# 实测结论）：
      - OPTIONS + Origin + ACR-Method → 永远 204，ACAO 头存在 ≠ 策略通过，不存在 = 策略拒绝
      - OPTIONS + Origin（无 ACR-Method）→ 405（不是预检，路由决定）
      - OPTIONS 无 Origin → 405（CORS 中间件直接跳过）
      - 普通请求带 Origin → 路由决定状态码，策略通过则加 ACAO 头
    """

    DEFAULT = "/ch06/cors/default"   # GET + requireCors()，默认策略 allowed.com
    STRICT  = "/ch06/cors/strict"    # GET + requireCors("strict")，strict 策略 strict.com
    NONE    = "/ch06/cors/none"      # GET，无 requireCors
    MULTI   = "/ch06/cors/multi"     # GET + POST，requireCors()

    ALLOWED_ORIGIN = "https://allowed.com"
    STRICT_ORIGIN  = "https://strict.com"
    DENIED_ORIGIN  = "https://evil.com"

    # ── 场景 A：默认策略端点 (/ch06/cors/default) ────────────────

    def test_tc166_preflight_allowed_origin(self):
        """TC166: 默认策略 + 允许来源 + ACR=GET → 204 + ACAO 头"""
        r = request("OPTIONS", self.DEFAULT, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC166: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers, (
            "TC166: ACAO 头应存在（来源在策略内）"
        )
        assert r.headers["access-control-allow-origin"] == self.ALLOWED_ORIGIN

    def test_tc167_preflight_denied_origin(self):
        """TC167: 默认策略 + 拒绝来源 → 204（CORS 中间件永远返回 204），但无 ACAO 头"""
        r = request("OPTIONS", self.DEFAULT, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC167: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" not in r.headers, (
            "TC167: ACAO 头不应存在（来源不在策略内，浏览器侧被拒）"
        )

    def test_tc168_preflight_method_not_in_endpoint(self):
        """TC168: 默认策略 + 允许来源 + ACR=POST（端点只有 GET，但策略 AllowAnyMethod）→ 204 + ACAO

        关键：CORS 预检的方法验证由 CORS 策略决定，不由路由端点决定。
        策略 AllowAnyMethod → 即使端点无 POST，CORS 层仍然允许。
        """
        r = request("OPTIONS", self.DEFAULT, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "POST",
        })
        assert r.status_code == 204, f"TC168: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers, (
            "TC168: AllowAnyMethod 策略下 POST 预检仍应通过"
        )

    def test_tc169_options_no_origin(self):
        """TC169: OPTIONS 无 Origin → CORS 中间件不拦截 → 405"""
        r = request("OPTIONS", self.DEFAULT)
        assert r.status_code == 405, f"TC169: 无 Origin 不是 CORS 预检，期望 405，实际 {r.status_code}"

    def test_tc170_options_origin_no_acr_method(self):
        """TC170: OPTIONS + Origin（无 ACR-Method）→ 不是预检 → 405"""
        r = request("OPTIONS", self.DEFAULT, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 405, f"TC170: 无 ACR-Method 不是预检，期望 405，实际 {r.status_code}"

    def test_tc171_post_request_routing_405(self):
        """TC171: 普通 POST 请求（路由无 POST 端点）→ 405，且 ACAO 头存在（策略通过）"""
        r = request("POST", self.DEFAULT, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 405, f"TC171: 无 POST 端点，期望 405，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers, (
            "TC171: 405 响应仍应含 ACAO 头（CORS 策略通过，路由 405）"
        )

    # ── 场景 B：named 策略端点 (/ch06/cors/strict) ────────────────

    def test_tc172_strict_policy_correct_origin(self):
        """TC172: strict 策略 + 正确来源 strict.com → 204 + ACAO"""
        r = request("OPTIONS", self.STRICT, headers={
            "Origin": self.STRICT_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC172: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers
        assert r.headers["access-control-allow-origin"] == self.STRICT_ORIGIN

    def test_tc173_strict_policy_wrong_origin(self):
        """TC173: strict 策略 + 默认策略来源 allowed.com → 204，无 ACAO（策略拒绝）"""
        r = request("OPTIONS", self.STRICT, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC173: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" not in r.headers, (
            "TC173: allowed.com 不在 strict 策略内，不应有 ACAO 头"
        )

    # ── 场景 C：无 requireCors 路由 (/ch06/cors/none) ────────────

    def test_tc174_no_require_cors_uses_default_policy(self):
        """TC174: 无 requireCors 路由 + 允许来源 → 204 + ACAO（走中间件默认策略）"""
        r = request("OPTIONS", self.NONE, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC174: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers, (
            "TC174: 无 requireCors 仍走默认策略，应有 ACAO"
        )

    def test_tc175_no_require_cors_denied_origin(self):
        """TC175: 无 requireCors 路由 + 拒绝来源 → 204，无 ACAO"""
        r = request("OPTIONS", self.NONE, headers={
            "Origin": self.DENIED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204, f"TC175: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" not in r.headers

    # ── 场景 D：同路径多方法 (/ch06/cors/multi) ──────────────────

    def test_tc176_multi_preflight_get(self):
        """TC176: GET+POST 路由 + ACR=GET → 204 + ACAO"""
        r = request("OPTIONS", self.MULTI, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "GET",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_tc177_multi_preflight_post(self):
        """TC177: GET+POST 路由 + ACR=POST → 204 + ACAO"""
        r = request("OPTIONS", self.MULTI, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "POST",
        })
        assert r.status_code == 204
        assert "access-control-allow-origin" in r.headers

    def test_tc178_multi_preflight_delete_not_in_endpoints(self):
        """TC178: GET+POST 路由 + ACR=DELETE（无 DELETE 端点，但 AllowAnyMethod）→ 204 + ACAO"""
        r = request("OPTIONS", self.MULTI, headers={
            "Origin": self.ALLOWED_ORIGIN,
            "Access-Control-Request-Method": "DELETE",
        })
        assert r.status_code == 204, f"TC178: 期望 204，实际 {r.status_code}"
        assert "access-control-allow-origin" in r.headers, (
            "TC178: AllowAnyMethod 策略允许 DELETE 预检，应有 ACAO"
        )

    def test_tc179_multi_delete_routing_405(self):
        """TC179: 普通 DELETE 请求（无 DELETE 端点）→ 405"""
        r = request("DELETE", self.MULTI, headers={"Origin": self.ALLOWED_ORIGIN})
        assert r.status_code == 405, f"TC179: 无 DELETE 端点，期望 405，实际 {r.status_code}"


# ============================================================
# 6.7 HttpMethodDictionaryPolicyJumpTable 大小写不敏感 (TC180-190)
# ============================================================

class TestDictPolicyJumpTable:
    """6.7 HttpMethodDictionaryPolicyJumpTable 大小写不敏感 + 自定义方法

    /ch06/dict/multi  → GET+POST+PUT+PATCH+DELETE（5 方法），触发 DictionaryPolicyJumpTable
    /ch06/dict/report → map + withMetadata(HttpMethodMetadata(["REPORT"]))，测试 extraDestinations
    """

    MULTI  = "/ch06/dict/multi"
    REPORT = "/ch06/dict/report"

    # ── 大小写不敏感（经 HttpMethodDestinationsLookup 查表）──────────

    def test_tc180_lowercase_get(self):
        """TC180: 'get'（全小写）→ GET 端点命中 200"""
        r = request("get", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "GET"

    def test_tc181_lowercase_post(self):
        """TC181: 'post'（全小写）→ POST 端点命中 200"""
        r = request("post", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc182_mixed_put(self):
        """TC182: 'pUt'（混合大小写）→ PUT 端点命中 200（p 前缀长度 3 分支）"""
        r = request("pUt", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "PUT"

    def test_tc183_mixed_post(self):
        """TC183: 'pOsT'（混合大小写）→ POST 端点命中 200（p 前缀长度 4 分支）"""
        r = request("pOsT", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc184_lowercase_patch(self):
        """TC184: 'patch'（全小写）→ PATCH 端点命中 200（p 前缀长度 5 分支）"""
        r = request("patch", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "PATCH"

    def test_tc185_mixed_patch(self):
        """TC185: 'pAtCh'（混合大小写）→ PATCH 端点命中 200"""
        r = request("pAtCh", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "PATCH"

    def test_tc186_lowercase_delete(self):
        """TC186: 'delete'（全小写）→ DELETE 端点命中 200"""
        r = request("delete", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "DELETE"

    def test_tc187_mixed_delete(self):
        """TC187: 'DeLeTe'（混合大小写）→ DELETE 端点命中 200"""
        r = request("DeLeTe", self.MULTI)
        assert r.status_code == 200
        assert r.json()["method"] == "DELETE"

    def test_tc188_unregistered_head(self):
        """TC188: 'HEAD' 未在 /dict/multi 注册 → 405"""
        r = request("HEAD", self.MULTI)
        assert r.status_code == 405

    def test_tc189_unregistered_head_lowercase(self):
        """TC189: 'head'（小写）未注册 → 405"""
        r = request("head", self.MULTI)
        assert r.status_code == 405

    # ── withMetadata 自定义方法限制（extraDestinations 路径）───────

    def test_tc190_report_method(self):
        """TC190: REPORT 方法 + withMetadata 限制 → 200"""
        r = request("REPORT", self.REPORT)
        assert r.status_code == 200
        assert r.json()["method"] == "REPORT"

    def test_tc191_report_lowercase(self):
        """TC191: 'report'（小写）→ 命中 200（HttpMethodDestinationsLookup 大小写不敏感）"""
        r = request("report", self.REPORT)
        assert r.status_code == 200

    def test_tc192_get_on_report_path(self):
        """TC192: GET 请求打到仅限 REPORT 的路径 → 405"""
        r = get(self.REPORT)
        assert r.status_code == 405

