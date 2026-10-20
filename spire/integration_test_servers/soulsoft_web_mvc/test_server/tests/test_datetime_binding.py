"""
test_datetime_binding.py — DateTimeModelBinder 集成测试

覆盖：
  DateTime 多格式：键缺失/空串 → UnixEpoch；ISO 8601；yyyy-MM-dd HH:mm:ss；
                   yyyy-MM-dd；RFC1123；无效格式 → 400
  ?DateTime (NullableModelBinder)：缺失→None；有效→Some；无效→400
  Array<DateTime>：空数组；多值；无效→400
  /formats 端点：明确测试每种格式的解析行为
"""

from conftest import get


class TestDateTimeDefault:
    """缺省情况下返回 UnixEpoch"""

    def test_missing_key_returns_epoch(self):
        r = get("/api/datetime/echo")
        assert r.status_code == 200
        assert r.json()["is_epoch"] is True

    def test_empty_value_returns_epoch(self):
        r = get("/api/datetime/echo", params={"dt": ""})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is True


class TestDateTimeISO8601:
    """ISO 8601 格式（DateTime.tryParse 默认支持）"""

    def test_iso8601_utc(self):
        r = get("/api/datetime/echo", params={"dt": "2025-01-15T10:30:00Z"})
        assert r.status_code == 200
        data = r.json()
        assert data["is_epoch"] is False
        assert "2025" in data["value"]

    def test_iso8601_with_offset(self):
        r = get("/api/datetime/echo", params={"dt": "2025-06-01T00:00:00+08:00"})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is False


class TestDateTimeCustomFormats:
    """自定义格式（yyyy-MM-dd HH:mm:ss / yyyy-MM-dd）"""

    def test_datetime_with_time(self):
        """yyyy-MM-dd HH:mm:ss"""
        r = get("/api/datetime/year", params={"dt": "2025-01-15 10:30:00"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2025
        assert data["month"] == 1

    def test_date_only(self):
        """yyyy-MM-dd"""
        r = get("/api/datetime/year", params={"dt": "2025-06-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2025
        assert data["month"] == 6
        assert data["day"] == 15

    def test_date_only_different_year(self):
        r = get("/api/datetime/year", params={"dt": "2000-12-31"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2000
        assert data["month"] == 12
        assert data["day"] == 31


class TestDateTimeInvalid:
    """无效格式 → 400"""

    def test_invalid_string_returns_400(self):
        r = get("/api/datetime/echo", params={"dt": "not-a-date"})
        assert r.status_code == 400

    def test_random_text_returns_400(self):
        r = get("/api/datetime/echo", params={"dt": "hello"})
        assert r.status_code == 400

    def test_partial_date_returns_400(self):
        """只有年份通常不能解析"""
        r = get("/api/datetime/echo", params={"dt": "2025"})
        assert r.status_code == 400


class TestNullableDateTimeBinding:
    """GET /api/datetime/nullable — NullableModelBinder<DateTime>"""

    def test_iso8601_returns_some(self):
        r = get("/api/datetime/nullable", params={"dt": "2025-01-15T10:30:00Z"})
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is True
        assert "2025" in data["value"]

    def test_date_only_returns_some(self):
        r = get("/api/datetime/nullable", params={"dt": "2025-06-15"})
        assert r.status_code == 200
        assert r.json()["present"] is True

    def test_missing_returns_none(self):
        r = get("/api/datetime/nullable")
        assert r.status_code == 200
        data = r.json()
        assert data["present"] is False
        assert data["value"] is None

    def test_empty_returns_none(self):
        r = get("/api/datetime/nullable", params={"dt": ""})
        assert r.status_code == 200
        assert r.json()["present"] is False

    def test_invalid_returns_400(self):
        r = get("/api/datetime/nullable", params={"dt": "not-a-date"})
        assert r.status_code == 400


class TestDateTimeArray:
    """GET /api/datetime/array — ArrayModelBinder<DateTime>"""

    def test_no_values_returns_empty(self):
        r = get("/api/datetime/array")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["values"] == []

    def test_single_value(self):
        r = get("/api/datetime/array", params={"vals": "2025-01-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert "2025" in data["values"][0]

    def test_multiple_values(self):
        r = get("/api/datetime/array?vals=2025-01-01&vals=2025-06-15T10:30:00Z")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert "2025" in data["values"][0]
        assert "2025" in data["values"][1]

    def test_invalid_element_returns_400(self):
        r = get("/api/datetime/array?vals=2025-01-01&vals=invalid")
        assert r.status_code == 400


class TestDateTimeFormatsExplicit:
    """GET /api/datetime/formats — 明确测试每种格式的解析行为"""

    def test_date_only_format(self):
        """yyyy-MM-dd → 解析年份正确"""
        r = get("/api/datetime/formats", params={"dt": "2025-06-15"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2025
        assert data["is_epoch"] is False

    def test_datetime_with_space(self):
        """yyyy-MM-dd HH:mm:ss → 解析成功"""
        r = get("/api/datetime/formats", params={"dt": "2025-01-15 10:30:00"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2025
        assert data["is_epoch"] is False

    def test_iso8601_with_z(self):
        """ISO 8601 UTC → 解析成功"""
        r = get("/api/datetime/formats", params={"dt": "2025-03-20T08:00:00Z"})
        assert r.status_code == 200
        data = r.json()
        assert data["year"] == 2025
        assert data["is_epoch"] is False

    def test_iso8601_with_offset(self):
        """ISO 8601 带时区偏移 → 解析成功"""
        r = get("/api/datetime/formats", params={"dt": "2025-06-01T00:00:00+08:00"})
        assert r.status_code == 200
        assert r.json()["is_epoch"] is False

    def test_missing_key_returns_epoch(self):
        """键缺失 → UnixEpoch"""
        r = get("/api/datetime/formats")
        assert r.status_code == 200
        assert r.json()["is_epoch"] is True

    def test_invalid_returns_400(self):
        r = get("/api/datetime/formats", params={"dt": "not-a-date"})
        assert r.status_code == 400
