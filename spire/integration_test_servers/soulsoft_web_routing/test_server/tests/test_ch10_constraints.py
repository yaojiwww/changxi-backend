"""
test_ch10_constraints.py - 第十章：约束类详细边界 [P1]
测试用例：TC205-233
"""
import pytest
from conftest import get


# ============================================================
# 10.1 IntRouteConstraint (TC205-212)
# ============================================================

class TestIntConstraint:
    """10.1 IntRouteConstraint"""

    def test_tc205_zero(self):
        """TC205: '0' → true"""
        r = get("/ch10/int/0")
        assert r.status_code == 200

    def test_tc206_negative(self):
        """TC206: '-1' → true（负整数）"""
        r = get("/ch10/int/-1")
        assert r.status_code == 200

    def test_tc207_int64_max(self):
        """TC207: '9223372036854775807' → true（Int64 最大值）"""
        r = get("/ch10/int/9223372036854775807")
        assert r.status_code == 200

    def test_tc208_int64_overflow(self):
        """TC208: '9223372036854775808' → false（溢出）"""
        r = get("/ch10/int/9223372036854775808")
        assert r.status_code == 404

    def test_tc209_float_string(self):
        """TC209: '3.14' → false"""
        r = get("/ch10/int/3.14")
        assert r.status_code == 404

    def test_tc210_empty_string(self):
        """TC210: '' → false（空字符串）"""
        # 空路径段无法到达此路由
        r = get("/ch10/int/")
        assert r.status_code in (404, 400)


# ============================================================
# 10.2 BoolRouteConstraint (TC213-219)
# ============================================================

class TestBoolConstraint:
    """10.2 BoolRouteConstraint"""

    def test_tc213_true(self):
        """TC213: 'true' → true"""
        r = get("/ch10/bool/true")
        assert r.status_code == 200

    def test_tc214_false(self):
        """TC214: 'false' → true"""
        r = get("/ch10/bool/false")
        assert r.status_code == 200

    def test_tc217_number_one(self):
        """TC217: '1' → false（'1' 不是 bool）"""
        r = get("/ch10/bool/1")
        assert r.status_code == 404

    def test_tc218_yes(self):
        """TC218: 'yes' → false"""
        r = get("/ch10/bool/yes")
        assert r.status_code == 404

    def test_tc219_empty(self):
        """TC219: '' → false（空字符串）"""
        r = get("/ch10/bool/")
        assert r.status_code in (404, 400)


# ============================================================
# 10.3 FloatRouteConstraint (TC220-225)
# ============================================================

class TestFloatConstraint:
    """10.3 FloatRouteConstraint"""

    def test_tc220_decimal(self):
        """TC220: '3.14' → true"""
        r = get("/ch10/float/3.14")
        assert r.status_code == 200

    def test_tc221_negative(self):
        """TC221: '-0.5' → true"""
        r = get("/ch10/float/-0.5")
        assert r.status_code == 200

    def test_tc222_integer_as_float(self):
        """TC222: '0' → true（整数可解析为 float）"""
        r = get("/ch10/float/0")
        assert r.status_code == 200

    def test_tc223_scientific_notation(self):
        """TC223: '1e10' → true（科学计数法）"""
        r = get("/ch10/float/1e10")
        assert r.status_code == 200

    def test_tc224_invalid_string(self):
        """TC224: 'abc' → false"""
        r = get("/ch10/float/abc")
        assert r.status_code == 404

    def test_tc225_empty_string(self):
        """TC225: '' → false"""
        r = get("/ch10/float/")
        assert r.status_code in (404, 400)


# ============================================================
# 10.4 RegexRouteConstraint (TC226-233)
# ============================================================

class TestRegexConstraint:
    """10.4 RegexRouteConstraint"""

    def test_tc226_alpha_lowercase(self):
        """TC226: pattern=[a-z]+ + 'hello' → true"""
        r = get("/ch10/regex/alpha/hello")
        assert r.status_code == 200

    def test_tc229_digits_valid(self):
        """TC229: pattern=^\\d+$ + '123' → true"""
        r = get("/ch10/regex/digits/123")
        assert r.status_code == 200

    def test_tc230_digits_invalid(self):
        """TC230: pattern=^\\d+$ + 'abc' → false"""
        r = get("/ch10/regex/digits/abc")
        assert r.status_code == 404

    def test_tc231_partial_match(self):
        """TC231: pattern=[a-z]+ + 'hello world' → 部分匹配应命中"""
        # URL 编码空格
        r = get("/ch10/regex/alpha/hello%20world")
        # 正则为部分匹配，'hello world' 含字母段应命中
        assert r.status_code == 200

    def test_tc232_full_match_semantic(self):
        """TC232: pattern=^\\d+$ + '123abc' → false（全匹配语义）"""
        r = get("/ch10/regex/digits/123abc")
        assert r.status_code == 404

    def test_tc233_empty_string_regex(self):
        """TC233: pattern=[a-z]+ + '' → false（空字符串无字母）"""
        r = get("/ch10/regex/alpha/")
        assert r.status_code in (404, 400)
