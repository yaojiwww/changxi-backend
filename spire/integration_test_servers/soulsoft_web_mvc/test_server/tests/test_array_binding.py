"""
test_array_binding.py — ArrayModelBinder<T> 集成测试

覆盖全部 16 种 Array<T>：
  Array<Bool/Int8/Int16/Int32/Int64/UInt8/UInt16/UInt32/UInt64>
  Array<Float16/Float32/Float64/BigInt/Decimal/String/DateTime>
"""

import math
from conftest import get


class TestArrayInt64:
    """GET /api/array/int64 — ArrayModelBinder<Int64>"""

    def test_no_values_returns_empty_array(self):
        r = get("/api/array/int64")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_value(self):
        r = get("/api/array/int64", params={"ids": "42"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == [42]

    def test_multiple_values(self):
        r = get("/api/array/int64?ids=1&ids=2&ids=3")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [1, 2, 3]

    def test_includes_negative_values(self):
        r = get("/api/array/int64?ids=-1&ids=0&ids=1")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [-1, 0, 1]

    def test_invalid_element_returns_400(self):
        """任一元素无效 → modelState 错误 → 400"""
        r = get("/api/array/int64?ids=1&ids=abc&ids=3")
        assert r.status_code == 400

    def test_single_zero(self):
        r = get("/api/array/int64", params={"ids": "0"})
        assert r.status_code == 200
        assert r.json()["values"] == [0]


class TestArrayString:
    """GET /api/array/string — ArrayModelBinder<String>"""

    def test_no_values_returns_empty_array(self):
        r = get("/api/array/string")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_tag(self):
        r = get("/api/array/string", params={"tags": "golang"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == ["golang"]

    def test_multiple_tags(self):
        r = get("/api/array/string?tags=a&tags=b&tags=c")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == ["a", "b", "c"]

    def test_preserves_order(self):
        r = get("/api/array/string?tags=first&tags=second&tags=third")
        assert r.status_code == 200
        assert r.json()["values"] == ["first", "second", "third"]


class TestArrayBool:
    """GET /api/array/bool — ArrayModelBinder<Bool>"""

    def test_multiple_bool_values(self):
        r = get("/api/array/bool?flags=true&flags=false&flags=true")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [True, False, True]

    def test_no_values(self):
        r = get("/api/array/bool")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_element_returns_400(self):
        r = get("/api/array/bool?flags=true&flags=yes")
        assert r.status_code == 400


class TestArrayFloat64:
    """GET /api/array/float64 — ArrayModelBinder<Float64>"""

    def test_no_values_returns_empty_array(self):
        r = get("/api/array/float64")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_float_value(self):
        r = get("/api/array/float64", params={"vals": "3.14159"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert abs(data["values"][0] - 3.14159) < 0.00001

    def test_multiple_float_values(self):
        r = get("/api/array/float64?vals=1.5&vals=2.5&vals=3.5")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert abs(data["values"][0] - 1.5) < 0.00001
        assert abs(data["values"][1] - 2.5) < 0.00001
        assert abs(data["values"][2] - 3.5) < 0.00001

    def test_negative_float_values(self):
        r = get("/api/array/float64?vals=-1.5&vals=0.0&vals=1.5")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"][0] == -1.5

    def test_invalid_element_returns_400(self):
        r = get("/api/array/float64?vals=1.5&vals=abc")
        assert r.status_code == 400


class TestArrayInt32:
    """GET /api/array/int32 — ArrayModelBinder<Int32>"""

    def test_no_values_returns_empty_array(self):
        r = get("/api/array/int32")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_value(self):
        r = get("/api/array/int32", params={"vals": "100"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"] == [100]

    def test_multiple_values(self):
        r = get("/api/array/int32?vals=100&vals=200&vals=300")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [100, 200, 300]

    def test_overflow_returns_400(self):
        """Int32 溢出 → 400"""
        r = get("/api/array/int32?vals=2147483648")
        assert r.status_code == 400


class TestArrayUInt64:
    """GET /api/array/uint64 — ArrayModelBinder<UInt64>"""

    def test_no_values_returns_empty_array(self):
        r = get("/api/array/uint64")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_max_value(self):
        """UInt64 最大值作为字符串返回"""
        r = get("/api/array/uint64", params={"vals": "18446744073709551615"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["values"][0] == "18446744073709551615"

    def test_multiple_values(self):
        r = get("/api/array/uint64?vals=0&vals=100&vals=999999999999")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == ["0", "100", "999999999999"]

    def test_negative_value_returns_400(self):
        """UInt64 不能接受负值"""
        r = get("/api/array/uint64?vals=-1")
        assert r.status_code == 400


# ── 补全 10 种缺失的 Array<T> ──────────────────────────────────────────────────

class TestArrayInt8:
    """GET /api/array/int8 — ArrayModelBinder<Int8>"""

    def test_no_values(self):
        r = get("/api/array/int8")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_boundary_values(self):
        r = get("/api/array/int8?vals=127&vals=-128&vals=0")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [127, -128, 0]

    def test_overflow_returns_400(self):
        r = get("/api/array/int8?vals=128")
        assert r.status_code == 400


class TestArrayInt16:
    """GET /api/array/int16 — ArrayModelBinder<Int16>"""

    def test_boundary_values(self):
        r = get("/api/array/int16?vals=32767&vals=-32768")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["values"] == [32767, -32768]

    def test_no_values(self):
        r = get("/api/array/int16")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_overflow_returns_400(self):
        r = get("/api/array/int16?vals=32768")
        assert r.status_code == 400


class TestArrayUInt8:
    """GET /api/array/uint8 — ArrayModelBinder<UInt8>"""

    def test_boundary_values(self):
        r = get("/api/array/uint8?vals=0&vals=128&vals=255")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"] == [0, 128, 255]

    def test_no_values(self):
        r = get("/api/array/uint8")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_negative_returns_400(self):
        r = get("/api/array/uint8?vals=-1")
        assert r.status_code == 400


class TestArrayUInt16:
    """GET /api/array/uint16 — ArrayModelBinder<UInt16>"""

    def test_boundary_values(self):
        r = get("/api/array/uint16?vals=0&vals=65535")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["values"] == [0, 65535]

    def test_no_values(self):
        r = get("/api/array/uint16")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_negative_returns_400(self):
        r = get("/api/array/uint16?vals=-1")
        assert r.status_code == 400


class TestArrayUInt32:
    """GET /api/array/uint32 — ArrayModelBinder<UInt32>（以字符串返回）"""

    def test_boundary_values(self):
        r = get("/api/array/uint32?vals=0&vals=4294967295")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["values"] == ["0", "4294967295"]

    def test_no_values(self):
        r = get("/api/array/uint32")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_negative_returns_400(self):
        r = get("/api/array/uint32?vals=-1")
        assert r.status_code == 400


class TestArrayFloat16:
    """GET /api/array/float16 — ArrayModelBinder<Float16>"""

    def test_valid_values(self):
        r = get("/api/array/float16?vals=1.0&vals=2.0")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert math.isclose(data["values"][0], 1.0, rel_tol=1e-2)
        assert math.isclose(data["values"][1], 2.0, rel_tol=1e-2)

    def test_no_values(self):
        r = get("/api/array/float16")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/array/float16?vals=abc")
        assert r.status_code == 400


class TestArrayFloat32:
    """GET /api/array/float32 — ArrayModelBinder<Float32>"""

    def test_valid_values(self):
        r = get("/api/array/float32?vals=1.5&vals=2.5")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert math.isclose(data["values"][0], 1.5, rel_tol=1e-5)
        assert math.isclose(data["values"][1], 2.5, rel_tol=1e-5)

    def test_no_values(self):
        r = get("/api/array/float32")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/array/float32?vals=abc")
        assert r.status_code == 400


class TestArrayBigInt:
    """GET /api/array/bigint — ArrayModelBinder<BigInt>（以字符串返回）"""

    def test_large_values(self):
        r = get("/api/array/bigint?vals=999999999999999999&vals=0&vals=-999999999999999999")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["values"][0] == "999999999999999999"
        assert data["values"][1] == "0"
        assert data["values"][2] == "-999999999999999999"

    def test_no_values(self):
        r = get("/api/array/bigint")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/array/bigint?vals=3.14")
        assert r.status_code == 400


class TestArrayDecimal:
    """GET /api/array/decimal — ArrayModelBinder<Decimal>（以字符串返回）"""

    def test_valid_values(self):
        r = get("/api/array/decimal?vals=3.14&vals=2.71")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["values"][0] == "3.14"
        assert data["values"][1] == "2.71"

    def test_no_values(self):
        r = get("/api/array/decimal")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/array/decimal?vals=abc")
        assert r.status_code == 400


class TestArrayDateTime:
    """GET /api/array/datetime — ArrayModelBinder<DateTime>"""

    def test_valid_dates(self):
        r = get("/api/array/datetime?vals=2025-01-01&vals=2025-06-15")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert "2025" in data["values"][0]
        assert "2025" in data["values"][1]

    def test_no_values(self):
        r = get("/api/array/datetime")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_invalid_returns_400(self):
        r = get("/api/array/datetime?vals=not-a-date")
        assert r.status_code == 400

    def test_mixed_valid_invalid_returns_400(self):
        r = get("/api/array/datetime?vals=2025-01-01&vals=invalid")
        assert r.status_code == 400


