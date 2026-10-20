"""
test_healthchecks.py - HealthChecks 中间件功能测试

覆盖场景：
  1. 状态码映射（Healthy/Degraded/Unhealthy）
  2. 默认响应体（text/plain 状态名）
  3. Content-Type 响应头
  4. 防缓存响应头（allowCachingResponses=false 默认值）
  5. allowCachingResponses=true 时不注入防缓存头
  6. predicate 名称过滤
  7. predicate tag 过滤
  8. 路径精确匹配（/healthz 不干扰 /healthz/only-healthy）
  9. 尾部斜杠容忍（/healthz/only-healthy/ == /healthz/only-healthy）
  10. mapHealthChecks 端点路由
"""
import pytest
from conftest import get, get_raw


# ============================================================
# 1. 状态码映射
# ============================================================

class TestStatusCodes:
    """Healthy → 200, Degraded → 200, Unhealthy → 503"""

    def test_healthy_returns_200(self):
        """TC-01: /healthz/only-healthy → 200"""
        r = get("/healthz/only-healthy")
        assert r.status_code == 200

    def test_degraded_returns_200(self):
        """TC-02: /healthz/only-degraded → 200（Degraded 默认映射 200）"""
        r = get("/healthz/only-degraded")
        assert r.status_code == 200

    def test_unhealthy_returns_503(self):
        """TC-03: /healthz/only-unhealthy → 503"""
        r = get_raw("/healthz/only-unhealthy")
        assert r.status_code == 503

    def test_all_checks_aggregate_unhealthy(self):
        """TC-04: /healthz（全部检查）聚合状态 Unhealthy → 503"""
        r = get_raw("/healthz")
        assert r.status_code == 503


# ============================================================
# 2. 默认响应体
# ============================================================

class TestResponseBody:
    """默认 responseWriter 输出状态名称文本"""

    def test_healthy_body(self):
        """TC-05: body == 'Healthy'"""
        r = get("/healthz/only-healthy")
        assert r.text == "Healthy"

    def test_degraded_body(self):
        """TC-06: body == 'Degraded'"""
        r = get("/healthz/only-degraded")
        assert r.text == "Degraded"

    def test_unhealthy_body(self):
        """TC-07: body == 'Unhealthy'"""
        r = get_raw("/healthz/only-unhealthy")
        assert r.text == "Unhealthy"


# ============================================================
# 3. Content-Type
# ============================================================

class TestContentType:
    """默认 responseWriter 设置 Content-Type: text/plain"""

    def test_content_type_healthy(self):
        """TC-08: Healthy 端点 Content-Type 包含 text/plain"""
        r = get("/healthz/only-healthy")
        assert "text/plain" in r.headers.get("Content-Type", "")

    def test_content_type_unhealthy(self):
        """TC-09: Unhealthy 端点 Content-Type 包含 text/plain"""
        r = get_raw("/healthz/only-unhealthy")
        assert "text/plain" in r.headers.get("Content-Type", "")


# ============================================================
# 4. 防缓存响应头（allowCachingResponses=false，默认值）
# ============================================================

class TestCacheHeadersDisabled:
    """allowCachingResponses=false 时注入防缓存头"""

    def test_cache_control_no_store(self):
        """TC-10: Cache-Control 含 no-store"""
        r = get("/healthz/only-healthy")
        cc = r.headers.get("Cache-Control", "")
        assert "no-store" in cc

    def test_cache_control_no_cache(self):
        """TC-11: Cache-Control 含 no-cache"""
        r = get("/healthz/only-healthy")
        cc = r.headers.get("Cache-Control", "")
        assert "no-cache" in cc

    def test_pragma_no_cache(self):
        """TC-12: Pragma: no-cache"""
        r = get("/healthz/only-healthy")
        assert r.headers.get("Pragma", "") == "no-cache"

    def test_expires_epoch(self):
        """TC-13: Expires 为 epoch（Thu, 01 Jan 1970 00:00:00 GMT）"""
        r = get("/healthz/only-healthy")
        assert r.headers.get("Expires", "") == "Thu, 01 Jan 1970 00:00:00 GMT"


# ============================================================
# 5. allowCachingResponses=true 时不注入防缓存头
# ============================================================

class TestCacheHeadersEnabled:
    """allowCachingResponses=true 时不注入防缓存头"""

    def test_no_cache_control_header(self):
        """TC-14: /healthz/cache（allowCachingResponses=true）无 Cache-Control 防缓存头"""
        r = get("/healthz/cache")
        cc = r.headers.get("Cache-Control", "")
        assert "no-store" not in cc and "no-cache" not in cc

    def test_no_pragma_header(self):
        """TC-15: /healthz/cache 无 Pragma: no-cache"""
        r = get("/healthz/cache")
        assert r.headers.get("Pragma", "") != "no-cache"

    def test_status_still_correct(self):
        """TC-16: /healthz/cache 仍返回正确状态码 200"""
        r = get("/healthz/cache")
        assert r.status_code == 200


# ============================================================
# 6. Predicate 名称过滤
# ============================================================

class TestPredicateByName:
    """predicate 按健康检查名称过滤，只运行匹配的检查"""

    def test_only_healthy_check_runs(self):
        """TC-17: /healthz/only-healthy 只运行 healthy → 200"""
        r = get("/healthz/only-healthy")
        assert r.status_code == 200
        assert r.text == "Healthy"

    def test_only_unhealthy_check_runs(self):
        """TC-18: /healthz/only-unhealthy 只运行 unhealthy → 503"""
        r = get_raw("/healthz/only-unhealthy")
        assert r.status_code == 503
        assert r.text == "Unhealthy"

    def test_only_degraded_check_runs(self):
        """TC-19: /healthz/only-degraded 只运行 degraded → 200"""
        r = get("/healthz/only-degraded")
        assert r.status_code == 200
        assert r.text == "Degraded"


# ============================================================
# 7. Predicate Tag 过滤
# ============================================================

class TestPredicateByTag:
    """predicate 按 tag 过滤健康检查"""

    def test_tag_critical_returns_503(self):
        """TC-20: /healthz/tag/critical 按 tag="critical" 过滤 → Unhealthy → 503"""
        r = get_raw("/healthz/tag/critical")
        assert r.status_code == 503
        assert r.text == "Unhealthy"

    def test_tag_slow_returns_200_degraded(self):
        """TC-21: /healthz/tag/slow 按 tag="slow" 过滤 → Degraded → 200"""
        r = get("/healthz/tag/slow")
        assert r.status_code == 200
        assert r.text == "Degraded"


# ============================================================
# 8. 路径精确匹配（不干扰子路径）
# ============================================================

class TestPathIsolation:
    """mapWhen 精确匹配，/healthz 不响应 /healthz/only-healthy 请求"""

    def test_subpath_not_matched_by_parent(self):
        """TC-22: /healthz/only-healthy 不被 /healthz 的 predicate 拦截 → 仍返回 200 Healthy"""
        r = get("/healthz/only-healthy")
        # 若被 /healthz（全部检查）拦截，则返回 503；正确行为应为 200
        assert r.status_code == 200
        assert r.text == "Healthy"

    def test_parent_not_matched_by_subpath(self):
        """TC-23: /healthz 不被子路径 predicate 拦截 → 仍返回 503 Unhealthy"""
        r = get_raw("/healthz")
        assert r.status_code == 503


# ============================================================
# 9. 尾部斜杠容忍
# ============================================================

class TestTrailingSlash:
    """路径比较前裁剪尾部 /，/healthz/only-healthy/ 等价于 /healthz/only-healthy"""

    def test_trailing_slash_healthy(self):
        """TC-24: /healthz/only-healthy/ → 200（尾部斜杠容忍）"""
        r = get("/healthz/only-healthy/")
        assert r.status_code == 200
        assert r.text == "Healthy"

    def test_trailing_slash_unhealthy(self):
        """TC-25: /healthz/only-unhealthy/ → 503"""
        r = get_raw("/healthz/only-unhealthy/")
        assert r.status_code == 503

    def test_trailing_slash_root(self):
        """TC-26: /healthz/ → 503（全部检查，尾部斜杠容忍）"""
        r = get_raw("/healthz/")
        assert r.status_code == 503


# ============================================================
# 10. mapHealthChecks 端点路由
# ============================================================

class TestMapHealthChecks:
    """mapHealthChecks 通过端点路由注册，行为与 useHealthChecks 一致"""

    def test_map_all_checks_503(self):
        """TC-27: /map/healthz（全部检查）→ 503"""
        r = get_raw("/map/healthz")
        assert r.status_code == 503
        assert r.text == "Unhealthy"

    def test_map_only_healthy_200(self):
        """TC-28: /map/healthz/only-healthy → 200"""
        r = get("/map/healthz/only-healthy")
        assert r.status_code == 200
        assert r.text == "Healthy"

    def test_map_content_type(self):
        """TC-29: mapHealthChecks 端点也设置 text/plain"""
        r = get("/map/healthz/only-healthy")
        assert "text/plain" in r.headers.get("Content-Type", "")

    def test_map_cache_headers(self):
        """TC-30: mapHealthChecks 端点默认也注入防缓存头"""
        r = get("/map/healthz/only-healthy")
        assert "no-store" in r.headers.get("Cache-Control", "")
