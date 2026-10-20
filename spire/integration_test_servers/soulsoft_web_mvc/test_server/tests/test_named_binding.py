from conftest import assert_problem_error_key, get, post


class TestNamedQueryBinding:
    def test_explicit_query_name_binds_value(self):
        r = get("/api/primitive/named-int64", params={"type": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_parameter_name_no_longer_matches_when_explicit_name_is_present(self):
        r = get("/api/primitive/named-int64", params={"value": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_explicit_query_name_is_used_for_error_key(self):
        r = get("/api/primitive/named-int64", params={"type": "abc"})
        messages = assert_problem_error_key(r, "type")
        assert "not valid for type" in messages[0]


class TestNamedRouteBinding:
    def test_explicit_route_name_binds_value(self):
        r = get("/api/route/named-int64/42")
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_explicit_route_name_is_used_for_error_key(self):
        r = get("/api/route/named-int64/abc")
        messages = assert_problem_error_key(r, "type")
        assert "not valid for type" in messages[0]


class TestNamedFormBinding:
    def test_explicit_form_name_binds_value(self):
        r = post("/api/form/named-int64", data={"type": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 42

    def test_parameter_name_no_longer_matches_when_explicit_name_is_present(self):
        r = post("/api/form/named-int64", data={"value": "42"})
        assert r.status_code == 200
        assert r.json()["value"] == 0

    def test_explicit_form_name_is_used_for_error_key(self):
        r = post("/api/form/named-int64", data={"type": "abc"})
        messages = assert_problem_error_key(r, "type")
        assert "not valid for type" in messages[0]
