import re


HTTP_METHODS = {"get", "put", "post", "delete", "options", "head", "patch", "trace"}
VALID_SCHEMA_TYPES = {"string", "number", "integer", "boolean", "array", "object", "null"}


def _iter_operations(spec):
    for path, path_item in spec["paths"].items():
        for method, operation in path_item.items():
            if method in HTTP_METHODS:
                yield path, method, operation


def _normalize_component_name(name: str) -> str:
    def _strip_namespace(match: re.Match[str]) -> str:
        token = match.group(0)
        return token.rsplit(".", 1)[-1]

    return re.sub(r"[A-Za-z_][A-Za-z0-9_.]*", _strip_namespace, name)


def _iter_schema_dicts(node, pointer):
    if isinstance(node, dict):
        if "$ref" in node or isinstance(node.get("type"), str):
            yield pointer, node
        for key, value in node.items():
            yield from _iter_schema_dicts(value, f"{pointer}/{key}")
    elif isinstance(node, list):
        for index, value in enumerate(node):
            yield from _iter_schema_dicts(value, f"{pointer}/{index}")


def _find_parameter(operation, *, location, name):
    for parameter in operation.get("parameters", []):
        if parameter.get("in") == location and parameter.get("name") == name:
            return parameter
    raise AssertionError(f"missing parameter {location}:{name}")


def _find_component_name(spec, suffix):
    normalized_suffix = _normalize_component_name(suffix.lstrip("."))
    matches = [
        name
        for name in spec["components"]["schemas"]
        if _normalize_component_name(name).endswith(normalized_suffix)
    ]
    assert matches, f"schema ending with {suffix!r} not found"
    assert len(matches) == 1, f"schema ending with {suffix!r} is ambiguous: {matches}"
    return matches[0]


def _assert_nullable_schema(schema):
    assert schema.get("nullable") is True


def _assert_nullable_ref_schema(schema, ref_suffix: str):
    _assert_nullable_schema(schema)
    assert "allOf" in schema
    assert len(schema["allOf"]) == 1
    assert schema["allOf"][0]["$ref"].endswith(ref_suffix)


def test_all_operations_define_responses(openapi_spec):
    for path, method, operation in _iter_operations(openapi_spec):
        assert "responses" in operation, f"{method.upper()} {path} missing responses"
        assert operation["responses"], f"{method.upper()} {path} has empty responses"


def test_path_templates_match_documented_path_parameters(openapi_spec):
    for path, method, operation in _iter_operations(openapi_spec):
        placeholders = re.findall(r"{([^{}]+)}", path)
        documented = [
            parameter
            for parameter in operation.get("parameters", [])
            if parameter.get("in") == "path"
        ]
        documented_names = [parameter["name"] for parameter in documented]
        assert documented_names == placeholders, (
            f"{method.upper()} {path} path parameters must exactly match template "
            f"placeholders. "
            f"placeholders={placeholders}, documented={documented_names}"
        )
        for parameter in documented:
            assert parameter.get("required") is True, (
                f"{method.upper()} {path} path parameter "
                f"{parameter['name']!r} must declare required=true"
            )


def test_optional_query_parameter_is_not_required_and_is_nullable(openapi_spec):
    operation = openapi_spec["paths"]["/api/params/optional-query"]["get"]
    parameter = _find_parameter(operation, location="query", name="id")

    assert parameter.get("required") is False
    _assert_nullable_schema(parameter["schema"])


def test_header_parameters_use_http_header_names(openapi_spec):
    header_operation = openapi_spec["paths"]["/api/params/header"]["get"]
    multi_header_operation = openapi_spec["paths"]["/api/params/multi-header"]["get"]
    mixed_operation = openapi_spec["paths"]["/api/params/mixed/{userId}"]["get"]

    header_names = {parameter["name"] for parameter in header_operation["parameters"]}
    multi_header_names = {
        parameter["name"] for parameter in multi_header_operation["parameters"]
    }
    mixed_header_names = {
        parameter["name"]
        for parameter in mixed_operation["parameters"]
        if parameter["in"] == "header"
    }

    assert header_names == {"X-Request-ID"}
    assert multi_header_names == {"X-Client-ID", "X-API-Key"}
    assert mixed_header_names == {"X-Token"}


def test_json_payloads_are_described_with_request_body(openapi_spec):
    primitive_body = openapi_spec["paths"]["/api/primitive/body"]["post"]
    complex_body = openapi_spec["paths"]["/api/complex/body"]["post"]

    assert "requestBody" in primitive_body
    assert "requestBody" in complex_body
    assert "parameters" not in primitive_body or not any(
        parameter.get("name") == "id" and parameter.get("in") == "body"
        for parameter in primitive_body["parameters"]
    )
    assert "application/json" in primitive_body["requestBody"]["content"]
    assert "application/json" in complex_body["requestBody"]["content"]


def test_nullable_model_fields_are_marked_nullable(openapi_spec):
    user_dto_name = _find_component_name(openapi_spec, ".UserDto")
    hello_model_name = _find_component_name(openapi_spec, ".HelloModel")
    full_type_name = _find_component_name(openapi_spec, ".FullTypeDto")

    user_dto = openapi_spec["components"]["schemas"][user_dto_name]
    hello_model = openapi_spec["components"]["schemas"][hello_model_name]
    full_type = openapi_spec["components"]["schemas"][full_type_name]

    _assert_nullable_schema(user_dto["properties"]["balance"])
    _assert_nullable_schema(hello_model["properties"]["age"])
    _assert_nullable_schema(full_type["properties"]["optInt64"])
    _assert_nullable_schema(full_type["properties"]["optDateTime"])


def test_datetime_action_result_is_a_string_with_date_time_format(openapi_spec):
    response = openapi_spec["paths"]["/api/response/json-datetime"]["get"]["responses"][
        "200"
    ]
    schema = response["content"]["application/json"]["schema"]

    assert schema["type"] == "string"
    assert schema["format"] == "date-time"


def test_nullable_json_result_of_object_uses_one_of_ref_and_null(openapi_spec):
    response = openapi_spec["paths"]["/api/response/json-nullable-object"]["get"][
        "responses"
    ]["200"]
    schema = response["content"]["application/json"]["schema"]

    _assert_nullable_ref_schema(schema, "/DataItem")


def test_enum_response_includes_declared_string_values(openapi_spec):
    response = openapi_spec["paths"]["/api/response/enum-value"]["get"]["responses"][
        "200"
    ]
    schema = response["content"]["application/json"]["schema"]

    assert schema["type"] == "string"
    assert schema["enum"] == ["Ready", "Failed"]


def test_path_item_ref_is_serialized_as_a_string(openapi_spec):
    path_item = openapi_spec["paths"]["/openapi/path-ref-probe"]

    assert path_item["$ref"] == "#/components/schemas/DataItem"


def test_all_schema_types_use_openapi_primitive_or_composite_types(openapi_spec):
    for pointer, schema in _iter_schema_dicts(openapi_spec, "#"):
        if "type" in schema:
            assert schema["type"] in VALID_SCHEMA_TYPES, (
                f"{pointer} uses invalid OpenAPI schema type {schema['type']!r}"
            )
