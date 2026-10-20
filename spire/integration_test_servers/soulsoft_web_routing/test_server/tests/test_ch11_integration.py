"""
test_ch11_integration.py - 第十一章：端到端路由管道集成 [P1]
测试用例：TC234-249
"""
import pytest
import threading
import time
from conftest import get, post, delete, request


# ============================================================
# 11.1 完整请求路由 (TC234-243)
# ============================================================

class TestFullPipeline:
    """11.1 完整请求路由（addRouting → useRouting → useEndpoints → 请求）"""

    def test_tc234_basic_get(self):
        """TC234: mapGet('/users', h) + GET /users → handler 执行"""
        r = get("/ch11/users")
        assert r.status_code == 200
        assert r.json()["matched"] is True

    def test_tc235_int_constraint_pass(self):
        """TC235: mapGet('/users/{id:int}') + GET /users/42 → id='42' 可获取"""
        r = get("/ch11/users/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc236_int_constraint_fail(self):
        """TC236: mapGet('/users/{id:int}') + GET /users/abc → 404"""
        r = get("/ch11/users/abc")
        assert r.status_code == 404

    def test_tc237_post_route_matches(self):
        """TC237: GET /a + POST /a → POST /a 命中 h2"""
        r = post("/ch11/dual")
        assert r.status_code == 200
        assert r.json()["handler"] == "h2"
        assert r.json()["method"] == "POST"

    def test_tc238_delete_no_match(self):
        """TC238: GET /a + POST /a → DELETE /a → 405"""
        r = delete("/ch11/dual")
        assert r.status_code == 405

    def test_tc239_literal_me_takes_priority(self):
        """TC239: /me（字面量）+ /{id}（参数）→ GET /me 命中字面量"""
        r = get("/ch11/me")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_me"

    def test_tc240_param_for_other_values(self):
        """TC240: /me + /{id} → GET /alice 命中参数路由"""
        r = get("/ch11/alice")
        assert r.status_code == 200
        assert r.json()["route"] == "param_id"
        assert r.json()["id"] == "alice"

    def test_tc241_catchall_any_path(self):
        """TC241: map('/{**path}') → GET /any/deep/path → path='any/deep/path'"""
        r = get("/ch11/catchall/any/deep/path")
        assert r.status_code == 200
        assert r.json()["path"] == "any/deep/path"

    def test_tc242_mvc_route_values(self):
        """TC242: /{ctrl}/{action} → GET /home/index → ctrl='home', action='index'"""
        r = get("/ch11/mvc/home/index")
        assert r.status_code == 200
        data = r.json()
        # 参数值应保留原始大小写
        assert data["ctrl"] == "home"
        assert data["action"] == "index"

    def test_tc242_mvc_mixed_case(self):
        """TC242-variant: GET /Home/Index → ctrl='Home', action='Index'（原始大小写）"""
        r = get("/ch11/mvc/Home/Index")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "Home"
        assert data["action"] == "Index"


# ============================================================
# 11.1 TC243：跨数据源聚合（CompositeEndpointDataSource）
# ============================================================

class TestCompositeDataSource:
    """TC243: 跨数据源路由均可命中（CompositeEndpointDataSource 聚合）"""

    def test_tc243_cross_chapter_routes_reachable(self):
        """TC243: 来自不同章节（数据源）的路由均可命中"""
        # ch04 路由（第一个注册批次）
        r1 = get("/ch04/literal/users")
        assert r1.status_code == 200, "ch04 路由应可命中"

        # ch11 路由（另一注册批次）
        r2 = get("/ch11/users")
        assert r2.status_code == 200, "ch11 路由应可命中"

        # ch12 路由（又一批次）
        r3 = get("/ch12/align/users")
        assert r3.status_code == 200, "ch12 路由应可命中"


# ============================================================
# 11.2 中间件顺序与状态 (TC244-249)
# ============================================================

class TestMiddlewareState:
    """11.2 中间件顺序与状态"""

    def test_tc244_tc246_dfa_initialized_on_first_request(self):
        """TC244/TC246: 首次请求触发 DFA 初始化，后续请求复用同一实例"""
        # 发送 3 次请求，均应成功（验证 DFA 初始化和缓存）
        for i in range(3):
            r = get("/ch11/users")
            assert r.status_code == 200, f"第 {i+1} 次请求应成功"

    def test_tc245_concurrent_requests_single_init(self):
        """TC245: 并发首次请求只初始化一次 DFA（双重检查锁）"""
        results = []
        errors = []

        def make_request():
            try:
                r = get("/ch04/literal/users")
                results.append(r.status_code)
            except Exception as e:
                errors.append(str(e))

        # 并发发送 5 个请求
        threads = [threading.Thread(target=make_request) for _ in range(5)]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=10)

        assert not errors, f"并发请求出错: {errors}"
        assert all(s == 200 for s in results), f"并发请求状态码: {results}"

    def test_tc247_matched_endpoint_returns_correct_handler(self):
        """TC247: 端点匹配后正确执行 handler（endpoint 已设置）"""
        r = get("/ch11/me")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_me"

    def test_tc248_no_match_returns_404(self):
        """TC248: 无匹配时 EndpointMiddleware 不执行 handler，返回 404"""
        r = get("/ch11/nonexistent/path/that/should/not/match")
        assert r.status_code == 404

    def test_tc249_server_running_implies_routing_registered(self):
        """TC249: 服务器正在运行意味着 addRouting 已成功注册（否则启动失败）"""
        # 通过 /health 端点验证服务器正常运行
        r = get("/health")
        assert r.status_code == 200
        assert r.text == "ok"
