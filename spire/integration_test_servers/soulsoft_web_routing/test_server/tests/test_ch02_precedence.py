"""
test_ch02_precedence.py - 第二章：路由优先级 RoutePrecedence [P1]
测试用例：TC48-63

通过 /meta/parse 端点获取 inboundPrecedence / outboundPrecedence 值进行验证。
优先级规则：数字越小，inbound 优先级越高。
"""
import urllib.parse
from conftest import get


def meta_parse(pattern: str) -> dict:
    """调用 /meta/parse 端点，返回解析结果"""
    encoded = urllib.parse.quote(pattern, safe="")
    r = get(f"/meta/parse?pattern={encoded}")
    assert r.status_code == 200
    d = r.json()
    assert d["ok"] is True, f"模式 '{pattern}' 解析失败: {d.get('error')}"
    return d


def inbound(pattern: str) -> str:
    """获取模式的 inboundPrecedence 字符串"""
    return meta_parse(pattern)["inbound"]


def outbound(pattern: str) -> str:
    """获取模式的 outboundPrecedence 字符串"""
    return meta_parse(pattern)["outbound"]


# ============================================================
# 2.1 Inbound 优先级数字（单段）TC48-54
# ============================================================

class TestInboundPrecedenceSingleSegment:
    """2.1 Inbound 优先级数字（单段）"""

    def test_tc48_literal_segment(self):
        """TC48: 字面量段（如 /users）→ inbound 以 '1' 开头"""
        v = inbound("/users")
        assert v.startswith("1"), f"TC48: 期望以 '1' 开头，实际 '{v}'"

    def test_tc49_complex_segment(self):
        """TC49: 复合段（如 /v{ver}）→ inbound 以 '2' 开头"""
        v = inbound("/v{ver}")
        assert v.startswith("2"), f"TC49: 期望以 '2' 开头，实际 '{v}'"

    def test_tc50_constrained_param(self):
        """TC50: 有约束参数（如 /{id:int}）→ inbound 以 '2' 开头"""
        v = inbound("/{id:int}")
        assert v.startswith("2"), f"TC50: 期望以 '2' 开头，实际 '{v}'"

    def test_tc52_unconstrained_param(self):
        """TC52: 无约束普通参数（如 /{id}）→ inbound 以 '3' 开头"""
        v = inbound("/{id}")
        assert v.startswith("3"), f"TC52: 期望以 '3' 开头，实际 '{v}'"

    def test_tc54_unconstrained_catchall(self):
        """TC54: 无约束 catch-all（如 /{**path}）→ inbound 以 '5' 开头"""
        v = inbound("/{**path}")
        assert v.startswith("5"), f"TC54: 期望以 '5' 开头，实际 '{v}'"


# ============================================================
# 2.2 多段合并公式验证 TC55-59
# ============================================================

class TestInboundPrecedenceMultiSegment:
    """2.2 多段合并公式验证"""

    def test_tc55_all_literal_three_segments(self):
        """TC55: /a/b/c（全字面量3段）→ '1.11'"""
        v = inbound("/a/b/c")
        assert v == "1.11", f"TC55: 期望 '1.11'，实际 '{v}'"

    def test_tc56_literal_plus_param(self):
        """TC56: /a/{id}（1字面+1参数）→ '1.3'"""
        v = inbound("/a/{id}")
        assert v == "1.3", f"TC56: 期望 '1.3'，实际 '{v}'"

    def test_tc57_literal_plus_constrained_param(self):
        """TC57: /a/{id:int}（1字面+1约束参数）→ '1.2'"""
        v = inbound("/a/{id:int}")
        assert v == "1.2", f"TC57: 期望 '1.2'，实际 '{v}'"

    def test_tc58_two_unconstrained_params(self):
        """TC58: /{id}/{name}（2普通参数）→ '3.3'"""
        v = inbound("/{id}/{name}")
        assert v == "3.3", f"TC58: 期望 '3.3'，实际 '{v}'"

    def test_tc59_literal_plus_catchall(self):
        """TC59: /a/{**rest}（1字面+catch-all）→ '1.5'"""
        v = inbound("/a/{**rest}")
        assert v == "1.5", f"TC59: 期望 '1.5'，实际 '{v}'"


# ============================================================
# 2.3 排序方向验证（优先级高 = 值小）TC60-63
# ============================================================

class TestInboundPrecedenceOrdering:
    """2.3 排序方向验证"""

    def test_tc60_literal_beats_param(self):
        """TC60: /users/list 的 inbound < /users/{id}（字面量优先）"""
        a = inbound("/users/list")
        b = inbound("/users/{id}")
        assert a < b, f"TC60: 期望字面量 '{a}' < 参数 '{b}'"

    def test_tc61_constrained_beats_unconstrained(self):
        """TC61: /users/{id:int} 的 inbound < /users/{id}（约束参数优先）"""
        a = inbound("/users/{id:int}")
        b = inbound("/users/{id}")
        assert a < b, f"TC61: 期望约束 '{a}' < 无约束 '{b}'"

    def test_tc62_param_beats_catchall(self):
        """TC62: /users/{id} 的 inbound < /files/{**rest}（参数优先于 catch-all）"""
        a = inbound("/users/{id}")
        b = inbound("/files/{**rest}")
        assert a < b, f"TC62: 期望参数 '{a}' < catch-all '{b}'"

    def test_tc63_constrained_param_beats_constrained_catchall(self):
        """TC63: /a/{id:int} < /a/{**path:regex(...)}（约束参数优于约束 catch-all）"""
        a = inbound("/a/{id:int}")
        b = inbound("/a/{**path:regex([a-z]+)}")
        assert a < b, f"TC63: 期望 '{a}' < '{b}'"
