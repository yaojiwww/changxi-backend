"""
test_primitive_binding.py — PrimitiveModelBinder<T> 集成测试

覆盖全部 14 种 Parsable 类型，并补充 4 个代表性 Nullable 查询绑定：
  Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64,
  Float16, Float32, Float64, BigInt, Decimal,
  ?Int64, ?String, ?Bool, ?DateTime
"""

import math
import pytest
from conftest import assert_problem_error_key, get


class TestInt64Binding:
    """GET /api/primitive/int64 — PrimitiveModelBinder<Int64>"""

    def test_valid_positive(self):
        r = get("/api/primitive/int64", params={"id": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_valid_negative(self):
        r = get("/api/primitive/int64", params={"id": "-100"})
        assert r.status_code == 200
        assert r.json()["value"] == -100

    def test_max_value(self):
        """Int64.Max = 9223372036854775807"""
        r = get("/api/primitive/int64", params={"id": "9223372036854775807"})
        assert r.status_code == 200
        assert r.json()["value"] == 9223372036854775807

    def test_zero(self):
        r = get("/api/primitive/int64", params={"id": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_missing_key_returns_default(self):
        """键缺失 → 返回默认值 0"""
        r = get("/api/primitive/int64")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_empty_value_returns_default(self):
        """空字符串 → 返回默认值 0"""
        r = get("/api/primitive/int64", params={"id": ""})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_invalid_string_returns_400(self):
        """无效字符串 → 框架自动返回 400"""
        r = get("/api/primitive/int64", params={"id": "abc"})
        assert r.status_code == 400

    def test_invalid_string_reports_binding_name(self):
        r = get("/api/primitive/int64", params={"id": "abc"})
        messages = assert_problem_error_key(r, "id")
        assert "not valid for id" in messages[0]

    def test_invalid_float_string_returns_400(self):
        """浮点字面量对 Int64 无效 → 400"""
        r = get("/api/primitive/int64", params={"id": "3.14"})
        assert r.status_code == 400

    def test_overflow_returns_400(self):
        """超出 Int64 范围 → 400"""
        r = get("/api/primitive/int64", params={"id": "99999999999999999999"})
        assert r.status_code == 400


class TestInt32Binding:
    """GET /api/primitive/int32 — PrimitiveModelBinder<Int32>"""

    def test_valid_value(self):
        r = get("/api/primitive/int32", params={"n": "100"})
        assert r.status_code == 200
        assert r.json()["value"] == 100

    def test_max_value(self):
        """Int32.Max = 2147483647"""
        r = get("/api/primitive/int32", params={"n": "2147483647"})
        assert r.status_code == 200
        assert r.json()["value"] == 2147483647

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/int32")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/primitive/int32", params={"n": "not_a_number"})
        assert r.status_code == 400

    def test_int64_overflow_returns_400(self):
        """超出 Int32 但在 Int64 范围内 → 400"""
        r = get("/api/primitive/int32", params={"n": "2147483648"})
        assert r.status_code == 400


class TestBoolBinding:
    """GET /api/primitive/bool — PrimitiveModelBinder<Bool>"""

    def test_true(self):
        r = get("/api/primitive/bool", params={"flag": "true"})
        assert r.status_code == 200
        assert r.json()["value"] is True

    def test_false(self):
        r = get("/api/primitive/bool", params={"flag": "false"})
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_missing_key_returns_default_false(self):
        r = get("/api/primitive/bool")
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_empty_value_returns_default_false(self):
        r = get("/api/primitive/bool", params={"flag": ""})
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_invalid_yes_returns_400(self):
        r = get("/api/primitive/bool", params={"flag": "yes"})
        assert r.status_code == 400

    def test_invalid_1_returns_400(self):
        """整数 1 对 Bool 无效"""
        r = get("/api/primitive/bool", params={"flag": "1"})
        assert r.status_code == 400

    def test_invalid_on_returns_400(self):
        r = get("/api/primitive/bool", params={"flag": "on"})
        assert r.status_code == 400


class TestFloat64Binding:
    """GET /api/primitive/float64 — PrimitiveModelBinder<Float64>"""

    def test_valid_positive(self):
        r = get("/api/primitive/float64", params={"val": "3.14"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.14, rel_tol=1e-6)

    def test_valid_negative(self):
        r = get("/api/primitive/float64", params={"val": "-1.5"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], -1.5, rel_tol=1e-6)

    def test_integer_string(self):
        r = get("/api/primitive/float64", params={"val": "42"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 42.0, rel_tol=1e-6)

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/float64")
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 0.0, abs_tol=1e-9)

    def test_invalid_returns_400(self):
        r = get("/api/primitive/float64", params={"val": "abc"})
        assert r.status_code == 400


class TestUInt64Binding:
    """GET /api/primitive/uint64 — PrimitiveModelBinder<UInt64>"""

    def test_max_value(self):
        """UInt64.Max = 18446744073709551615，以字符串返回"""
        r = get("/api/primitive/uint64", params={"n": "18446744073709551615"})
        assert r.status_code == 200
        assert r.json()["value"] == "18446744073709551615"

    def test_zero(self):
        r = get("/api/primitive/uint64", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        """UInt64 不接受负数"""
        r = get("/api/primitive/uint64", params={"n": "-1"})
        assert r.status_code == 400


class TestInt8Binding:
    """GET /api/primitive/int8 — PrimitiveModelBinder<Int8>"""

    def test_max_value(self):
        r = get("/api/primitive/int8", params={"n": "127"})
        assert r.status_code == 200
        assert r.json()["value"] == 127

    def test_min_value(self):
        r = get("/api/primitive/int8", params={"n": "-128"})
        assert r.status_code == 200
        assert r.json()["value"] == -128

    def test_zero(self):
        r = get("/api/primitive/int8", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/int8")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        """128 超出 Int8 范围 → 400"""
        r = get("/api/primitive/int8", params={"n": "128"})
        assert r.status_code == 400

    def test_invalid_returns_400(self):
        r = get("/api/primitive/int8", params={"n": "abc"})
        assert r.status_code == 400


class TestInt16Binding:
    """GET /api/primitive/int16 — PrimitiveModelBinder<Int16>"""

    def test_max_value(self):
        r = get("/api/primitive/int16", params={"n": "32767"})
        assert r.status_code == 200
        assert r.json()["value"] == 32767

    def test_min_value(self):
        r = get("/api/primitive/int16", params={"n": "-32768"})
        assert r.status_code == 200
        assert r.json()["value"] == -32768

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/int16")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = get("/api/primitive/int16", params={"n": "32768"})
        assert r.status_code == 400

    def test_invalid_returns_400(self):
        r = get("/api/primitive/int16", params={"n": "abc"})
        assert r.status_code == 400


class TestUInt8Binding:
    """GET /api/primitive/uint8 — PrimitiveModelBinder<UInt8>"""

    def test_max_value(self):
        r = get("/api/primitive/uint8", params={"n": "255"})
        assert r.status_code == 200
        assert r.json()["value"] == 255

    def test_zero(self):
        r = get("/api/primitive/uint8", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/uint8")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/primitive/uint8", params={"n": "-1"})
        assert r.status_code == 400

    def test_overflow_returns_400(self):
        r = get("/api/primitive/uint8", params={"n": "256"})
        assert r.status_code == 400


class TestUInt16Binding:
    """GET /api/primitive/uint16 — PrimitiveModelBinder<UInt16>"""

    def test_max_value(self):
        r = get("/api/primitive/uint16", params={"n": "65535"})
        assert r.status_code == 200
        assert r.json()["value"] == 65535

    def test_zero(self):
        r = get("/api/primitive/uint16", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/uint16")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/primitive/uint16", params={"n": "-1"})
        assert r.status_code == 400

    def test_overflow_returns_400(self):
        r = get("/api/primitive/uint16", params={"n": "65536"})
        assert r.status_code == 400


class TestUInt32Binding:
    """GET /api/primitive/uint32 — PrimitiveModelBinder<UInt32>（以字符串返回）"""

    def test_max_value(self):
        r = get("/api/primitive/uint32", params={"n": "4294967295"})
        assert r.status_code == 200
        assert r.json()["value"] == "4294967295"

    def test_zero(self):
        r = get("/api/primitive/uint32", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/uint32")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = get("/api/primitive/uint32", params={"n": "-1"})
        assert r.status_code == 400

    def test_overflow_returns_400(self):
        r = get("/api/primitive/uint32", params={"n": "4294967296"})
        assert r.status_code == 400


class TestFloat16Binding:
    """GET /api/primitive/float16 — PrimitiveModelBinder<Float16>（精度约 3 位小数）"""

    def test_valid_value(self):
        import math
        r = get("/api/primitive/float16", params={"val": "1.0"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 1.0, rel_tol=1e-2)

    def test_zero(self):
        r = get("/api/primitive/float16", params={"val": "0.0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/float16")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_negative_value(self):
        import math
        r = get("/api/primitive/float16", params={"val": "-1.0"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], -1.0, rel_tol=1e-2)

    def test_invalid_returns_400(self):
        r = get("/api/primitive/float16", params={"val": "abc"})
        assert r.status_code == 400


class TestFloat32Binding:
    """GET /api/primitive/float32 — PrimitiveModelBinder<Float32>"""

    def test_valid_value(self):
        import math
        r = get("/api/primitive/float32", params={"val": "3.14"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.14, rel_tol=1e-5)

    def test_negative_value(self):
        import math
        r = get("/api/primitive/float32", params={"val": "-1.5"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], -1.5, rel_tol=1e-5)

    def test_zero(self):
        r = get("/api/primitive/float32", params={"val": "0.0"})
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/float32")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = get("/api/primitive/float32", params={"val": "not_a_float"})
        assert r.status_code == 400


class TestBigIntBinding:
    """GET /api/primitive/bigint — PrimitiveModelBinder<BigInt>（以字符串返回）"""

    def test_large_value(self):
        r = get("/api/primitive/bigint", params={"n": "99999999999999999999"})
        assert r.status_code == 200
        assert r.json()["value"] == "99999999999999999999"

    def test_negative_value(self):
        r = get("/api/primitive/bigint", params={"n": "-99999999999999999999"})
        assert r.status_code == 200
        assert r.json()["value"] == "-99999999999999999999"

    def test_zero(self):
        r = get("/api/primitive/bigint", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/bigint")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = get("/api/primitive/bigint", params={"n": "3.14"})
        assert r.status_code == 400

    def test_invalid_string_returns_400(self):
        r = get("/api/primitive/bigint", params={"n": "abc"})
        assert r.status_code == 400


class TestDecimalBinding:
    """GET /api/primitive/decimal — PrimitiveModelBinder<Decimal>（以字符串返回）"""

    def test_integer_value(self):
        r = get("/api/primitive/decimal", params={"val": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == "42"

    def test_decimal_value(self):
        r = get("/api/primitive/decimal", params={"val": "3.14"})
        assert r.status_code == 200
        assert r.json()["value"] == "3.14"

    def test_high_precision(self):
        r = get("/api/primitive/decimal", params={"val": "3.141592653589793"})
        assert r.status_code == 200
        assert r.json()["value"] == "3.141592653589793"

    def test_negative_value(self):
        r = get("/api/primitive/decimal", params={"val": "-99.99"})
        assert r.status_code == 200
        assert r.json()["value"] == "-99.99"

    def test_zero(self):
        r = get("/api/primitive/decimal", params={"val": "0"})
        assert r.status_code == 200

    def test_missing_key_returns_default(self):
        r = get("/api/primitive/decimal")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = get("/api/primitive/decimal", params={"val": "abc"})
        assert r.status_code == 400


class TestNullableInt64Binding:
    """GET /api/primitive/nullable-int64 — @FromQuery id: ?Int64"""

    def test_valid_value_returns_some(self):
        r = get("/api/primitive/nullable-int64", params={"id": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 42

    def test_missing_key_returns_none(self):
        r = get("/api/primitive/nullable-int64")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_value_returns_none(self):
        r = get("/api/primitive/nullable-int64", params={"id": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_invalid_returns_400(self):
        r = get("/api/primitive/nullable-int64", params={"id": "abc"})
        assert r.status_code == 400


class TestNullableStringBinding:
    """GET /api/primitive/nullable-string — @FromQuery name: ?String"""

    def test_valid_value_returns_some(self):
        r = get("/api/primitive/nullable-string", params={"name": "Alice"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "Alice"

    def test_missing_key_returns_none(self):
        r = get("/api/primitive/nullable-string")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_value_returns_none(self):
        r = get("/api/primitive/nullable-string", params={"name": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None


class TestNullableBoolBinding:
    """GET /api/primitive/nullable-bool — @FromQuery flag: ?Bool"""

    def test_true_returns_some_true(self):
        r = get("/api/primitive/nullable-bool", params={"flag": "true"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] is True

    def test_missing_key_returns_none(self):
        r = get("/api/primitive/nullable-bool")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_invalid_returns_400(self):
        r = get("/api/primitive/nullable-bool", params={"flag": "yes"})
        assert r.status_code == 400


class TestNullableDateTimeBinding:
    """GET /api/primitive/nullable-datetime — @FromQuery dt: ?DateTime"""

    def test_valid_value_returns_some(self):
        r = get("/api/primitive/nullable-datetime", params={"dt": "2025-01-15T10:30:00Z"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert "2025" in data["value"]

    def test_missing_key_returns_none(self):
        r = get("/api/primitive/nullable-datetime")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_invalid_returns_400(self):
        r = get("/api/primitive/nullable-datetime", params={"dt": "not-a-date"})
        assert r.status_code == 400
