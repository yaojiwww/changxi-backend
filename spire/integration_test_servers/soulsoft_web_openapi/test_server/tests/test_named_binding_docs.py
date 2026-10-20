def _get_operation(spec: dict, path: str, method: str) -> dict:
    assert path in spec["paths"], f"missing path {path}"
    assert method in spec["paths"][path], f"missing operation {method.upper()} {path}"
    return spec["paths"][path][method]


def _find_parameter(operation: dict, *, name: str, location: str) -> dict:
    for parameter in operation.get("parameters", []):
        if parameter.get("name") == name and parameter.get("in") == location:
            return parameter
    raise AssertionError(f"missing parameter {location}:{name}")


def test_named_query_parameter_uses_explicit_name(openapi_spec):
    operation = _get_operation(openapi_spec, "/api/params/query-named", "get")
    parameter = _find_parameter(operation, name="type", location="query")

    assert parameter["required"] is True
    assert parameter["schema"]["type"] == "integer"
    assert parameter["schema"]["format"] == "int64"


def test_named_path_parameter_uses_explicit_name(openapi_spec):
    operation = _get_operation(openapi_spec, "/api/params/path-named/{type}", "get")
    parameter = _find_parameter(operation, name="type", location="path")

    assert parameter["required"] is True
    assert parameter["schema"]["type"] == "integer"
    assert parameter["schema"]["format"] == "int64"


def test_named_form_parameter_uses_explicit_name_in_request_body(openapi_spec):
    operation = _get_operation(openapi_spec, "/api/params/form-named", "post")
    request_body = operation["requestBody"]
    schema = request_body["content"]["multipart/form-data"]["schema"]

    assert request_body["required"] is True
    assert "type" in schema["properties"]
    assert schema["properties"]["type"]["type"] == "integer"
    assert schema["properties"]["type"]["format"] == "int64"
