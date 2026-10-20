"""
test_nullable_binding.py — NullableModelBinder（Option<T>）集成测试

覆盖全部 16 种 ?T：
  ?Bool, ?Int8, ?Int16, ?Int32, ?Int64,
  ?UInt8, ?UInt16, ?UInt32, ?UInt64,
  ?Float16, ?Float32, ?Float64,
  ?BigInt, ?Decimal, ?String, ?DateTime
"""

import math
from conftest import get


class TestNullableInt64:
    """GET /api/nullable/int64 — NullableModelBinder<Int64>"""

    def test_valid_value_returns_some(self):
        r = get("/api/nullable/int64", params={"id": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 42

    def test_missing_key_returns_none(self):
        """键缺失 → NullableModelBinder 返回 None"""
        r = get("/api/nullable/int64")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_value_returns_none(self):
        """空串 → NullableModelBinder 视为缺失，返回 None"""
        r = get("/api/nullable/int64", params={"id": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_zero_returns_some(self):
        """零值是有效值，应返回 Some(0)"""
        r = get("/api/nullable/int64", params={"id": "0"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 0

    def test_negative_value_returns_some(self):
        r = get("/api/nullable/int64", params={"id": "-99"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == -99

    def test_invalid_string_returns_400(self):
        """无效值 → 内层 PrimitiveModelBinder 写入 modelState → 框架返回 400"""
        r = get("/api/nullable/int64", params={"id": "abc"})
        assert r.status_code == 400


class TestNullableBool:
    """GET /api/nullable/bool — NullableModelBinder<Bool>"""

    def test_true_returns_some_true(self):
        r = get("/api/nullable/bool", params={"flag": "true"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] is True

    def test_false_returns_some_false(self):
        r = get("/api/nullable/bool", params={"flag": "false"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] is False

    def test_missing_key_returns_none(self):
        r = get("/api/nullable/bool")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_value_returns_none(self):
        r = get("/api/nullable/bool", params={"flag": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_invalid_returns_400(self):
        r = get("/api/nullable/bool", params={"flag": "yes"})
        assert r.status_code == 400


class TestNullableString:
    """GET /api/nullable/string — NullableModelBinder<String>"""

    def test_valid_value_returns_some(self):
        r = get("/api/nullable/string", params={"name": "Alice"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "Alice"

    def test_missing_key_returns_none(self):
        r = get("/api/nullable/string")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_value_returns_none(self):
        """空串 → NullableModelBinder 视为缺失 → None"""
        r = get("/api/nullable/string", params={"name": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_whitespace_value_returns_some(self):
        """纯空格是非空字符串，应返回 Some"""
        r = get("/api/nullable/string", params={"name": " "})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == " "


# ── 补全 13 种缺失的 ?T 类型 ──────────────────────────────────────────────────

class TestNullableInt8:
    """GET /api/nullable/int8 — NullableModelBinder<Int8>"""

    def test_valid_max(self):
        r = get("/api/nullable/int8", params={"n": "127"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 127

    def test_valid_min(self):
        r = get("/api/nullable/int8", params={"n": "-128"})
        assert r.status_code == 200
        assert r.json()["value"] == -128

    def test_missing_returns_none(self):
        r = get("/api/nullable/int8")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_returns_none(self):
        r = get("/api/nullable/int8", params={"n": ""})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_overflow_returns_400(self):
        r = get("/api/nullable/int8", params={"n": "128"})
        assert r.status_code == 400

    def test_invalid_returns_400(self):
        r = get("/api/nullable/int8", params={"n": "abc"})
        assert r.status_code == 400


class TestNullableInt16:
    """GET /api/nullable/int16 — NullableModelBinder<Int16>"""

    def test_valid_max(self):
        r = get("/api/nullable/int16", params={"n": "32767"})
        assert r.status_code == 200
        assert r.json()["value"] == 32767

    def test_missing_returns_none(self):
        r = get("/api/nullable/int16")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_overflow_returns_400(self):
        r = get("/api/nullable/int16", params={"n": "32768"})
        assert r.status_code == 400


class TestNullableInt32:
    """GET /api/nullable/int32 — NullableModelBinder<Int32>"""

    def test_valid_max(self):
        r = get("/api/nullable/int32", params={"n": "2147483647"})
        assert r.status_code == 200
        assert r.json()["value"] == 2147483647

    def test_missing_returns_none(self):
        r = get("/api/nullable/int32")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_overflow_returns_400(self):
        r = get("/api/nullable/int32", params={"n": "2147483648"})
        assert r.status_code == 400


class TestNullableUInt8:
    """GET /api/nullable/uint8 — NullableModelBinder<UInt8>"""

    def test_valid_max(self):
        r = get("/api/nullable/uint8", params={"n": "255"})
        assert r.status_code == 200
        assert r.json()["value"] == 255

    def test_missing_returns_none(self):
        r = get("/api/nullable/uint8")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_negative_returns_400(self):
        r = get("/api/nullable/uint8", params={"n": "-1"})
        assert r.status_code == 400


class TestNullableUInt16:
    """GET /api/nullable/uint16 — NullableModelBinder<UInt16>"""

    def test_valid_max(self):
        r = get("/api/nullable/uint16", params={"n": "65535"})
        assert r.status_code == 200
        assert r.json()["value"] == 65535

    def test_missing_returns_none(self):
        r = get("/api/nullable/uint16")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_negative_returns_400(self):
        r = get("/api/nullable/uint16", params={"n": "-1"})
        assert r.status_code == 400


class TestNullableUInt32:
    """GET /api/nullable/uint32 — NullableModelBinder<UInt32>（以字符串返回）"""

    def test_valid_max(self):
        r = get("/api/nullable/uint32", params={"n": "4294967295"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "4294967295"

    def test_missing_returns_none(self):
        r = get("/api/nullable/uint32")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_negative_returns_400(self):
        r = get("/api/nullable/uint32", params={"n": "-1"})
        assert r.status_code == 400


class TestNullableUInt64:
    """GET /api/nullable/uint64 — NullableModelBinder<UInt64>（以字符串返回）"""

    def test_valid_max(self):
        r = get("/api/nullable/uint64", params={"n": "18446744073709551615"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "18446744073709551615"

    def test_zero(self):
        r = get("/api/nullable/uint64", params={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_missing_returns_none(self):
        r = get("/api/nullable/uint64")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_negative_returns_400(self):
        r = get("/api/nullable/uint64", params={"n": "-1"})
        assert r.status_code == 400


class TestNullableFloat16:
    """GET /api/nullable/float16 — NullableModelBinder<Float16>"""

    def test_valid_value(self):
        r = get("/api/nullable/float16", params={"val": "1.0"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert math.isclose(data["value"], 1.0, rel_tol=1e-2)

    def test_missing_returns_none(self):
        r = get("/api/nullable/float16")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/float16", params={"val": "abc"})
        assert r.status_code == 400


class TestNullableFloat32:
    """GET /api/nullable/float32 — NullableModelBinder<Float32>"""

    def test_valid_value(self):
        r = get("/api/nullable/float32", params={"val": "3.14"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert math.isclose(data["value"], 3.14, rel_tol=1e-5)

    def test_missing_returns_none(self):
        r = get("/api/nullable/float32")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/float32", params={"val": "abc"})
        assert r.status_code == 400


class TestNullableFloat64:
    """GET /api/nullable/float64 — NullableModelBinder<Float64>"""

    def test_valid_value(self):
        r = get("/api/nullable/float64", params={"val": "3.141592653589793"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert math.isclose(data["value"], 3.141592653589793, rel_tol=1e-6)

    def test_negative(self):
        r = get("/api/nullable/float64", params={"val": "-1.5"})
        assert r.status_code == 200
        assert r.json()["value"] == -1.5

    def test_missing_returns_none(self):
        r = get("/api/nullable/float64")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/float64", params={"val": "abc"})
        assert r.status_code == 400


class TestNullableBigInt:
    """GET /api/nullable/bigint — NullableModelBinder<BigInt>（以字符串返回）"""

    def test_large_positive(self):
        r = get("/api/nullable/bigint", params={"n": "99999999999999999999"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "99999999999999999999"

    def test_negative(self):
        r = get("/api/nullable/bigint", params={"n": "-12345678901234567890"})
        assert r.status_code == 200
        assert r.json()["present"] is True

    def test_missing_returns_none(self):
        r = get("/api/nullable/bigint")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/bigint", params={"n": "3.14"})
        assert r.status_code == 400


class TestNullableDecimal:
    """GET /api/nullable/decimal — NullableModelBinder<Decimal>（以字符串返回）"""

    def test_high_precision(self):
        r = get("/api/nullable/decimal", params={"val": "3.141592653589793"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "3.141592653589793"

    def test_integer_decimal(self):
        r = get("/api/nullable/decimal", params={"val": "42"})
        assert r.status_code == 200
        assert r.json()["present"] is True

    def test_missing_returns_none(self):
        r = get("/api/nullable/decimal")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/decimal", params={"val": "abc"})
        assert r.status_code == 400


class TestNullableDateTime:
    """GET /api/nullable/datetime — NullableModelBinder<DateTime>"""

    def test_iso8601_returns_some(self):
        r = get("/api/nullable/datetime", params={"dt": "2025-01-15T10:30:00Z"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert "2025" in data["value"]

    def test_date_only_returns_some(self):
        r = get("/api/nullable/datetime", params={"dt": "2025-06-15"})
        assert r.status_code == 200
        assert r.json()["present"] is True

    def test_missing_returns_none(self):
        r = get("/api/nullable/datetime")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_returns_none(self):
        r = get("/api/nullable/datetime", params={"dt": ""})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/nullable/datetime", params={"dt": "not-a-date"})
        assert r.status_code == 400
