"""
test_string_binding.py -- StringModelBinder integration tests

Coverage:
  - missing key    -> empty string ""
  - empty value    -> empty string ""
  - valid string   -> returned as-is
  - URL-encoded chars
  - length helper endpoint
"""

from conftest import get


class TestStringEcho:
    """GET /api/string/echo -- StringModelBinder"""

    def test_valid_string(self):
        r = get("/api/string/echo", params={"name": "hello"})
        assert r.status_code == 200
        assert r.json()["value"] == "hello"

    def test_missing_key_returns_empty(self):
        """missing key -> StringModelBinder returns String.empty -> \"\" """
        r = get("/api/string/echo")
        assert r.status_code == 200
        assert r.json()["value"] == ""

    def test_empty_value_returns_empty(self):
        """empty string value -> StringModelBinder returns String.empty"""
        r = get("/api/string/echo", params={"name": ""})
        assert r.status_code == 200
        assert r.json()["value"] == ""

    def test_string_with_spaces(self):
        """string with spaces (URL auto-encoded)"""
        r = get("/api/string/echo", params={"name": "hello world"})
        assert r.status_code == 200
        assert r.json()["value"] == "hello world"

    def test_unicode_string(self):
        """unicode string"""
        r = get("/api/string/echo", params={"name": "\u4f60\u597d\u4e16\u754c"})
        assert r.status_code == 200
        assert r.json()["value"] == "\u4f60\u597d\u4e16\u754c"

    def test_numeric_string(self):
        """numeric string is still returned as string"""
        r = get("/api/string/echo", params={"name": "12345"})
        assert r.status_code == 200
        assert r.json()["value"] == "12345"

    def test_special_characters(self):
        """special ASCII characters"""
        r = get("/api/string/echo", params={"name": "foo-bar_baz"})
        assert r.status_code == 200
        assert r.json()["value"] == "foo-bar_baz"


class TestStringLength:
    """GET /api/string/length -- verify both value and length fields"""

    def test_length_of_hello(self):
        r = get("/api/string/length", params={"s": "hello"})
        assert r.status_code == 200
        data = r.json()
        assert data["value"] == "hello"
        assert data["length"] == 5

    def test_length_of_empty(self):
        r = get("/api/string/length", params={"s": ""})
        assert r.status_code == 200
        data = r.json()
        assert data["value"] == ""
        assert data["length"] == 0

    def test_length_missing_key(self):
        r = get("/api/string/length")
        assert r.status_code == 200
        data = r.json()
        assert data["value"] == ""
        assert data["length"] == 0

    def test_length_unicode(self):
        """unicode string length (by char count)"""
        r = get("/api/string/length", params={"s": "abc"})
        assert r.status_code == 200
        data = r.json()
        assert data["length"] == 3
