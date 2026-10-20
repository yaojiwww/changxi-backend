"""
test_ch01_patterns.py - 第一章：路由模式解析 RoutePatternParser [P1]
测试用例：TC1-47

说明：
  - 有效模式通过注册的 HTTP 路由验证匹配行为
  - 无效模式（RoutePatternException）通过 GET /meta/parse?pattern=xxx 验证 ok=false
"""
import urllib.parse
import pytest
from conftest import get


def meta_parse(pattern: str) -> dict:
    """调用 /meta/parse 端点解析路由模式"""
    encoded = urllib.parse.quote(pattern, safe="")
    r = get(f"/meta/parse?pattern={encoded}")
    assert r.status_code in (200, 400)
    return r.json()


# ============================================================
# 1.1 前缀修剪 (TC1-5)
# ============================================================

class TestPrefixTrimming:
    """1.1 前缀修剪"""

    def test_tc1_slash_prefix_route(self):
        """TC1: /users → 正常路径，注册为 /ch01/prefix/users"""
        r = get("/ch01/prefix/users")
        assert r.status_code == 200

    def test_tc2_no_slash_prefix_meta(self):
        """TC2: users（无斜杠）→ meta/parse 验证 segments=1"""
        d = meta_parse("users")
        assert d["ok"] is True
        assert d["segments"] == 1

    def test_tc3_tilde_slash_prefix_meta(self):
        """TC3: ~/users → meta/parse 验证 segments=1（移除 ~/）"""
        d = meta_parse("~/users")
        assert d["ok"] is True
        assert d["segments"] == 1

    def test_tc4_tilde_no_slash_exception(self):
        """TC4: ~users → RoutePatternException（ok=false）"""
        d = meta_parse("~users")
        assert d["ok"] is False

    def test_tc5_tilde_slash_root(self):
        """TC5: ~/ → 根路径（segments=0）"""
        d = meta_parse("~/")
        assert d["ok"] is True
        assert d["segments"] == 0


# ============================================================
# 1.2 字面量路由 (TC6-9)
# ============================================================

class TestLiteralRoutes:
    """1.2 字面量路由"""

    def test_tc6_root_path_meta(self):
        """TC6: / → 0 段（meta 验证）"""
        d = meta_parse("/")
        assert d["ok"] is True
        assert d["segments"] == 0

    def test_tc7_single_segment_meta(self):
        """TC7: /users → 1 个字面量段"""
        d = meta_parse("/users")
        assert d["ok"] is True
        assert d["segments"] == 1

    def test_tc7_route_matchable(self):
        """TC7 行为: /ch01/literal/users → 命中"""
        r = get("/ch01/literal/users")
        assert r.status_code == 200

    def test_tc8_three_segments_meta(self):
        """TC8: /api/v1/users → 3 个字面量段"""
        d = meta_parse("/api/v1/users")
        assert d["ok"] is True
        assert d["segments"] == 3

    def test_tc8_route_matchable(self):
        """TC8 行为: /ch01/literal/api/v1/users → 命中"""
        r = get("/ch01/literal/api/v1/users")
        assert r.status_code == 200

    def test_tc9_five_segments_meta(self):
        """TC9: /a/b/c/d/e → 5 个字面量段"""
        d = meta_parse("/a/b/c/d/e")
        assert d["ok"] is True
        assert d["segments"] == 5

    def test_tc9_route_matchable(self):
        """TC9 行为: /ch01/literal/a/b/c/d/e → 命中"""
        r = get("/ch01/literal/a/b/c/d/e")
        assert r.status_code == 200


# ============================================================
# 1.3 参数路由 (TC10-17)
# ============================================================

class TestParamRoutes:
    """1.3 参数路由"""

    def test_tc10_simple_param_meta(self):
        """TC10: /{id} → name=id, 非 optional, 非 catchAll"""
        d = meta_parse("/{id}")
        assert d["ok"] is True
        assert d["params"] == 1
        assert d["param_names"] == ["id"]
        assert d["param_optional"] == [False]
        assert d["param_catch_all"] == [False]

    def test_tc10_route_matchable(self):
        """TC10 行为: /ch01/param/42 → id='42'"""
        r = get("/ch01/param/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc11_two_params_meta(self):
        """TC11: /{ctrl}/{action} → 2 参数，顺序正确"""
        d = meta_parse("/{ctrl}/{action}")
        assert d["ok"] is True
        assert d["params"] == 2
        assert d["param_names"] == ["ctrl", "action"]

    def test_tc11_route_matchable(self):
        """TC11 行为: /ch01/param/Home/Index → ctrl='Home', action='Index'"""
        r = get("/ch01/param/Home/Index")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "Home"
        assert data["action"] == "Index"

    def test_tc12_default_value_meta(self):
        """TC12: /{id=42} → default='42'"""
        d = meta_parse("/{id=42}")
        assert d["ok"] is True
        assert d["param_defaults"].get("id") == "42"

    def test_tc12_route_matchable(self):
        """TC12 行为: /ch01/default/99 → id='99'（覆盖默认值）"""
        r = get("/ch01/default/99")
        assert r.status_code == 200
        assert r.json()["id"] == "99"

    def test_tc13_optional_param_meta(self):
        """TC13: /{id?} → isOptional=true"""
        d = meta_parse("/{id?}")
        assert d["ok"] is True
        assert d["param_optional"] == [True]

    def test_tc13_route_matchable(self):
        """TC13 行为: /ch01/param/opt/42 → id='42'"""
        r = get("/ch01/param/opt/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc14_double_star_catchall_meta(self):
        """TC14: /{**path} → isCatchAll=true"""
        d = meta_parse("/{**path}")
        assert d["ok"] is True
        assert d["param_catch_all"] == [True]

    def test_tc14_route_matchable(self):
        """TC14 行为: /ch01/param/dstar/a/b/c → path='a/b/c'"""
        r = get("/ch01/param/dstar/a/b/c")
        assert r.status_code == 200
        assert r.json()["path"] == "a/b/c"

    def test_tc15_single_star_catchall_meta(self):
        """TC15: /{*path} → isCatchAll=true"""
        d = meta_parse("/{*path}")
        assert d["ok"] is True
        assert d["param_catch_all"] == [True]

    def test_tc15_route_matchable(self):
        """TC15 行为: /ch01/param/sstar/x/y → path='x/y'"""
        r = get("/ch01/param/sstar/x/y")
        assert r.status_code == 200
        assert r.json()["path"] == "x/y"

    def test_tc16_optional_with_default_exception(self):
        """TC16: /{id=0?} → RoutePatternException"""
        d = meta_parse("/{id=0?}")
        assert d["ok"] is False

    def test_tc17_catchall_optional_exception(self):
        """TC17: /{**path?} → RoutePatternException"""
        d = meta_parse("/{**path?}")
        assert d["ok"] is False


# ============================================================
# 1.4 内联约束 (TC18-25)
# ============================================================

class TestConstraintRoutes:
    """1.4 内联约束"""

    def test_tc18_int_constraint_meta(self):
        """TC18: /{id:int} → 解析成功，params=1"""
        d = meta_parse("/{id:int}")
        assert d["ok"] is True
        assert d["params"] == 1

    def test_tc18_route_matchable(self):
        """TC18 行为: /ch01/constraint/int/42 → 命中"""
        r = get("/ch01/constraint/int/42")
        assert r.status_code == 200

    def test_tc19_bool_constraint_meta(self):
        """TC19: /{flag:bool} → 解析成功"""
        d = meta_parse("/{flag:bool}")
        assert d["ok"] is True

    def test_tc20_float_constraint_meta(self):
        """TC20: /{v:float} → 解析成功"""
        d = meta_parse("/{v:float}")
        assert d["ok"] is True

    def test_tc21_regex_constraint_meta(self):
        """TC21: /{s:regex([a-z]+)} → 解析成功"""
        d = meta_parse("/{s:regex([a-z]+)}")
        assert d["ok"] is True

    def test_tc22_multi_constraints_meta(self):
        """TC22: /{id:int:min(1)} → 解析成功（多约束）"""
        d = meta_parse("/{id:int:min(1)}")
        assert d["ok"] is True

    def test_tc23_constraint_with_default_meta(self):
        """TC23: /{id:int=5} → IntRouteConstraint + default='5'"""
        d = meta_parse("/{id:int=5}")
        assert d["ok"] is True
        assert d["param_defaults"].get("id") == "5"

    def test_tc23_route_matchable(self):
        """TC23 行为: /ch01/constraint/intdef/7 → id='7'"""
        r = get("/ch01/constraint/intdef/7")
        assert r.status_code == 200

    def test_tc24_regex_before_int_meta(self):
        """TC24: /{id:regex([a-z]+):int} → 解析成功（多约束，regex 在前）"""
        d = meta_parse("/{id:regex([a-z]+):int}")
        assert d["ok"] is True

    def test_tc25_unknown_constraint_meta(self):
        """TC25: /{id:unknown} → 无异常（约束名不在解析时验证）"""
        d = meta_parse("/{id:unknown}")
        assert d["ok"] is True

    def test_tc25_route_matchable(self):
        """TC25 修正: RoutePatternFactory.parse 成功，但注册未知约束路由会在 DFA 构建时失败
        （与 ASP.NET Core 一致）。验证 parse 层返回 ok=True 已足够。"""
        d = meta_parse("/{id:unknown}")
        assert d["ok"] is True  # parse 层不验证约束名


# ============================================================
# 1.5 复合段 (TC26-30)
# ============================================================

class TestComplexSegments:
    """1.5 复合段"""

    def test_tc26_prefix_param_meta(self):
        """TC26: /v{version} → 解析成功，1 参数"""
        d = meta_parse("/v{version}")
        assert d["ok"] is True
        assert d["params"] == 1

    def test_tc26_route_matchable(self):
        """TC26 行为: /ch01/complex/v2 → version='2'"""
        r = get("/ch01/complex/v2")
        assert r.status_code == 200
        assert r.json()["version"] == "2"

    def test_tc27_param_suffix_meta(self):
        """TC27: /{name}.html → 解析成功"""
        d = meta_parse("/{name}.html")
        assert d["ok"] is True

    def test_tc27_route_matchable(self):
        """TC27 行为: /ch01/suffix/readme.html → name='readme'"""
        r = get("/ch01/suffix/readme.html")
        assert r.status_code == 200
        assert r.json()["name"] == "readme"

    def test_tc28_two_params_sep_meta(self):
        """TC28: /{a}-{b} → 解析成功，2 参数"""
        d = meta_parse("/{a}-{b}")
        assert d["ok"] is True
        assert d["params"] == 2

    def test_tc28_route_matchable(self):
        """TC28 行为: /ch01/complex/foo-bar → a='foo', b='bar'"""
        r = get("/ch01/complex/foo-bar")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "foo"
        assert data["b"] == "bar"

    def test_tc29_two_params_dot_meta(self):
        """TC29: /{file}.{ext} → 解析成功，2 参数"""
        d = meta_parse("/{file}.{ext}")
        assert d["ok"] is True
        assert d["params"] == 2

    def test_tc29_route_matchable(self):
        """TC29 行为: /ch01/complex/readme.md → file='readme', ext='md'"""
        r = get("/ch01/complex/readme.md")
        assert r.status_code == 200
        data = r.json()
        assert data["file"] == "readme"
        assert data["ext"] == "md"

    def test_tc30_param_wrapped_meta(self):
        """TC30: /prefix-{id}-suffix → 解析成功"""
        d = meta_parse("/prefix-{id}-suffix")
        assert d["ok"] is True

    def test_tc30_route_matchable(self):
        """TC30 行为: /ch01/wrap/prefix-hello-suffix → id='hello'"""
        r = get("/ch01/wrap/prefix-hello-suffix")
        assert r.status_code == 200
        assert r.json()["id"] == "hello"


# ============================================================
# 1.6 可选参数位置约束 (TC31-35)
# ============================================================

class TestOptionalParamPosition:
    """1.6 可选参数位置约束"""

    def test_tc31_valid_optional_at_end_meta(self):
        """TC31: /{controller}/{action?} → 合法"""
        d = meta_parse("/{controller}/{action?}")
        assert d["ok"] is True

    def test_tc31_route_matchable(self):
        """TC31 行为: /ch01/optpos/Home → controller='Home'"""
        r = get("/ch01/optpos/Home")
        assert r.status_code == 200

    def test_tc32_optional_not_last_exception(self):
        """TC32: /{action?}/{controller} → 合法模式，ASP.NET Core 不抛异常（ok=True）"""
        d = meta_parse("/{action?}/{controller}")
        assert d["ok"] is True

    def test_tc33_valid_dot_optional_meta(self):
        """TC33: /path.{ext?} → ASP.NET Core 拒绝（前缀 'path.' 非单独的 '.'）"""
        d = meta_parse("/path.{ext?}")
        assert d["ok"] is False

    def test_tc33_route_matchable(self):
        """TC33 修正: /{name}.{ext?} 是合法的复合段可选模式"""
        d = meta_parse("/{name}.{ext?}")
        assert d["ok"] is True

    def test_tc34_dash_optional_exception(self):
        """TC34: /path-{ext?} → RoutePatternException（可选参数前只能是 .）"""
        d = meta_parse("/path-{ext?}")
        assert d["ok"] is False

    def test_tc35_optional_not_terminal_exception(self):
        """TC35: /{a?}{b} → RoutePatternException"""
        d = meta_parse("/{a?}{b}")
        assert d["ok"] is False


# ============================================================
# 1.7 catch-all 位置约束 (TC36-39)
# ============================================================

class TestCatchAllPosition:
    """1.7 catch-all 位置约束"""

    def test_tc36_valid_catchall_at_end_meta(self):
        """TC36: /files/{**rest} → 合法"""
        d = meta_parse("/files/{**rest}")
        assert d["ok"] is True

    def test_tc36_route_matchable(self):
        """TC36 行为: /ch01/capos/files/a/b → rest='a/b'"""
        r = get("/ch01/capos/files/a/b")
        assert r.status_code == 200
        assert r.json()["rest"] == "a/b"

    def test_tc37_catchall_not_last_exception(self):
        """TC37: /{**rest}/after → RoutePatternException"""
        d = meta_parse("/{**rest}/after")
        assert d["ok"] is False

    def test_tc38_catchall_then_param_exception(self):
        """TC38: /{**rest}/{id} → RoutePatternException"""
        d = meta_parse("/{**rest}/{id}")
        assert d["ok"] is False

    def test_tc39_root_catchall_meta(self):
        """TC39: /{**rest} → 合法，根级 catch-all"""
        d = meta_parse("/{**rest}")
        assert d["ok"] is True

    def test_tc39_route_matchable(self):
        """TC39 行为: /ch01/capos/any/deep → rest='any/deep'"""
        r = get("/ch01/capos/any/deep")
        assert r.status_code == 200


# ============================================================
# 1.8 段内规则约束 (TC40-42)
# ============================================================

class TestSegmentRules:
    """1.8 段内规则约束"""

    def test_tc40_two_params_no_sep_exception(self):
        """TC40: /{a}{b} → RoutePatternException（连续参数无分隔符）"""
        d = meta_parse("/{a}{b}")
        assert d["ok"] is False

    def test_tc41_catchall_in_complex_segment_exception(self):
        """TC41: /{**path}/x → RoutePatternException"""
        d = meta_parse("/{**path}/x")
        assert d["ok"] is False

    def test_tc42_duplicate_param_name_exception(self):
        """TC42: /{id}/{id} → RoutePatternException（重复参数名）"""
        d = meta_parse("/{id}/{id}")
        assert d["ok"] is False


# ============================================================
# 1.9 花括号转义 (TC43-47)
# ============================================================

class TestBraceEscape:
    """1.9 花括号转义"""

    def test_tc43_escaped_braces_literal(self):
        """TC43: /{{literal}} → 字面量 {literal}，params=0"""
        d = meta_parse("/{{literal}}")
        assert d["ok"] is True
        assert d["params"] == 0  # 转义后是字面量，非参数

    def test_tc44_escaped_id_literal(self):
        """TC44: /{{id}} → 字面量 {id}（非参数），params=0"""
        d = meta_parse("/{{id}}")
        assert d["ok"] is True
        assert d["params"] == 0

    def test_tc45_unclosed_brace_exception(self):
        """TC45: /{id → RoutePatternException（未闭合花括号）"""
        d = meta_parse("/{id")
        assert d["ok"] is False

    def test_tc46_escaped_open_then_close_exception(self):
        """TC46: /{{} → RoutePatternException"""
        d = meta_parse("/{{}")
        assert d["ok"] is False

    def test_tc47_empty_param_name_exception(self):
        """TC47: /{} → RoutePatternException（空参数名）"""
        d = meta_parse("/{}")
        assert d["ok"] is False
