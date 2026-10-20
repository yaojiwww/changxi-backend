"""
test_route_binding.py — @FromRoute 来源绑定集成测试

覆盖全部 16 种叶子类型 + 代表性 ?T（路由段提取）：
  Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64,
  Float16, Float32, Float64, BigInt, Decimal, String, DateTime,
  ?Int64, ?String
"""

import math
from conftest import get


class TestRouteInt64:
    """GET /api/route/int64/{id} — @FromRoute Int64"""

    def test_valid_positive(self):
        r = get("/api/route/int64/42")
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_valid_negative(self):
        r = get("/api/route/int64/-100")
        assert r.status_code == 200
        assert r.json()["value"] == -100

    def test_zero(self):
        r = get("/api/route/int64/0")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_max_value(self):
        r = get("/api/route/int64/9223372036854775807")
        assert r.status_code == 200
        assert r.json()["value"] == 9223372036854775807

    def test_invalid_returns_400(self):
        r = get("/api/route/int64/abc")
        assert r.status_code == 400

    def test_float_string_returns_400(self):
        r = get("/api/route/int64/3.14")
        assert r.status_code == 400


class TestRouteInt32:
    """GET /api/route/int32/{n} — @FromRoute Int32"""

    def test_valid_value(self):
        r = get("/api/route/int32/2147483647")
        assert r.status_code == 200
        assert r.json()["value"] == 2147483647

    def test_negative(self):
        r = get("/api/route/int32/-2147483648")
        assert r.status_code == 200
        assert r.json()["value"] == -2147483648

    def test_overflow_returns_400(self):
        r = get("/api/route/int32/2147483648")
        assert r.status_code == 400


class TestRouteInt8:
    """GET /api/route/int8/{n} — @FromRoute Int8"""

    def test_max_value(self):
        r = get("/api/route/int8/127")
        assert r.status_code == 200
        assert r.json()["value"] == 127

    def test_min_value(self):
        r = get("/api/route/int8/-128")
        assert r.status_code == 200
        assert r.json()["value"] == -128

    def test_overflow_returns_400(self):
        r = get("/api/route/int8/128")
        assert r.status_code == 400


class TestRouteInt16:
    """GET /api/route/int16/{n} — @FromRoute Int16"""

    def test_max_value(self):
        r = get("/api/route/int16/32767")
        assert r.status_code == 200
        assert r.json()["value"] == 32767

    def test_min_value(self):
        r = get("/api/route/int16/-32768")
        assert r.status_code == 200
        assert r.json()["value"] == -32768

    def test_overflow_returns_400(self):
        r = get("/api/route/int16/32768")
        assert r.status_code == 400


class TestRouteUInt8:
    """GET /api/route/uint8/{n} — @FromRoute UInt8"""

    def test_max_value(self):
        r = get("/api/route/uint8/255")
        assert r.status_code == 200
        assert r.json()["value"] == 255

    def test_zero(self):
        r = get("/api/route/uint8/0")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/route/uint8/-1")
        assert r.status_code == 400


class TestRouteUInt16:
    """GET /api/route/uint16/{n} — @FromRoute UInt16"""

    def test_max_value(self):
        r = get("/api/route/uint16/65535")
        assert r.status_code == 200
        assert r.json()["value"] == 65535

    def test_zero(self):
        r = get("/api/route/uint16/0")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/route/uint16/-1")
        assert r.status_code == 400


class TestRouteUInt32:
    """GET /api/route/uint32/{n} — @FromRoute UInt32（以字符串返回）"""

    def test_max_value(self):
        r = get("/api/route/uint32/4294967295")
        assert r.status_code == 200
        assert r.json()["value"] == "4294967295"

    def test_zero(self):
        r = get("/api/route/uint32/0")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = get("/api/route/uint32/-1")
        assert r.status_code == 400


class TestRouteUInt64:
    """GET /api/route/uint64/{n} — @FromRoute UInt64（以字符串返回）"""

    def test_max_value(self):
        r = get("/api/route/uint64/18446744073709551615")
        assert r.status_code == 200
        assert r.json()["value"] == "18446744073709551615"

    def test_zero(self):
        r = get("/api/route/uint64/0")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = get("/api/route/uint64/-1")
        assert r.status_code == 400


class TestRouteFloat16:
    """GET /api/route/float16/{val} — @FromRoute Float16"""

    def test_valid_value(self):
        r = get("/api/route/float16/1.0")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 1.0, rel_tol=1e-2)

    def test_negative(self):
        r = get("/api/route/float16/-2.0")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], -2.0, rel_tol=1e-2)

    def test_invalid_returns_400(self):
        r = get("/api/route/float16/abc")
        assert r.status_code == 400


class TestRouteFloat32:
    """GET /api/route/float32/{val} — @FromRoute Float32"""

    def test_valid_value(self):
        r = get("/api/route/float32/3.14")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.14, rel_tol=1e-5)

    def test_negative(self):
        r = get("/api/route/float32/-1.5")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], -1.5, rel_tol=1e-5)

    def test_invalid_returns_400(self):
        r = get("/api/route/float32/abc")
        assert r.status_code == 400


class TestRouteFloat64:
    """GET /api/route/float64/{val} — @FromRoute Float64"""

    def test_valid_value(self):
        r = get("/api/route/float64/3.141592653589793")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.141592653589793, rel_tol=1e-6)

    def test_zero(self):
        r = get("/api/route/float64/0.0")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = get("/api/route/float64/abc")
        assert r.status_code == 400


class TestRouteBigInt:
    """GET /api/route/bigint/{n} — @FromRoute BigInt（以字符串返回）"""

    def test_large_positive(self):
        r = get("/api/route/bigint/99999999999999999999")
        assert r.status_code == 200
        assert r.json()["value"] == "99999999999999999999"

    def test_negative(self):
        r = get("/api/route/bigint/-12345678901234567890")
        assert r.status_code == 200
        assert r.json()["value"] == "-12345678901234567890"

    def test_zero(self):
        r = get("/api/route/bigint/0")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = get("/api/route/bigint/abc")
        assert r.status_code == 400


class TestRouteDecimal:
    """GET /api/route/decimal/{val} — @FromRoute Decimal（以字符串返回）"""

    def test_high_precision(self):
        r = get("/api/route/decimal/3.141592653589793")
        assert r.status_code == 200
        assert r.json()["value"] == "3.141592653589793"

    def test_integer(self):
        r = get("/api/route/decimal/42")
        assert r.status_code == 200
        assert r.json()["value"] == "42"

    def test_negative(self):
        r = get("/api/route/decimal/-99.99")
        assert r.status_code == 200
        assert r.json()["value"] == "-99.99"

    def test_invalid_returns_400(self):
        r = get("/api/route/decimal/abc")
        assert r.status_code == 400


class TestRouteBool:
    """GET /api/route/bool/{flag} — @FromRoute Bool"""

    def test_true(self):
        r = get("/api/route/bool/true")
        assert r.status_code == 200
        assert r.json()["value"] is True

    def test_false(self):
        r = get("/api/route/bool/false")
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_invalid_returns_400(self):
        r = get("/api/route/bool/yes")
        assert r.status_code == 400

    def test_integer_returns_400(self):
        r = get("/api/route/bool/1")
        assert r.status_code == 400


class TestRouteString:
    """GET /api/route/string/{name} — @FromRoute String"""

    def test_valid_string(self):
        r = get("/api/route/string/hello")
        assert r.status_code == 200
        assert r.json()["value"] == "hello"

    def test_numeric_string(self):
        r = get("/api/route/string/12345")
        assert r.status_code == 200
        assert r.json()["value"] == "12345"

    def test_special_chars(self):
        r = get("/api/route/string/foo-bar")
        assert r.status_code == 200
        assert r.json()["value"] == "foo-bar"


class TestRouteDateTime:
    """GET /api/route/datetime/{dt} — @FromRoute DateTime"""

    def test_date_only(self):
        r = get("/api/route/datetime/2025-01-15")
        assert r.status_code == 200
        data = r.json()
        assert data["is_epoch"] is False
        assert "2025" in data["value"]

    def test_invalid_returns_400(self):
        r = get("/api/route/datetime/not-a-date")
        assert r.status_code == 400


class TestRouteNullableInt64:
    """GET /api/route/nullable-int64/{id} — @FromRoute ?Int64"""

    def test_valid_value_returns_some(self):
        r = get("/api/route/nullable-int64/42")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 42

    def test_invalid_returns_400(self):
        r = get("/api/route/nullable-int64/abc")
        assert r.status_code == 400


class TestRouteNullableString:
    """GET /api/route/nullable-string/{name} — @FromRoute ?String"""

    def test_valid_value_returns_some(self):
        r = get("/api/route/nullable-string/hello")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "hello"


class TestActionCaseRouting:
    """[controller]/[action] 模板 — action 名称大小写路由验证

    路由存储时已全量转小写，客户端须以全小写 URL 访问。
    """

    def test_camel_case_action(self):
        """camelCaseAction → /route/camelcaseaction"""
        r = get("/route/camelcaseaction")
        assert r.status_code == 200
        assert r.json()["action"] == "camelCaseAction"

    def test_pascal_case_action(self):
        """PascalCaseAction → /route/pascalcaseaction"""
        r = get("/route/pascalcaseaction")
        assert r.status_code == 200
        assert r.json()["action"] == "PascalCaseAction"

    def test_get_mixed_case_action(self):
        """getMixedCase → /route/getmixedcase"""
        r = get("/route/getmixedcase")
        assert r.status_code == 200
        assert r.json()["action"] == "getMixedCase"

    def test_original_case_url_matches(self):
        """原始大小写 URL 同样命中（路由匹配对请求路径不区分大小写）"""
        r = get("/route/camelCaseAction")
        assert r.status_code == 200
        assert r.json()["action"] == "camelCaseAction"
