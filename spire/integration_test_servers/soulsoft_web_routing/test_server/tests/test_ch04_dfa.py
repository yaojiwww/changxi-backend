"""
test_ch04_dfa.py - 第四章：DFA 匹配器核心 [P0]
测试用例：TC76-127
"""
import pytest
from conftest import get, request


# ============================================================
# 4.1 字面量精确匹配 (TC76-82)
# ============================================================

class TestLiteralMatching:
    """4.1 字面量精确匹配"""

    def test_tc76_exact_match(self):
        """TC76: GET /users → 命中"""
        r = get("/ch04/literal/users")
        assert r.status_code == 200
        assert r.json()["matched"] is True

    def test_tc79_no_match_different_path(self):
        """TC79: GET /posts → 无匹配（路由只有 /users）"""
        r = get("/ch04/literal/posts")
        assert r.status_code == 404

    def test_tc80_multi_segment_exact(self):
        """TC80: GET /api/v1/users → 命中"""
        r = get("/ch04/literal/api/v1/users")
        assert r.status_code == 200

    def test_tc81_multi_segment_no_match(self):
        """TC81: GET /api/v2/users → 无匹配"""
        r = get("/ch04/literal/api/v2/users")
        assert r.status_code == 404

    def test_tc82_trailing_slash_behavior(self):
        """TC82: GET /users/ → 尾随斜杠与无斜杠行为一致（均返回 200）

        C# ASP.NET Core 验证确认：默认配置下 /users/ 与 /users 返回相同结果（200），
        无自动 trailing slash 重定向或 404 处理。原期望 404 有误，修正为 200。
        """
        r = get("/ch04/literal/users/")
        assert r.status_code == 200


# ============================================================
# 4.2 路由参数值大小写保留 (TC83-85)
# ============================================================

class TestParamCaptureLowercase:
    """4.2 路由参数值捕获（URL 规范：路径及参数均为小写）"""

    def test_tc83_param_lowercase(self):
        """TC83: /hello → id='hello'"""
        r = get("/ch04/paramcase/hello")
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == "hello"

    def test_tc84_param_lowercase_word(self):
        """TC84: /world → id='world'"""
        r = get("/ch04/paramcase/world")
        assert r.status_code == 200
        assert r.json()["id"] == "world"

    def test_tc85_multi_param_lowercase(self):
        """TC85: /home/index → ctrl='home', action='index'"""
        r = get("/ch04/paramcase/home/index")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "home"
        assert data["action"] == "index"


# ============================================================
# 4.3 普通参数捕获 (TC86-93)
# ============================================================

class TestParamCapture:
    """4.3 普通参数捕获"""

    def test_tc86_single_param(self):
        """TC86: /users/42 → id='42'"""
        r = get("/ch04/param/users/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc87_param_with_hyphen(self):
        """TC87: /users/abc-def → id='abc-def'"""
        r = get("/ch04/param/users/abc-def")
        assert r.status_code == 200
        assert r.json()["id"] == "abc-def"

    def test_tc88_three_params(self):
        """TC88: /x/y/z → a='x', b='y', c='z'"""
        r = get("/ch04/param/x/y/z")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "x"
        assert data["b"] == "y"
        assert data["c"] == "z"

    def test_tc89_complex_prefix_param(self):
        """TC89: /v2/api → version='2'（复合段 v{version}）"""
        r = get("/ch04/complex/v2/api")
        assert r.status_code == 200
        assert r.json()["version"] == "2"

    def test_tc90_complex_suffix_param(self):
        """TC90: /readme.html → file='readme'"""
        r = get("/ch04/suffix/readme.html")
        assert r.status_code == 200
        assert r.json()["file"] == "readme"

    def test_tc91_complex_separator_params(self):
        """TC91: /foo-bar → a='foo', b='bar'"""
        r = get("/ch04/complex/foo-bar")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "foo"
        assert data["b"] == "bar"

    def test_tc92_complex_surrounded_param(self):
        """TC92: /prefix-hello-suffix → id='hello'"""
        r = get("/ch04/wrap/prefix-hello-suffix")
        assert r.status_code == 200
        assert r.json()["id"] == "hello"

    def test_tc93_complex_dot_params(self):
        """TC93: /readme.md → file='readme', ext='md'"""
        r = get("/ch04/complex/readme.md")
        assert r.status_code == 200
        data = r.json()
        assert data["file"] == "readme"
        assert data["ext"] == "md"


# ============================================================
# 4.4 默认值行为 (TC94-97)
# ============================================================

class TestDefaultValues:
    """4.4 默认值行为"""

    def test_tc94_default_overridden(self):
        """TC94: /99 → id='99'（提供值覆盖默认值 1）"""
        r = get("/ch04/default1/99")
        assert r.status_code == 200
        assert r.json()["id"] == "99"

    def test_tc95_default_used(self):
        """TC95: / → id='1'（省略时使用默认值）"""
        r = get("/ch04/default1/")
        # 根路径命中默认值路由
        assert r.status_code == 200
        assert r.json()["id"] == "1"

    def test_tc96_two_defaults_first_provided(self):
        """TC96: /About → ctrl='About', action='Index'"""
        r = get("/ch04/default2/About")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "About"
        assert data["action"] == "Index"

    def test_tc97_two_defaults_all_omitted(self):
        """TC97: / → ctrl='Home', action='Index'"""
        r = get("/ch04/default2/")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "Home"
        assert data["action"] == "Index"


# ============================================================
# 4.5 可选参数行为 (TC98-103)
# ============================================================

class TestOptionalParams:
    """4.5 可选参数行为"""

    def test_tc98_optional_provided(self):
        """TC98: /users/42 → id='42'"""
        r = get("/ch04/optional/users/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc99_optional_omitted(self):
        """TC99: /users → id=null（可选参数不提供）"""
        r = get("/ch04/optional/users")
        assert r.status_code == 200
        assert r.json()["id"] is None

    def test_tc100_second_optional_omitted(self):
        """TC100: /home → ctrl='home', action=null"""
        r = get("/ch04/optional/home")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "home"
        assert data["action"] is None

    def test_tc101_second_optional_provided(self):
        """TC101: /home/index → ctrl='home', action='index'"""
        r = get("/ch04/optional/home/index")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "home"
        assert data["action"] == "index"

    def test_tc102_optional_ext_omitted(self):
        """TC102: /doc/readme → name='readme', ext=null"""
        r = get("/ch04/optional/doc/readme")
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "readme"
        assert data["ext"] is None

    def test_tc103_optional_ext_provided(self):
        """TC103: /doc/readme.md → name='readme', ext='md'"""
        r = get("/ch04/optional/doc/readme.md")
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "readme"
        assert data["ext"] == "md"


# ============================================================
# 4.6 Catch-all 参数 (TC104-110)
# ============================================================

class TestCatchAll:
    """4.6 Catch-all 参数"""

    def test_tc104_catchall_single_segment(self):
        """TC104: /files/a → path='a'"""
        r = get("/ch04/catchall/files/a")
        assert r.status_code == 200
        assert r.json()["path"] == "a"

    def test_tc105_catchall_multi_segment(self):
        """TC105: /files/a/b/c → path='a/b/c'"""
        r = get("/ch04/catchall/files/a/b/c")
        assert r.status_code == 200
        assert r.json()["path"] == "a/b/c"

    def test_tc106_catchall_empty(self):
        """TC106: /files → path='' (catch-all 为空)"""
        r = get("/ch04/catchall/files")
        assert r.status_code == 200
        assert r.json()["path"] == ""

    def test_tc107_root_catchall(self):
        """TC107: /any/deep/path → path='any/deep/path'"""
        r = get("/ch04/catchall/any/deep/path")
        assert r.status_code == 200
        assert r.json()["path"] == "any/deep/path"

    def test_tc108_root_catchall_empty(self):
        """TC108: / → path=''"""
        r = get("/ch04/catchall/")
        assert r.status_code == 200
        assert r.json()["path"] == ""

    def test_tc109_single_star_catchall(self):
        """TC109: /files/a/b → path='a/b'（单星 catch-all）"""
        r = get("/ch04/catchall/star/files/a/b")
        assert r.status_code == 200
        assert r.json()["path"] == "a/b"

    def test_tc110_catchall_ignores_query_string(self):
        """TC110: /base/x/y?q=1 → path='x/y'（query string 不计入路径）"""
        r = get("/ch04/catchall/files/x/y", params={"q": "1"})
        assert r.status_code == 200
        assert r.json()["path"] == "x/y"


# ============================================================
# 4.7 约束验证与候选排除 (TC111-127)
# ============================================================

class TestConstraintValidation:
    """4.7 约束验证与候选排除"""

    def test_tc111_int_constraint_valid(self):
        """TC111: /users/42 → 命中（整数合法）"""
        r = get("/ch04/constraint/users/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc112_int_constraint_invalid(self):
        """TC112: /users/abc → 约束失败，无匹配"""
        r = get("/ch04/constraint/users/abc")
        assert r.status_code == 404

    def test_tc113_int_constraint_negative(self):
        """TC113: /users/-1 → 命中（负整数合法）"""
        r = get("/ch04/constraint/users/-1")
        assert r.status_code == 200
        assert r.json()["id"] == "-1"

    def test_tc114_int_constraint_overflow(self):
        """TC114: /users/9999999999999999999 → 溢出，约束失败"""
        r = get("/ch04/constraint/users/9999999999999999999")
        assert r.status_code == 404

    def test_tc115_bool_constraint_true(self):
        """TC115: /true → 命中"""
        r = get("/ch04/constraint/bool/true")
        assert r.status_code == 200

    def test_tc116_bool_constraint_false(self):
        """TC116: /false → 命中"""
        r = get("/ch04/constraint/bool/false")
        assert r.status_code == 200

    def test_tc118_bool_constraint_invalid(self):
        """TC118: /yes → 约束失败"""
        r = get("/ch04/constraint/bool/yes")
        assert r.status_code == 404

    def test_tc119_float_constraint_valid(self):
        """TC119: /rate/3.14 → 命中"""
        r = get("/ch04/constraint/rate/3.14")
        assert r.status_code == 200
        assert r.json()["v"] == "3.14"

    def test_tc120_float_constraint_negative(self):
        """TC120: /rate/-0.5 → 命中"""
        r = get("/ch04/constraint/rate/-0.5")
        assert r.status_code == 200

    def test_tc121_float_constraint_invalid(self):
        """TC121: /rate/abc → 约束失败"""
        r = get("/ch04/constraint/rate/abc")
        assert r.status_code == 404

    def test_tc122_regex_alpha_valid(self):
        """TC122: /slug/hello → 命中"""
        r = get("/ch04/constraint/slug/hello")
        assert r.status_code == 200

    def test_tc124_regex_digits_valid(self):
        """TC124: /digits/123 → 命中"""
        r = get("/ch04/constraint/digits/123")
        assert r.status_code == 200

    def test_tc125_regex_digits_invalid(self):
        """TC125: /digits/abc → 约束失败"""
        r = get("/ch04/constraint/digits/abc")
        assert r.status_code == 404

    def test_tc126_constrained_takes_priority(self):
        """TC126: /u/42 → 命中有约束路由（约束参数优先）"""
        r = get("/ch04/fallback/42")
        assert r.status_code == 200
        assert r.json()["route"] == "constrained"

    def test_tc127_fallback_to_unconstrained(self):
        """TC127: /u/abc → 命中无约束路由（约束失败回退）"""
        r = get("/ch04/fallback/abc")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"
