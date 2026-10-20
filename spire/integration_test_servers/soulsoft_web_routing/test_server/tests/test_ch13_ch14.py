"""
test_ch13_ch14.py - 第十三章：约束优化 + 第十四章：OutboundPrecedence [P2]
测试用例：TC261-264

第十三章通过 DFA 匹配行为验证约束优化，第十四章通过 /meta/parse 的 outbound 字段验证。
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


# ============================================================
# 第十三章：IParameterLiteralNodeMatchingPolicy (TC261-262)
# ============================================================

class TestParameterLiteralPolicy:
    """13. IParameterLiteralNodeMatchingPolicy 约束优化"""

    def test_tc261_literal_123_wins_over_int_constraint(self):
        """TC261: /literal/123 注册为字面量，优先于 /{id:int} 参数路由"""
        r = get("/ch13/literal/123")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_123"

    def test_tc261_int_constraint_matches_456(self):
        """TC261: /int/456 → 命中 /{id:int} 约束路由"""
        r = get("/ch13/int/456")
        assert r.status_code == 200
        assert r.json()["route"] == "int_constrained"
        assert r.json()["id"] == "456"

    def test_tc262_int_constraint_rejects_abc(self):
        """TC262: /int/abc → int 约束排除字母输入（404）"""
        r = get("/ch13/int/abc")
        assert r.status_code == 404

    def test_tc262_unconstrained_matches_abc(self):
        """TC262: /str/abc → 无约束路由命中"""
        r = get("/ch13/str/abc")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"
        assert r.json()["name"] == "abc"


# ============================================================
# 第十四章：OutboundPrecedence (TC263-264)
# ============================================================

class TestOutboundPrecedence:
    """14. OutboundPrecedence（URL 生成优先级，与 inbound 方向相反）"""

    def test_tc263_literal_outbound_higher_than_param(self):
        """TC263: 字面量 outbound > 普通参数 outbound（数字越大优先级越高）"""
        literal_out = meta_parse("/users")["outbound"]
        param_out = meta_parse("/{id}")["outbound"]
        # outbound 方向与 inbound 相反：字面量应有更高数字
        assert float(literal_out) > float(param_out), (
            f"TC263: 字面量 outbound '{literal_out}' 应大于普通参数 '{param_out}'"
        )

    def test_tc264_catchall_has_lowest_outbound(self):
        """TC264: 无约束 catch-all outbound 最低，字面量 outbound 最高"""
        literal_out = meta_parse("/users")["outbound"]
        catchall_out = meta_parse("/{**path}")["outbound"]
        assert float(literal_out) > float(catchall_out), (
            f"TC264: 字面量 outbound '{literal_out}' 应大于 catch-all '{catchall_out}'"
        )

    def test_tc264_param_outbound_between(self):
        """TC264: 普通参数 outbound 介于字面量和 catch-all 之间"""
        literal_out = float(meta_parse("/users")["outbound"])
        param_out = float(meta_parse("/{id}")["outbound"])
        catchall_out = float(meta_parse("/{**path}")["outbound"])
        assert literal_out > param_out > catchall_out, (
            f"TC264: 期望 字面量({literal_out}) > 参数({param_out}) > catch-all({catchall_out})"
        )
