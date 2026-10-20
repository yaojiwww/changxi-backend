"""
test_complex_binding.py — ComplexObjectModelBinder / JsonInputFormatter 集成测试

覆盖：
  @FromQuery → ComplexObjectModelBinder (UserDto / HelloModel / FullTypeDto)
  无注解（默认 FromBody）→ JsonInputFormatter (UserDto / HelloModel / FullTypeDto)
  FullTypeDto 覆盖全部 16 种字段类型 + ?T + Array<T>
"""

from conftest import assert_problem_error_key, get, post


class TestComplexFromQuery:
    """GET /api/complex/query — ComplexObjectModelBinder"""

    def test_all_fields_provided(self):
        """所有字段绑定：name, age, email, score, isActive, balance"""
        r = get("/api/complex/query", params={
            "name": "Alice",
            "age": "30",
            "email": "alice@example.com",
            "score": "95.5",
            "isActive": "true",
            "balance": "1234.56"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Alice"
        assert data["age"] == 30
        assert data["email"] == "alice@example.com"
        assert abs(data["score"] - 95.5) < 0.00001
        assert data["isActive"] is True
        assert abs(float(data["balance"]) - 1234.56) < 0.01  # Decimal 内部用 Float 处理，允许微小误差

    def test_only_name_provided(self):
        """部分字段 → 其他字段保留 UserDto 初始值"""
        r = get("/api/complex/query", params={"name": "Bob"})
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Bob"
        assert data["age"] == 0
        assert data["email"] == ""
        assert data["score"] == 0.0
        assert data["isActive"] is False
        assert data["balance"] is None

    def test_no_fields_provided_returns_defaults(self):
        """所有字段缺省 → UserDto 默认值"""
        r = get("/api/complex/query")
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == ""
        assert data["age"] == 0
        assert data["email"] == ""
        assert data["score"] == 0.0
        assert data["isActive"] is False
        assert data["balance"] is None

    def test_empty_name_field(self):
        """名称为空串 → ComplexObjectModelBinder 跳过空串 → 保留初始值"""
        r = get("/api/complex/query", params={"name": "", "age": "10"})
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == ""
        assert data["age"] == 10

    def test_invalid_age_returns_400(self):
        """age 无效值 → PrimitiveModelBinder<Int64> 写入 modelState 错误 → 400"""
        r = get("/api/complex/query", params={"name": "Alice", "age": "abc"})
        assert r.status_code == 400

    def test_invalid_age_reports_property_binding_name(self):
        r = get("/api/complex/query", params={"name": "Alice", "age": "abc"})
        messages = assert_problem_error_key(r, "age")
        assert "not valid for age" in messages[0]

    def test_invalid_score_returns_400(self):
        """score 无效值 → 400"""
        r = get("/api/complex/query", params={"name": "Alice", "score": "abc"})
        assert r.status_code == 400

    def test_invalid_isActive_returns_400(self):
        """isActive 无效值 → 400"""
        r = get("/api/complex/query", params={"name": "Alice", "isActive": "yes"})
        assert r.status_code == 400

    def test_unicode_name(self):
        r = get("/api/complex/query", params={"name": "张三", "age": "28"})
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "张三"
        assert data["age"] == 28


class TestComplexFromBody:
    """POST /api/complex/body — JsonInputFormatter（默认 FromBody）"""

    def test_full_json_body(self):
        r = post("/api/complex/body", json={
            "name": "Alice",
            "age": 30,
            "email": "alice@example.com",
            "score": 95.5,
            "isActive": True,
            "balance": "1234.56"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Alice"
        assert data["age"] == 30
        assert data["email"] == "alice@example.com"
        assert abs(data["score"] - 95.5) < 0.00001
        assert data["isActive"] is True
        assert abs(float(data["balance"]) - 1234.56) < 0.01  # Decimal 内部用 Float 处理，允许微小误差

    def test_empty_json_body(self):
        """空 JSON 对象 → 保留 UserDto 初始值"""
        r = post("/api/complex/body", json={})
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == ""
        assert data["age"] == 0
        assert data["email"] == ""
        assert data["balance"] is None

    def test_partial_json_body(self):
        r = post("/api/complex/body", json={"name": "Carol", "score": 88.5})
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "Carol"
        assert data["age"] == 0
        assert data["score"] == 88.5

    def test_wrong_content_type_returns_415(self):
        """非 JSON Content-Type → UnsupportedContentTypeException → 415"""
        r = post(
            "/api/complex/body",
            data="name=Alice&age=30",
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        assert r.status_code == 415

    def test_negative_age(self):
        r = post("/api/complex/body", json={"name": "Dave", "age": -5})
        assert r.status_code == 200
        data = r.json()
        assert data["age"] == -5

    def test_invalid_body_age_reports_json_path(self):
        r = post("/api/complex/body", json={"name": "Alice", "age": "abc"})
        messages = assert_problem_error_key(r, "age")
        assert "The 'age' field" in messages[0]


class TestComplexBindingComparison:
    """对比 FromQuery vs FromBody 绑定结果的一致性"""

    def test_same_result_from_query_and_body(self):
        query_r = get("/api/complex/query", params={"name": "Eve", "age": "99"})
        body_r = post("/api/complex/body", json={"name": "Eve", "age": 99})
        assert query_r.status_code == 200
        assert body_r.status_code == 200
        assert query_r.json() == body_r.json()


class TestJsonPropertyNameFromQuery:
    """GET /api/complex/json-property-name-query — JsonPropertyName 映射名 via ComplexObjectModelBinder"""

    def test_json_property_name_mapped_names_are_used_for_query_binding(self):
        response = get("/api/complex/json-property-name-query", params={
            "user_name": "Alice",
            "page_no": "2",
            "keyword": "mvc"
        })
        assert response.status_code == 200
        payload = response.json()
        assert payload["userName"] == "Alice"
        assert payload["pageNo"] == 2
        assert payload["keyword"] == "mvc"

    def test_property_names_do_not_bind_mapped_fields(self):
        response = get("/api/complex/json-property-name-query", params={
            "userName": "Alice",
            "pageNo": "2",
            "keyword": "mvc"
        })
        assert response.status_code == 200
        payload = response.json()
        assert payload["userName"] == ""
        assert payload["pageNo"] == 0
        assert payload["keyword"] == "mvc"

    def test_invalid_mapped_query_field_reports_json_property_name(self):
        response = get("/api/complex/json-property-name-query", params={
            "user_name": "Alice",
            "page_no": "abc",
            "keyword": "mvc"
        })
        messages = assert_problem_error_key(response, "page_no")
        assert "not valid for page_no" in messages[0]


class TestInheritanceFromQuery:
    """
    GET /api/complex/inheritance-query — 继承场景测试
    PageModel (父类: pageIndex, pageSize) + HelloModel (子类: id, age, name)
    注意：Cangjie反射默认不会反射父类字段，需验证 pageIndex/pageSize 是否能绑定
    """

    def test_all_fields_including_parent(self):
        """提供所有字段（父类+子类）"""
        r = get("/api/complex/inheritance-query", params={
            "id": "100",
            "age": "25",
            "name": "Test",
            "pageIndex": "1",
            "pageSize": "20"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 100
        assert data["age"] == 25
        assert data["name"] == "Test"
        # 验证父类字段
        assert data["pageIndex"] == 1
        assert data["pageSize"] == 20

    def test_only_child_fields(self):
        """只提供子类字段 → 父类字段保持默认值"""
        r = get("/api/complex/inheritance-query", params={
            "id": "200",
            "name": "Hello"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 200
        assert data["name"] == "Hello"
        assert data["age"] is None  # age 是可空类型，默认 None
        # 父类字段默认值
        assert data["pageIndex"] == 0
        assert data["pageSize"] == 0

    def test_no_fields_provided(self):
        """不提供任何字段 → 全部保持默认值"""
        r = get("/api/complex/inheritance-query")
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 10  # 子类默认值
        assert data["age"] is None
        assert data["name"] == ""
        assert data["pageIndex"] == 0
        assert data["pageSize"] == 0


class TestInheritanceFromBody:
    """
    POST /api/complex/inheritance-body — 继承场景 FromBody 测试
    """

    def test_all_fields_including_parent(self):
        """JSON body 包含父类+子类字段"""
        r = post("/api/complex/inheritance-body", json={
            "id": 100,
            "age": 25,
            "name": "Test",
            "pageIndex": 1,
            "pageSize": 20
        })
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 100
        assert data["age"] == 25
        assert data["name"] == "Test"
        assert data["pageIndex"] == 1
        assert data["pageSize"] == 20

    def test_partial_fields(self):
        """部分字段 → 其他字段保持默认值"""
        r = post("/api/complex/inheritance-body", json={
            "id": 200,
            "name": "Hello"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 200
        assert data["name"] == "Hello"
        assert data["age"] is None
        assert data["pageIndex"] == 0
        assert data["pageSize"] == 0

    def test_empty_body(self):
        """空 body → 全部默认值"""
        r = post("/api/complex/inheritance-body", json={})
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 10
        assert data["age"] is None
        assert data["name"] == ""
        assert data["pageIndex"] == 0
        assert data["pageSize"] == 0


class TestOverridePropertyFromQuery:
    """
    GET /api/complex/override-query — override 同名属性回归测试
    该路径会在服务端检测 DataModelStruct 中是否出现重复 keyword 字段，
    未修复 ReflectUtilities 时应触发 400，修复后返回 200。
    """

    def test_override_property_and_parent_fields_bind_successfully(self):
        r = get("/api/complex/override-query", params={
            "tenantId": "tenant-a",
            "pageIndex": "3",
            "orderBy": "updatedAt",
            "keyword": "child-only"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["tenantId"] == "tenant-a"
        assert data["pageIndex"] == 3
        assert data["orderBy"] == "updatedAt"
        assert data["keyword"] == "child-only"

    def test_override_property_defaults_when_no_fields_provided(self):
        r = get("/api/complex/override-query")
        assert r.status_code == 200
        data = r.json()
        assert data["tenantId"] == "tenant-default"
        assert data["pageIndex"] == 0
        assert data["orderBy"] == "createdAt"
        assert data["keyword"] == "child-keyword-default"


class TestOverridePropertyFromBody:
    """POST /api/complex/override-body — override 同名属性的 JSON 反序列化场景"""

    def test_override_property_body_binding(self):
        r = post("/api/complex/override-body", json={
            "tenantId": "tenant-b",
            "pageIndex": 7,
            "orderBy": "priority",
            "keyword": "body-keyword"
        })
        assert r.status_code == 200
        data = r.json()
        assert data["tenantId"] == "tenant-b"
        assert data["pageIndex"] == 7
        assert data["orderBy"] == "priority"
        assert data["keyword"] == "body-keyword"

    def test_override_property_body_defaults(self):
        r = post("/api/complex/override-body", json={})
        assert r.status_code == 200
        data = r.json()
        assert data["tenantId"] == "tenant-default"
        assert data["pageIndex"] == 0
        assert data["orderBy"] == "createdAt"
        assert data["keyword"] == "child-keyword-default"


# ── FullTypeDto 全类型覆盖 ────────────────────────────────────────────────────

_FULL_QUERY_PARAMS = {
    "boolVal": "true",
    "int8Val": "127",
    "int16Val": "32767",
    "int32Val": "2147483647",
    "int64Val": "9223372036854775807",
    "uint8Val": "255",
    "uint16Val": "65535",
    "uint32Val": "4294967295",
    "uint64Val": "9223372036854775807",
    "float16Val": "1.0",
    "float32Val": "3.14",
    "float64Val": "2.718281828",
    "bigIntVal": "999999999999999999",
    "decimalVal": "3.141592653589793",
    "strVal": "hello",
    "dtVal": "2025-01-15",
    "optInt64": "42",
    "strArr": ["a", "b"],
    "int64Arr": ["1", "2"],
}

_FULL_BODY_PAYLOAD = {
    "boolVal": True,
    "int8Val": 127,
    "int16Val": 32767,
    "int32Val": 2147483647,
    "int64Val": 9223372036854775807,
    "uint8Val": 255,
    "uint16Val": 65535,
    "uint32Val": 4294967295,
    "uint64Val": 9223372036854775807,
    "float16Val": 1.0,
    "float32Val": 3.14,
    "float64Val": 2.718281828,
    "bigIntVal": "999999999999999999",
    "decimalVal": "3.141592653589793",
    "strVal": "hello",
    "dtVal": "2025-01-15T00:00:00Z",
    "optInt64": 42,
    "strArr": ["a", "b"],
    "int64Arr": [1, 2],
}


class TestFullTypeFromQuery:
    """GET /api/complex/full-query — FullTypeDto via ComplexObjectModelBinder（全 16 种字段）"""

    def test_all_fields_provided(self):
        r = get("/api/complex/full-query", params=_FULL_QUERY_PARAMS)
        assert r.status_code == 200
        data = r.json()
        assert data["boolVal"] is True
        assert data["int8Val"] == 127
        assert data["int16Val"] == 32767
        assert data["int32Val"] == 2147483647
        assert data["int64Val"] == 9223372036854775807
        assert data["uint8Val"] == 255
        assert data["uint16Val"] == 65535
        assert data["uint32Val"] == "4294967295"
        assert data["uint64Val"] == "9223372036854775807"
        assert data["bigIntVal"] == "999999999999999999"
        assert abs(float(data["decimalVal"]) - 3.141592653589793) < 1e-6  # Decimal 内部用 Float 处理
        assert data["strVal"] == "hello"
        assert "2025" in data["dtVal"]
        assert data["optInt64"] == 42
        assert data["strArr"] == ["a", "b"]
        assert data["int64Arr"] == [1, 2]

    def test_no_fields_returns_defaults(self):
        """所有字段缺省 → FullTypeDto 初始值"""
        r = get("/api/complex/full-query")
        assert r.status_code == 200
        data = r.json()
        assert data["boolVal"] is False
        assert data["int64Val"] == 0
        assert data["strVal"] == ""
        assert data["optInt64"] is None
        assert data["strArr"] == []
        assert data["int64Arr"] == []

    def test_invalid_int8_returns_400(self):
        r = get("/api/complex/full-query", params={"int8Val": "999"})
        assert r.status_code == 400

    def test_invalid_bool_returns_400(self):
        r = get("/api/complex/full-query", params={"boolVal": "yes"})
        assert r.status_code == 400

    def test_invalid_decimal_returns_400(self):
        r = get("/api/complex/full-query", params={"decimalVal": "not_a_decimal"})
        assert r.status_code == 400


class TestFullTypeFromBody:
    """POST /api/complex/full-body — FullTypeDto via JsonInputFormatter（全 16 种字段）"""

    def test_all_fields_provided(self):
        r = post("/api/complex/full-body", json=_FULL_BODY_PAYLOAD)
        assert r.status_code == 200
        data = r.json()
        assert data["boolVal"] is True
        assert data["int8Val"] == 127
        assert data["int16Val"] == 32767
        assert data["int32Val"] == 2147483647
        assert data["int64Val"] == 9223372036854775807
        assert data["uint8Val"] == 255
        assert data["uint16Val"] == 65535
        assert data["bigIntVal"] == "999999999999999999"
        assert abs(float(data["decimalVal"]) - 3.141592653589793) < 1e-6  # Decimal 内部用 Float 处理
        assert data["strVal"] == "hello"
        assert data["optInt64"] == 42
        assert data["strArr"] == ["a", "b"]
        assert data["int64Arr"] == [1, 2]

    def test_empty_body_returns_defaults(self):
        """空 JSON → 全部默认值"""
        r = post("/api/complex/full-body", json={})
        assert r.status_code == 200
        data = r.json()
        assert data["boolVal"] is False
        assert data["int64Val"] == 0
        assert data["strVal"] == ""
        assert data["optInt64"] is None
        assert data["strArr"] == []

    def test_partial_fields(self):
        """部分字段 → 其他字段保留默认值"""
        r = post("/api/complex/full-body", json={"strVal": "partial", "int64Val": 99})
        assert r.status_code == 200
        data = r.json()
        assert data["strVal"] == "partial"
        assert data["int64Val"] == 99
        assert data["boolVal"] is False

    def test_opt_int64_null(self):
        """optInt64 为 null → None"""
        r = post("/api/complex/full-body", json={"optInt64": None})
        assert r.status_code == 200
        assert r.json()["optInt64"] is None

    def test_array_fields(self):
        """strArr 和 int64Arr 可正常反序列化"""
        r = post("/api/complex/full-body", json={"strArr": ["x", "y", "z"], "int64Arr": [10, 20]})
        assert r.status_code == 200
        data = r.json()
        assert data["strArr"] == ["x", "y", "z"]
        assert data["int64Arr"] == [10, 20]
