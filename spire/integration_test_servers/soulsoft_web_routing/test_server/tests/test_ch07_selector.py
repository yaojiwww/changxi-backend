"""
test_ch07_selector.py - 第七章：端点选择与歧义处理 [P0]
测试用例：TC174-187
"""
import pytest
from conftest import get, get_raw, delete


# ============================================================
# 7.1 优先级选择 (TC174-178)
# ============================================================

class TestPrioritySelection:
    """7.1 优先级选择（score 低者优先）"""

    def test_tc174_literal_beats_param(self):
        """TC174: /users/me + /users/{id} → GET /users/me 命中字面量"""
        r = get("/ch07/priority/users/me")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_me"

    def test_tc174_param_when_not_me(self):
        """TC174-variant: GET /users/42 → 命中参数路由"""
        r = get("/ch07/priority/users/42")
        assert r.status_code == 200
        assert r.json()["route"] == "param_id"
        assert r.json()["id"] == "42"

    def test_tc175_constrained_beats_unconstrained_number(self):
        """TC175: /typed/42 → 命中有约束路由（int 约束通过）"""
        r = get("/ch07/priority/typed/42")
        assert r.status_code == 200
        assert r.json()["route"] == "constrained_int"

    def test_tc175_unconstrained_for_string(self):
        """TC175: /typed/abc → 约束失败，命中无约束路由"""
        r = get("/ch07/priority/typed/abc")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"

    def test_tc176_literal_api_users_beats_catchall(self):
        """TC176: /api/users → 字面量优先于 catch-all"""
        r = get("/ch07/priority/api/users")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_api_users"

    def test_tc176_catchall_for_others(self):
        """TC176-variant: /other/path → catch-all 命中"""
        r = get("/ch07/priority/other/path")
        assert r.status_code == 200
        assert r.json()["route"] == "catchall"

    def test_tc177_literal_abc_beats_param_and_catchall(self):
        """TC177: /a/b/c → 全字面量路由优先"""
        r = get("/ch07/priority/abc/a/b/c")
        assert r.status_code == 200
        assert r.json()["route"] == "abc_literal"

    def test_tc177_param_abc_beats_catchall(self):
        """TC177: /a/x/c → 参数路由优先于 catch-all"""
        r = get("/ch07/priority/abc/a/x/c")
        assert r.status_code == 200
        assert r.json()["route"] == "abc_param"

    def test_tc178_mid_int_beats_mid_name(self):
        """TC178: /a/42/b → int 约束路由优先"""
        r = get("/ch07/priority/mid/42/b")
        assert r.status_code == 200
        assert r.json()["route"] == "mid_int"

    def test_tc178_mid_name_for_string(self):
        """TC178: /a/hello/b → 无约束路由命中"""
        r = get("/ch07/priority/mid/hello/b")
        assert r.status_code == 200
        assert r.json()["route"] == "mid_name"


# ============================================================
# 7.2 歧义匹配异常 (TC179-181)
# ============================================================

class TestAmbiguousMatch:
    """7.2 歧义匹配异常"""

    def test_tc179_ambiguous_two_params(self):
        """TC179: /users/{id} + /users/{name} → AmbiguousMatchException (500)"""
        r = get_raw("/ch07/ambig/tc179/42")
        assert r.status_code >= 500, (
            f"TC179: 期望 5xx（AmbiguousMatchException），实际 {r.status_code}"
        )

    def test_tc180_ambiguous_two_params_string(self):
        """TC180: /a/{x} + /a/{y} → AmbiguousMatchException"""
        r = get_raw("/ch07/ambig/tc180/hello")
        assert r.status_code >= 500

    def test_tc181_ambiguous_three_params(self):
        """TC181: 3 个相同结构路由 → AmbiguousMatchException"""
        r = get_raw("/ch07/ambig/tc181/v")
        assert r.status_code >= 500

    def test_tc188_constraint_resolves_ambiguity_int(self):
        """TC188: {id:int} + {name} 同路径 → 数字命中有约束路由，歧义消除"""
        r = get("/ch07/ambig/resolved/42")
        assert r.status_code == 200
        data = r.json()
        assert data["route"] == "int"
        assert data["id"] == "42"

    def test_tc188_constraint_resolves_ambiguity_string(self):
        """TC188-variant: {id:int} + {name} → 字符串约束失败，命中无约束路由"""
        r = get("/ch07/ambig/resolved/hello")
        assert r.status_code == 200
        data = r.json()
        assert data["route"] == "name"
        assert data["name"] == "hello"


# ============================================================
# 7.3 无匹配 (TC182-185)
# ============================================================

class TestNoMatch:
    """7.3 无匹配"""

    def test_tc182_different_path(self):
        """TC182: /users 路由 + GET /posts → 404"""
        r = get("/ch07/nomatch/posts")
        assert r.status_code == 404

    def test_tc183_constraint_all_fail(self):
        """TC183: /constrained/{id:int} + GET /constrained/abc → 404"""
        r = get("/ch07/nomatch/constrained/abc")
        assert r.status_code == 404

    def test_tc184_wrong_method(self):
        """TC184: GET /method 路由 + DELETE 请求 → 405"""
        r = delete("/ch07/nomatch/method")
        assert r.status_code == 405

    def test_tc185_required_param_missing(self):
        """TC185: /required/{id} + GET /required → 404（参数必须提供）"""
        r = get("/ch07/nomatch/required")
        assert r.status_code == 404


# ============================================================
# 7.4 单候选优化路径 (TC186-187)
# ============================================================

class TestSingleCandidate:
    """7.4 单候选优化路径"""

    def test_tc186_single_match(self):
        """TC186: 单路由命中 → 走快速路径，正常返回"""
        r = get("/ch07/single/match")
        assert r.status_code == 200

    def test_tc187_single_constraint_fail(self):
        """TC187: 单路由约束失败 → 404"""
        r = get("/ch07/single/constrained/abc")
        assert r.status_code == 404

    def test_tc187_single_constraint_pass(self):
        """TC187-variant: 单路由约束通过 → 200"""
        r = get("/ch07/single/constrained/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"
