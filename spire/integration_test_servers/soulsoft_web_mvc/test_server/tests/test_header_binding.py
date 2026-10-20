"""
test_header_binding.py — @FromHeader 来源绑定集成测试

覆盖全部 16 种叶子类型 + 代表性 ?T + Array<T>（请求头提取）：
  Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64,
  Float16, Float32, Float64, BigInt, Decimal, String, DateTime,
  ?Int64, ?String, ?Bool, ?DateTime, Array<String>, Array<Int64>

说明：参数名即为 Header 名（框架不区分大小写）
"""

import math
from conftest import get


class TestHeaderString:
    """GET /api/header/string — @FromHeader name: String"""

    def test_valid_value(self):
        r = get("/api/header/string", headers={"name": "Alice"})
        assert r.status_code == 200
        assert r.json()["value"] == "Alice"

    def test_missing_header_returns_empty(self):
        """Header 缺失 → StringModelBinder 返回空字符串"""
        r = get("/api/header/string")
        assert r.status_code == 200
        assert r.json()["value"] == ""

    def test_unicode_value(self):
        """Header 原始值使用 ASCII 安全编码传输；框架按原始 header 值绑定。"""
        encoded_value = "%E5%BC%A0%E4%B8%89"
        r = get("/api/header/string", headers={"name": encoded_value})
        assert r.status_code == 200
        assert r.json()["value"] == encoded_value


class TestHeaderStringNamed:
    """GET /api/header/string-named — @FromHeader(name: "X-Display-Name") value: String"""

    def test_explicit_header_name_binds_value(self):
        r = get("/api/header/string-named", headers={"X-Display-Name": "Alice"})
        assert r.status_code == 200
        assert r.json()["value"] == "Alice"

    def test_explicit_header_name_ignores_parameter_name(self):
        r = get("/api/header/string-named", headers={
            "X-Display-Name": "Custom",
            "value": "ParameterName"
        })
        assert r.status_code == 200
        assert r.json()["value"] == "Custom"

    def test_missing_explicit_header_name_returns_empty(self):
        r = get("/api/header/string-named", headers={"value": "ParameterName"})
        assert r.status_code == 200
        assert r.json()["value"] == ""


class TestHeaderInt64:
    """GET /api/header/int64 — @FromHeader id: Int64"""

    def test_valid_value(self):
        r = get("/api/header/int64", headers={"id": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_negative(self):
        r = get("/api/header/int64", headers={"id": "-100"})
        assert r.status_code == 200
        assert r.json()["value"] == -100

    def test_missing_returns_default(self):
        r = get("/api/header/int64")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/header/int64", headers={"id": "abc"})
        assert r.status_code == 400


class TestHeaderInt32:
    """GET /api/header/int32 — @FromHeader n: Int32"""

    def test_max_value(self):
        r = get("/api/header/int32", headers={"n": "2147483647"})
        assert r.status_code == 200
        assert r.json()["value"] == 2147483647

    def test_missing_returns_default(self):
        r = get("/api/header/int32")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = get("/api/header/int32", headers={"n": "2147483648"})
        assert r.status_code == 400


class TestHeaderInt8:
    """GET /api/header/int8 — @FromHeader n: Int8"""

    def test_max_value(self):
        r = get("/api/header/int8", headers={"n": "127"})
        assert r.status_code == 200
        assert r.json()["value"] == 127

    def test_min_value(self):
        r = get("/api/header/int8", headers={"n": "-128"})
        assert r.status_code == 200
        assert r.json()["value"] == -128

    def test_missing_returns_default(self):
        r = get("/api/header/int8")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = get("/api/header/int8", headers={"n": "128"})
        assert r.status_code == 400


class TestHeaderInt16:
    """GET /api/header/int16 — @FromHeader n: Int16"""

    def test_max_value(self):
        r = get("/api/header/int16", headers={"n": "32767"})
        assert r.status_code == 200
        assert r.json()["value"] == 32767

    def test_missing_returns_default(self):
        r = get("/api/header/int16")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = get("/api/header/int16", headers={"n": "32768"})
        assert r.status_code == 400


class TestHeaderUInt8:
    """GET /api/header/uint8 — @FromHeader n: UInt8"""

    def test_max_value(self):
        r = get("/api/header/uint8", headers={"n": "255"})
        assert r.status_code == 200
        assert r.json()["value"] == 255

    def test_missing_returns_default(self):
        r = get("/api/header/uint8")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/header/uint8", headers={"n": "-1"})
        assert r.status_code == 400


class TestHeaderUInt16:
    """GET /api/header/uint16 — @FromHeader n: UInt16"""

    def test_max_value(self):
        r = get("/api/header/uint16", headers={"n": "65535"})
        assert r.status_code == 200
        assert r.json()["value"] == 65535

    def test_missing_returns_default(self):
        r = get("/api/header/uint16")
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = get("/api/header/uint16", headers={"n": "-1"})
        assert r.status_code == 400


class TestHeaderUInt32:
    """GET /api/header/uint32 — @FromHeader n: UInt32（以字符串返回）"""

    def test_max_value(self):
        r = get("/api/header/uint32", headers={"n": "4294967295"})
        assert r.status_code == 200
        assert r.json()["value"] == "4294967295"

    def test_zero(self):
        r = get("/api/header/uint32", headers={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_missing_returns_default(self):
        r = get("/api/header/uint32")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = get("/api/header/uint32", headers={"n": "-1"})
        assert r.status_code == 400


class TestHeaderUInt64:
    """GET /api/header/uint64 — @FromHeader n: UInt64（以字符串返回）"""

    def test_max_value(self):
        r = get("/api/header/uint64", headers={"n": "18446744073709551615"})
        assert r.status_code == 200
        assert r.json()["value"] == "18446744073709551615"

    def test_missing_returns_default(self):
        r = get("/api/header/uint64")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = get("/api/header/uint64", headers={"n": "-1"})
        assert r.status_code == 400


class TestHeaderFloat16:
    """GET /api/header/float16 — @FromHeader val: Float16"""

    def test_valid_value(self):
        r = get("/api/header/float16", headers={"val": "1.0"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 1.0, rel_tol=1e-2)

    def test_missing_returns_default(self):
        r = get("/api/header/float16")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = get("/api/header/float16", headers={"val": "abc"})
        assert r.status_code == 400


class TestHeaderFloat32:
    """GET /api/header/float32 — @FromHeader val: Float32"""

    def test_valid_value(self):
        r = get("/api/header/float32", headers={"val": "3.14"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.14, rel_tol=1e-5)

    def test_missing_returns_default(self):
        r = get("/api/header/float32")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = get("/api/header/float32", headers={"val": "abc"})
        assert r.status_code == 400


class TestHeaderFloat64:
    """GET /api/header/float64 — @FromHeader val: Float64"""

    def test_valid_value(self):
        r = get("/api/header/float64", headers={"val": "3.141592653589793"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.141592653589793, rel_tol=1e-6)

    def test_missing_returns_default(self):
        r = get("/api/header/float64")
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = get("/api/header/float64", headers={"val": "abc"})
        assert r.status_code == 400


class TestHeaderBigInt:
    """GET /api/header/bigint — @FromHeader n: BigInt（以字符串返回）"""

    def test_large_value(self):
        r = get("/api/header/bigint", headers={"n": "99999999999999999999"})
        assert r.status_code == 200
        assert r.json()["value"] == "99999999999999999999"

    def test_negative(self):
        r = get("/api/header/bigint", headers={"n": "-12345678901234567890"})
        assert r.status_code == 200
        assert r.json()["value"] == "-12345678901234567890"

    def test_missing_returns_default(self):
        r = get("/api/header/bigint")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = get("/api/header/bigint", headers={"n": "3.14"})
        assert r.status_code == 400


class TestHeaderDecimal:
    """GET /api/header/decimal — @FromHeader val: Decimal（以字符串返回）"""

    def test_high_precision(self):
        r = get("/api/header/decimal", headers={"val": "3.141592653589793"})
        assert r.status_code == 200
        assert r.json()["value"] == "3.141592653589793"

    def test_missing_returns_default(self):
        r = get("/api/header/decimal")
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = get("/api/header/decimal", headers={"val": "abc"})
        assert r.status_code == 400


class TestHeaderBool:
    """GET /api/header/bool — @FromHeader flag: Bool"""

    def test_true(self):
        r = get("/api/header/bool", headers={"flag": "true"})
        assert r.status_code == 200
        assert r.json()["value"] is True

    def test_false(self):
        r = get("/api/header/bool", headers={"flag": "false"})
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_missing_returns_default_false(self):
        r = get("/api/header/bool")
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_invalid_returns_400(self):
        r = get("/api/header/bool", headers={"flag": "yes"})
        assert r.status_code == 400


class TestHeaderDateTime:
    """GET /api/header/datetime — @FromHeader dt: DateTime"""

    def test_date_only(self):
        r = get("/api/header/datetime", headers={"dt": "2025-01-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["is_epoch"] is False
        assert "2025" in data["value"]

    def test_iso8601(self):
        r = get("/api/header/datetime", headers={"dt": "2025-06-15T10:30:00Z"})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is False

    def test_missing_returns_epoch(self):
        r = get("/api/header/datetime")
        assert r.status_code == 200
        assert r.json()["is_epoch"] is True

    def test_invalid_returns_400(self):
        r = get("/api/header/datetime", headers={"dt": "not-a-date"})
        assert r.status_code == 400


class TestHeaderNullableInt64:
    """GET /api/header/nullable-int64 — @FromHeader id: ?Int64"""

    def test_valid_returns_some(self):
        r = get("/api/header/nullable-int64", headers={"id": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 42

    def test_missing_returns_none(self):
        r = get("/api/header/nullable-int64")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_invalid_returns_400(self):
        r = get("/api/header/nullable-int64", headers={"id": "abc"})
        assert r.status_code == 400


class TestHeaderNullableString:
    """GET /api/header/nullable-string — @FromHeader name: ?String"""

    def test_valid_returns_some(self):
        r = get("/api/header/nullable-string", headers={"name": "Alice"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "Alice"

    def test_missing_returns_none(self):
        r = get("/api/header/nullable-string")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None


class TestHeaderNullableBool:
    """GET /api/header/nullable-bool — @FromHeader flag: ?Bool"""

    def test_true_returns_some(self):
        r = get("/api/header/nullable-bool", headers={"flag": "true"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] is True

    def test_missing_returns_none(self):
        r = get("/api/header/nullable-bool")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/header/nullable-bool", headers={"flag": "yes"})
        assert r.status_code == 400


class TestHeaderNullableDateTime:
    """GET /api/header/nullable-datetime — @FromHeader dt: ?DateTime"""

    def test_valid_returns_some(self):
        r = get("/api/header/nullable-datetime", headers={"dt": "2025-01-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert "2025" in data["value"]

    def test_missing_returns_none(self):
        r = get("/api/header/nullable-datetime")
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/header/nullable-datetime", headers={"dt": "not-a-date"})
        assert r.status_code == 400


class TestHeaderArrayString:
    """GET /api/header/array-string — @FromHeader tags: Array<String>"""

    def test_single_header(self):
        r = get("/api/header/array-string", headers={"tags": "golang"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == ["golang"]

    def test_missing_returns_empty(self):
        r = get("/api/header/array-string")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []


class TestHeaderArrayInt64:
    """GET /api/header/array-int64 — @FromHeader ids: Array<Int64>"""

    def test_single_header(self):
        r = get("/api/header/array-int64", headers={"ids": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == [42]

    def test_missing_returns_empty(self):
        r = get("/api/header/array-int64")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/header/array-int64", headers={"ids": "abc"})
        assert r.status_code == 400
