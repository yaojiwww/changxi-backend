"""
test_form_primitive_binding.py — @FromForm 基础类型绑定集成测试

覆盖全部 16 种叶子类型 + 代表性 ?T + Array<T>（表单字段提取）：
  Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64,
  Float16, Float32, Float64, BigInt, Decimal, String, DateTime,
  ?Int64, ?String, ?Bool, ?DateTime,
  Array<String>, Array<Int64>, Array<Bool>, Array<Float64>
  以及多参数混合端点

Content-Type: application/x-www-form-urlencoded
"""

import math
from conftest import post


class TestFormString:
    """POST /api/form/string — @FromForm s: String"""

    def test_valid_value(self):
        r = post("/api/form/string", data={"s": "hello"})
        assert r.status_code == 200
        assert r.json()["value"] == "hello"

    def test_missing_returns_empty(self):
        r = post("/api/form/string", data={})
        assert r.status_code == 200
        assert r.json()["value"] == ""

    def test_unicode_value(self):
        r = post("/api/form/string", data={"s": "你好世界"})
        assert r.status_code == 200
        assert r.json()["value"] == "你好世界"


class TestFormInt64:
    """POST /api/form/int64 — @FromForm n: Int64"""

    def test_valid_positive(self):
        r = post("/api/form/int64", data={"n": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_valid_negative(self):
        r = post("/api/form/int64", data={"n": "-100"})
        assert r.status_code == 200
        assert r.json()["value"] == -100

    def test_max_value(self):
        r = post("/api/form/int64", data={"n": "9223372036854775807"})
        assert r.status_code == 200
        assert r.json()["value"] == 9223372036854775807

    def test_missing_returns_default(self):
        r = post("/api/form/int64", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_invalid_returns_400(self):
        r = post("/api/form/int64", data={"n": "abc"})
        assert r.status_code == 400

    def test_overflow_returns_400(self):
        r = post("/api/form/int64", data={"n": "99999999999999999999"})
        assert r.status_code == 400


class TestFormInt32:
    """POST /api/form/int32 — @FromForm n: Int32"""

    def test_max_value(self):
        r = post("/api/form/int32", data={"n": "2147483647"})
        assert r.status_code == 200
        assert r.json()["value"] == 2147483647

    def test_missing_returns_default(self):
        r = post("/api/form/int32", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = post("/api/form/int32", data={"n": "2147483648"})
        assert r.status_code == 400


class TestFormInt8:
    """POST /api/form/int8 — @FromForm n: Int8"""

    def test_max_value(self):
        r = post("/api/form/int8", data={"n": "127"})
        assert r.status_code == 200
        assert r.json()["value"] == 127

    def test_min_value(self):
        r = post("/api/form/int8", data={"n": "-128"})
        assert r.status_code == 200
        assert r.json()["value"] == -128

    def test_missing_returns_default(self):
        r = post("/api/form/int8", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = post("/api/form/int8", data={"n": "128"})
        assert r.status_code == 400


class TestFormInt16:
    """POST /api/form/int16 — @FromForm n: Int16"""

    def test_max_value(self):
        r = post("/api/form/int16", data={"n": "32767"})
        assert r.status_code == 200
        assert r.json()["value"] == 32767

    def test_missing_returns_default(self):
        r = post("/api/form/int16", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_overflow_returns_400(self):
        r = post("/api/form/int16", data={"n": "32768"})
        assert r.status_code == 400


class TestFormUInt8:
    """POST /api/form/uint8 — @FromForm n: UInt8"""

    def test_max_value(self):
        r = post("/api/form/uint8", data={"n": "255"})
        assert r.status_code == 200
        assert r.json()["value"] == 255

    def test_missing_returns_default(self):
        r = post("/api/form/uint8", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = post("/api/form/uint8", data={"n": "-1"})
        assert r.status_code == 400


class TestFormUInt16:
    """POST /api/form/uint16 — @FromForm n: UInt16"""

    def test_max_value(self):
        r = post("/api/form/uint16", data={"n": "65535"})
        assert r.status_code == 200
        assert r.json()["value"] == 65535

    def test_missing_returns_default(self):
        r = post("/api/form/uint16", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_negative_returns_400(self):
        r = post("/api/form/uint16", data={"n": "-1"})
        assert r.status_code == 400


class TestFormUInt32:
    """POST /api/form/uint32 — @FromForm n: UInt32（以字符串返回）"""

    def test_max_value(self):
        r = post("/api/form/uint32", data={"n": "4294967295"})
        assert r.status_code == 200
        assert r.json()["value"] == "4294967295"

    def test_zero(self):
        r = post("/api/form/uint32", data={"n": "0"})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_missing_returns_default(self):
        r = post("/api/form/uint32", data={})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = post("/api/form/uint32", data={"n": "-1"})
        assert r.status_code == 400


class TestFormUInt64:
    """POST /api/form/uint64 — @FromForm n: UInt64（以字符串返回）"""

    def test_max_value(self):
        r = post("/api/form/uint64", data={"n": "18446744073709551615"})
        assert r.status_code == 200
        assert r.json()["value"] == "18446744073709551615"

    def test_missing_returns_default(self):
        r = post("/api/form/uint64", data={})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_negative_returns_400(self):
        r = post("/api/form/uint64", data={"n": "-1"})
        assert r.status_code == 400


class TestFormFloat16:
    """POST /api/form/float16 — @FromForm val: Float16"""

    def test_valid_value(self):
        r = post("/api/form/float16", data={"val": "1.0"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 1.0, rel_tol=1e-2)

    def test_missing_returns_default(self):
        r = post("/api/form/float16", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = post("/api/form/float16", data={"val": "abc"})
        assert r.status_code == 400


class TestFormFloat32:
    """POST /api/form/float32 — @FromForm val: Float32"""

    def test_valid_value(self):
        r = post("/api/form/float32", data={"val": "3.14"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.14, rel_tol=1e-5)

    def test_missing_returns_default(self):
        r = post("/api/form/float32", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = post("/api/form/float32", data={"val": "abc"})
        assert r.status_code == 400


class TestFormFloat64:
    """POST /api/form/float64 — @FromForm val: Float64"""

    def test_valid_value(self):
        r = post("/api/form/float64", data={"val": "3.141592653589793"})
        assert r.status_code == 200
        assert math.isclose(r.json()["value"], 3.141592653589793, rel_tol=1e-6)

    def test_missing_returns_default(self):
        r = post("/api/form/float64", data={})
        assert r.status_code == 200
        assert r.json()["value"] == 0.0

    def test_invalid_returns_400(self):
        r = post("/api/form/float64", data={"val": "abc"})
        assert r.status_code == 400


class TestFormBigInt:
    """POST /api/form/bigint — @FromForm n: BigInt（以字符串返回）"""

    def test_large_value(self):
        r = post("/api/form/bigint", data={"n": "99999999999999999999"})
        assert r.status_code == 200
        assert r.json()["value"] == "99999999999999999999"

    def test_negative(self):
        r = post("/api/form/bigint", data={"n": "-12345678901234567890"})
        assert r.status_code == 200
        assert r.json()["value"] == "-12345678901234567890"

    def test_missing_returns_default(self):
        r = post("/api/form/bigint", data={})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = post("/api/form/bigint", data={"n": "3.14"})
        assert r.status_code == 400


class TestFormDecimal:
    """POST /api/form/decimal — @FromForm val: Decimal（以字符串返回）"""

    def test_high_precision(self):
        r = post("/api/form/decimal", data={"val": "3.141592653589793"})
        assert r.status_code == 200
        assert r.json()["value"] == "3.141592653589793"

    def test_missing_returns_default(self):
        r = post("/api/form/decimal", data={})
        assert r.status_code == 200
        assert r.json()["value"] == "0"

    def test_invalid_returns_400(self):
        r = post("/api/form/decimal", data={"val": "abc"})
        assert r.status_code == 400


class TestFormBool:
    """POST /api/form/bool — @FromForm flag: Bool"""

    def test_true(self):
        r = post("/api/form/bool", data={"flag": "true"})
        assert r.status_code == 200
        assert r.json()["value"] is True

    def test_false(self):
        r = post("/api/form/bool", data={"flag": "false"})
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_missing_returns_default_false(self):
        r = post("/api/form/bool", data={})
        assert r.status_code == 200
        assert r.json()["value"] is False

    def test_invalid_returns_400(self):
        r = post("/api/form/bool", data={"flag": "yes"})
        assert r.status_code == 400


class TestFormDateTime:
    """POST /api/form/datetime — @FromForm dt: DateTime"""

    def test_date_only(self):
        r = post("/api/form/datetime", data={"dt": "2025-01-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["is_epoch"] is False
        assert "2025" in data["value"]

    def test_iso8601(self):
        r = post("/api/form/datetime", data={"dt": "2025-06-15T10:30:00Z"})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is False

    def test_missing_returns_epoch(self):
        r = post("/api/form/datetime", data={})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is True

    def test_invalid_returns_400(self):
        r = post("/api/form/datetime", data={"dt": "not-a-date"})
        assert r.status_code == 400


# ── ?T 可选类型 ───────────────────────────────────────────────────────────────

class TestFormNullableInt64:
    """POST /api/form/nullable-int64 — @FromForm n: ?Int64"""

    def test_valid_returns_some(self):
        r = post("/api/form/nullable-int64", data={"n": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == 42

    def test_missing_returns_none(self):
        r = post("/api/form/nullable-int64", data={})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_returns_none(self):
        r = post("/api/form/nullable-int64", data={"n": ""})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = post("/api/form/nullable-int64", data={"n": "abc"})
        assert r.status_code == 400


class TestFormNullableString:
    """POST /api/form/nullable-string — @FromForm s: ?String"""

    def test_valid_returns_some(self):
        r = post("/api/form/nullable-string", data={"s": "hello"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] == "hello"

    def test_missing_returns_none(self):
        r = post("/api/form/nullable-string", data={})
        assert r.status_code == 200
        assert r.json()["present"] is False


class TestFormNullableBool:
    """POST /api/form/nullable-bool — @FromForm flag: ?Bool"""

    def test_true_returns_some(self):
        r = post("/api/form/nullable-bool", data={"flag": "true"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert data["value"] is True

    def test_missing_returns_none(self):
        r = post("/api/form/nullable-bool", data={})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = post("/api/form/nullable-bool", data={"flag": "yes"})
        assert r.status_code == 400


class TestFormNullableDateTime:
    """POST /api/form/nullable-datetime — @FromForm dt: ?DateTime"""

    def test_valid_returns_some(self):
        r = post("/api/form/nullable-datetime", data={"dt": "2025-01-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert "2025" in data["value"]

    def test_missing_returns_none(self):
        r = post("/api/form/nullable-datetime", data={})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = post("/api/form/nullable-datetime", data={"dt": "not-a-date"})
        assert r.status_code == 400


# ── Array<T> ─────────────────────────────────────────────────────────────────

class TestFormArrayString:
    """POST /api/form/array-string — @FromForm tags: Array<String>"""

    def test_multiple_values(self):
        r = post("/api/form/array-string", data=[("tags", "a"), ("tags", "b"), ("tags", "c")])
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == ["a", "b", "c"]

    def test_no_values(self):
        r = post("/api/form/array-string", data={})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_value(self):
        r = post("/api/form/array-string", data={"tags": "only"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == ["only"]


class TestFormArrayInt64:
    """POST /api/form/array-int64 — @FromForm ids: Array<Int64>"""

    def test_multiple_values(self):
        r = post("/api/form/array-int64", data=[("ids", "1"), ("ids", "2"), ("ids", "3")])
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [1, 2, 3]

    def test_no_values(self):
        r = post("/api/form/array-int64", data={})
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_element_returns_400(self):
        r = post("/api/form/array-int64", data=[("ids", "1"), ("ids", "abc")])
        assert r.status_code == 400


class TestFormArrayBool:
    """POST /api/form/array-bool — @FromForm flags: Array<Bool>"""

    def test_multiple_values(self):
        r = post("/api/form/array-bool", data=[("flags", "true"), ("flags", "false")])
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["values"] == [True, False]

    def test_no_values(self):
        r = post("/api/form/array-bool", data={})
        assert r.status_code == 200
        assert r.json()["count"] == 0


class TestFormArrayFloat64:
    """POST /api/form/array-float64 — @FromForm vals: Array<Float64>"""

    def test_multiple_values(self):
        r = post("/api/form/array-float64", data=[("vals", "1.5"), ("vals", "2.5")])
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert math.isclose(data["values"][0], 1.5, rel_tol=1e-6)
        assert math.isclose(data["values"][1], 2.5, rel_tol=1e-6)

    def test_no_values(self):
        r = post("/api/form/array-float64", data={})
        assert r.status_code == 200
        assert r.json()["count"] == 0


# ── 多参数混合端点 ─────────────────────────────────────────────────────────────

class TestFormMulti:
    """POST /api/form/multi — 多参数混合绑定"""

    def test_all_fields_provided(self):
        r = post("/api/form/multi", data={
            "name": "Alice",
            "age": "30",
            "score": "95.5",
            "active": "true",
            "optRank": "1"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Alice"
        assert data["age"] == 30
        assert math.isclose(data["score"], 95.5, rel_tol=1e-6)
        assert data["active"] is True
        assert data["optRank"] == 1

    def test_optional_field_missing(self):
        """optRank 缺失 → None"""
        r = post("/api/form/multi", data={
            "name": "Bob",
            "age": "25",
            "score": "88.0",
            "active": "false"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Bob"
        assert data["optRank"] is None

    def test_invalid_age_returns_400(self):
        r = post("/api/form/multi", data={
            "name": "Eve",
            "age": "abc",
            "score": "90.0",
            "active": "true"
        })
        assert r.status_code == 400
