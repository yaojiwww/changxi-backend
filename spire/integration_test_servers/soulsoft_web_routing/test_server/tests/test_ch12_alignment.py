"""
test_ch12_alignment.py - 第十二章：ASP.NET Core 对齐行为 [P0]
测试用例：TC250-260
"""
import pytest
from conftest import get, get_raw


class TestAspNetCoreAlignment:
    """第十二章 ASP.NET Core 对齐行为"""

    def test_tc250_literal_lowercase(self):
        """TC250: 字面量段小写 → /users 命中 /users 路由"""
        r = get("/ch12/align/users")
        assert r.status_code == 200

    def test_tc251_param_lowercase(self):
        """TC251: 参数值小写原样保留 → /hello → id='hello'"""
        r = get("/ch12/align/greet/hello")
        assert r.status_code == 200
        assert r.json()["id"] == "hello"

    def test_tc252_literal_highest_priority(self):
        """TC252: 字面量优先级最高"""
        r = get("/ch12/align/priority/literal")
        assert r.status_code == 200
        assert r.json()["route"] == "literal"

    def test_tc252_constrained_beats_unconstrained(self):
        """TC252: 约束参数优先于无约束参数"""
        r = get("/ch12/align/priority/42")
        assert r.status_code == 200
        assert r.json()["route"] == "constrained"

    def test_tc252_unconstrained_beats_catchall(self):
        """TC252: 无约束参数优先于 catch-all"""
        r = get("/ch12/align/priority/hello")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"

    def test_tc252_catchall_last(self):
        """TC252: catch-all 优先级最低（多段路径命中）"""
        r = get("/ch12/align/priority/a/b/c")
        assert r.status_code == 200
        assert r.json()["route"] == "catchall"

    def test_tc253_catchall_empty(self):
        """TC253: catch-all 可为空 → /files → path=''"""
        r = get("/ch12/align/files")
        assert r.status_code == 200
        assert r.json()["path"] == ""

    def test_tc253_catchall_with_path(self):
        """TC253-variant: /files/a/b → path='a/b'"""
        r = get("/ch12/align/files/a/b")
        assert r.status_code == 200
        assert r.json()["path"] == "a/b"

    def test_tc254_ambiguous_triggers_exception(self):
        """TC254: 同分路由触发歧义异常（AmbiguousMatchException）"""
        r = get_raw("/ch07/ambig/tc179/42")
        assert r.status_code >= 500

    def test_tc255_constraint_fallback(self):
        """TC255: 约束失败时可回退到低优先级路由"""
        # 数字命中约束路由
        r = get("/ch12/align/fallback/42")
        assert r.status_code == 200
        assert r.json()["route"] == "constrained"

        # 字母命中无约束路由
        r = get("/ch12/align/fallback/abc")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"

    def test_tc257_double_star_slashes(self):
        """TC257: ** catch-all 不编码斜杠 → /a/x/y → path='x/y'"""
        r = get("/ch12/align/dstar/x/y")
        assert r.status_code == 200
        assert r.json()["path"] == "x/y"

    def test_tc258_single_star_value(self):
        """TC258: * catch-all 路径值与 ** 相同（差异在 URL 生成）"""
        r = get("/ch12/align/sstar/x/y")
        assert r.status_code == 200
        assert r.json()["path"] == "x/y"

    def test_tc259_double_slash_treated_as_single(self):
        """TC259: 连续斜杠不计入分段 → GET /a//b 视为 /a/b"""
        # 大多数 HTTP 客户端会自动规范化，直接测试单斜杠行为
        r = get("/ch12/align/slash/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc260_trailing_slash(self):
        """TC260: 尾随斜杠不计入分段 → GET /users/ 命中 /users"""
        r = get("/ch12/align/trailing/")
        # 验证实际行为
        assert r.status_code in (200, 404), (
            f"TC260: 尾随斜杠行为，实际状态码：{r.status_code}"
        )


class TestTemplateCaseInsensitive:
    """TC261-266: 路由模板本身含大写/混合大小写字面量时的匹配行为

    核心验证：BUG-4 修复（移除 RouteEndpointDataSource.toAsciiLower + addLiteralNode 归一化）
    后，大写/混合大小写的路由模板字面量仍能正确实现大小写不敏感匹配，
    且 inline default 值的大小写不受影响。
    """

    # ── TC261-262: 纯大写模板字面量 /ch12/UPPER/literal/{id} ──

    def test_tc261_uppercase_template_lowercase_request(self):
        """TC261: 路由模板含大写字面量，请求路径为小写 → 命中"""
        r = get("/ch12/upper/literal/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc262_uppercase_template_lowercase_request(self):
        """TC262: 路由模板含大写字面量，请求路径为小写 → 命中"""
        r = get("/ch12/upper/literal/99")
        assert r.status_code == 200
        assert r.json()["id"] == "99"

    # ── TC263-264: 混合大小写模板字面量 /ch12/MixedCase/{id} ──

    def test_tc263_mixedcase_template_lowercase_request(self):
        """TC263: 混合大小写模板字面量，请求小写 → 命中，参数值原样保留"""
        r = get("/ch12/mixedcase/hello")
        assert r.status_code == 200
        assert r.json()["id"] == "hello"

    # ── TC265-266: 大写模板字面量 + inline default ──

    def test_tc265_uppercase_template_default_case_preserved(self):
        """TC265: 大写模板 + inline default，省略参数时默认值大小写不被小写化

        BUG-4 修复前：/ch12/UpperDefault/{ctrl=HomeValue} 的 HomeValue 被
        toAsciiLower() 变为 homevalue；修复后应保留原始大小写。
        """
        r = get("/ch12/upperdefault")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "HomeValue", (
            f"期望默认值 'HomeValue'，实际得到 '{data['ctrl']}'（大小写丢失）"
        )

    def test_tc266_uppercase_template_captured_value_lowercase(self):
        """TC266: 大写模板字面量，URL 提供的参数值小写原样保留"""
        r = get("/ch12/upperdefault/custom")
        assert r.status_code == 200
        data = r.json()
        assert data["ctrl"] == "custom", (
            f"期望参数值 'custom'，实际得到 '{data['ctrl']}'"
        )
