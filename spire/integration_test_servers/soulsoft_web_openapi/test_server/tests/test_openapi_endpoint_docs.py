import re

import pytest


USER_DTO = "soulsoft_openapi_test_server.controllers.UserDto"
USER_QUERY_RESPONSE = "soulsoft_openapi_test_server.controllers.UserQueryResponse"
FULL_TYPE_DTO = "soulsoft_openapi_test_server.controllers.FullTypeDto"
FULL_TYPE_RESPONSE = "soulsoft_openapi_test_server.controllers.FullTypeResponse"
HELLO_MODEL = "soulsoft_openapi_test_server.controllers.HelloModel"
HELLO_RESPONSE = "soulsoft_openapi_test_server.controllers.HelloResponse"

PATH_PARAM_RESPONSE = "soulsoft_openapi_test_server.controllers.PathParamResponse"
STRING_PATH_PARAM_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.StringPathParamResponse"
)
MULTI_PATH_PARAM_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.MultiPathParamResponse"
)
QUERY_PARAM_RESPONSE = "soulsoft_openapi_test_server.controllers.QueryParamResponse"
OPTIONAL_QUERY_PARAM_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.OptionalQueryParamResponse"
)
MULTI_QUERY_PARAM_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.MultiQueryParamResponse"
)
HEADER_PARAM_RESPONSE = "soulsoft_openapi_test_server.controllers.HeaderParamResponse"
MULTI_HEADER_PARAM_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.MultiHeaderParamResponse"
)
MIXED_PARAM_RESPONSE = "soulsoft_openapi_test_server.controllers.MixedParamResponse"

PRIMITIVE_VALUE_RESPONSE = (
    "soulsoft_openapi_test_server.controllers.PrimitiveValueResponse"
)
STRING_VALUE_RESPONSE = "soulsoft_openapi_test_server.controllers.StringValueResponse"
BOOL_VALUE_RESPONSE = "soulsoft_openapi_test_server.controllers.BoolValueResponse"
FLOAT_VALUE_RESPONSE = "soulsoft_openapi_test_server.controllers.FloatValueResponse"

DATA_ITEM = "soulsoft_openapi_test_server.controllers.DataItem"
PAGED_DATA_ITEM = (
    "PagedResultOfDataItem"
)
EMPTY_RESPONSE = "soulsoft_openapi_test_server.controllers.EmptyResponse"
NULLABLE_ITEM_ENVELOPE = "soulsoft_openapi_test_server.controllers.NullableItemEnvelope"
STRUCT_DATA_ITEM = "soulsoft_openapi_test_server.controllers.StructDataItem"
RESPONSE_STATE_ENUM = ["Ready", "Failed"]


EXPECTED_OPERATIONS = [
    ("/health", "get"),
    ("/api/complex/query", "get"),
    ("/api/complex/body", "post"),
    ("/api/complex/full-query", "get"),
    ("/api/complex/full-body", "post"),
    ("/api/complex/inheritance-query", "get"),
    ("/api/complex/inheritance-body", "post"),
    ("/api/params/path/{id}", "get"),
    ("/api/params/path-string/{name}", "get"),
    ("/api/params/multi-path/{userId}/{orderId}", "get"),
    ("/api/params/query", "get"),
    ("/api/params/multi-query", "get"),
    ("/api/params/optional-query", "get"),
    ("/api/params/header", "get"),
    ("/api/params/multi-header", "get"),
    ("/api/params/mixed/{userId}", "get"),
    ("/api/primitive/int64", "get"),
    ("/api/primitive/int32", "get"),
    ("/api/primitive/bool", "get"),
    ("/api/primitive/float64", "get"),
    ("/api/primitive/uint64", "get"),
    ("/api/primitive/int8", "get"),
    ("/api/primitive/int16", "get"),
    ("/api/primitive/uint8", "get"),
    ("/api/primitive/uint16", "get"),
    ("/api/primitive/uint32", "get"),
    ("/api/primitive/float16", "get"),
    ("/api/primitive/float32", "get"),
    ("/api/primitive/bigint", "get"),
    ("/api/primitive/decimal", "get"),
    ("/api/primitive/body", "post"),
    ("/api/response/object", "post"),
    ("/api/response/generic", "get"),
    ("/api/response/json-object", "get"),
    ("/api/response/json-array-object", "get"),
    ("/api/response/json-array-primitive", "get"),
    ("/api/response/json-generic", "get"),
    ("/api/response/empty", "get"),
    ("/api/response/json-dict", "get"),
    ("/api/response/json-datetime", "get"),
    ("/api/response/nullable-object", "get"),
    ("/api/response/json-value", "get"),
    ("/api/response/json-value-body", "post"),
    ("/api/response/struct-object", "post"),
    ("/api/response/enum-value", "get"),
    ("/api/response/json-nullable-object", "get"),
]


def _schema_ref(component_name: str):
    return {"ref": component_name}


def _scalar_schema(
    schema_type: str,
    *,
    fmt: str | None = None,
    nullable: bool | None = None,
):
    result = {"type": schema_type}
    if fmt is not None:
        result["format"] = fmt
    if nullable is True:
        result["nullable"] = True
        return result
    if nullable is False:
        return result
    return result


def _array_schema(items: dict):
    return {"type": "array", "items": items}


def _object_schema(properties: dict[str, dict]):
    return {"type": "object", "properties": properties}


def _dictionary_schema(value_schema: dict):
    return {"type": "object", "additionalProperties": value_schema}


def _nullable_ref_schema(component_name: str):
    return {"nullable": True, "allOf": [{"ref": component_name}]}


def _enum_schema(values: list[str], *, nullable: bool | None = None):
    result = {"type": "string", "enum": values}
    if nullable is not None:
        result["nullable"] = nullable
    return result


def _any_schema():
    return {}


def _get_operation(spec: dict, path: str, method: str):
    assert path in spec["paths"], f"missing path {path}"
    assert method in spec["paths"][path], f"missing operation {method.upper()} {path}"
    return spec["paths"][path][method]


def _normalize_component_name(name: str) -> str:
    def _strip_namespace(match: re.Match[str]) -> str:
        token = match.group(0)
        return token.rsplit(".", 1)[-1]

    return re.sub(r"[A-Za-z_][A-Za-z0-9_.]*", _strip_namespace, name)


def _resolve_component_name(openapi_spec: dict, expected_name: str) -> str:
    schemas = openapi_spec["components"]["schemas"]
    if expected_name in schemas:
        return expected_name

    normalized_expected = _normalize_component_name(expected_name)
    matches = [
        actual_name
        for actual_name in schemas
        if _normalize_component_name(actual_name) == normalized_expected
    ]
    assert matches, f"missing schema component {expected_name!r}"
    assert len(matches) == 1, (
        f"schema component {expected_name!r} is ambiguous after normalization: {matches}"
    )
    return matches[0]


def _find_parameter(operation: dict, *, name: str, location: str):
    for parameter in operation.get("parameters", []):
        if parameter.get("name") == name and parameter.get("in") == location:
            return parameter
    raise AssertionError(
        f"missing parameter {location}:{name} in operation with "
        f"parameters={operation.get('parameters', [])}"
    )


def _assert_schema(actual: dict, expected: dict, openapi_spec: dict):
    if "$ref" in actual and "ref" not in expected:
        component_name = actual["$ref"].rsplit("/", 1)[-1]
        component_schema = openapi_spec["components"]["schemas"][component_name]
        _assert_schema(component_schema, expected, openapi_spec)
        return

    if expected == {}:
        assert actual == {}
        return

    if "ref" in expected:
        component_name = _resolve_component_name(openapi_spec, expected["ref"])
        expected_ref = f"#/components/schemas/{component_name}"
        if "$ref" in actual:
            assert actual["$ref"] == expected_ref
            return

        component_schema = openapi_spec["components"]["schemas"][component_name]
        _assert_schema(actual, component_schema, openapi_spec)
        return

    if "oneOf" in expected:
        assert "oneOf" in actual
        assert len(actual["oneOf"]) == len(expected["oneOf"])
        for expected_item in expected["oneOf"]:
            matched = False
            for actual_item in actual["oneOf"]:
                try:
                    _assert_schema(actual_item, expected_item, openapi_spec)
                    matched = True
                    break
                except AssertionError:
                    continue
            assert matched, f"missing matching oneOf item for {expected_item!r} in {actual!r}"
        return

    if "type" in expected:
        assert actual["type"] == expected["type"]

    if "format" in expected:
        assert actual.get("format") == expected["format"]
    if "nullable" in expected:
        assert actual.get("nullable", False) is expected["nullable"]
    if "enum" in expected:
        assert actual.get("enum") == expected["enum"]
    if expected.get("type") == "array":
        _assert_schema(actual["items"], expected["items"], openapi_spec)
    if expected.get("type") == "object" and "properties" in expected:
        for name, schema in expected["properties"].items():
            assert name in actual["properties"], f"missing property {name}"
            _assert_schema(actual["properties"][name], schema, openapi_spec)
    if expected.get("type") == "object" and "additionalProperties" in expected:
        assert "additionalProperties" in actual
        _assert_schema(
            actual["additionalProperties"],
            expected["additionalProperties"],
            openapi_spec,
        )
    if "allOf" in expected:
        assert "allOf" in actual
        assert len(actual["allOf"]) == len(expected["allOf"])
        for actual_item, expected_item in zip(actual["allOf"], expected["allOf"]):
            _assert_schema(actual_item, expected_item, openapi_spec)


def _assert_parameter_docs(operation: dict, expected_params: list[dict], openapi_spec: dict):
    assert len(operation.get("parameters", [])) == len(expected_params)
    for expected in expected_params:
        parameter = _find_parameter(
            operation,
            name=expected["name"],
            location=expected["in"],
        )
        assert parameter.get("required") is expected["required"]
        _assert_schema(parameter["schema"], expected["schema"], openapi_spec)


def _assert_request_body_docs(operation: dict, expected_schema: dict, openapi_spec: dict):
    assert "requestBody" in operation
    request_body = operation["requestBody"]
    assert request_body.get("required") is True
    assert "application/json" in request_body["content"]
    _assert_schema(
        request_body["content"]["application/json"]["schema"],
        expected_schema,
        openapi_spec,
    )


def _assert_response_docs(operation: dict, expected_schema: dict, openapi_spec: dict):
    response = operation["responses"]["200"]
    assert "application/json" in response["content"]
    _assert_schema(
        response["content"]["application/json"]["schema"],
        expected_schema,
        openapi_spec,
    )


@pytest.mark.parametrize(("path", "method"), EXPECTED_OPERATIONS)
def test_every_controller_endpoint_is_present_in_openapi_document(
    openapi_spec,
    path: str,
    method: str,
):
    _get_operation(openapi_spec, path, method)


@pytest.mark.parametrize(
    ("path", "method", "expected_params", "expected_response"),
    [
        (
            "/api/params/path/{id}",
            "get",
            [
                {
                    "name": "id",
                    "in": "path",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                }
            ],
            _schema_ref(PATH_PARAM_RESPONSE),
        ),
        (
            "/api/params/path-string/{name}",
            "get",
            [
                {
                    "name": "name",
                    "in": "path",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                }
            ],
            _schema_ref(STRING_PATH_PARAM_RESPONSE),
        ),
        (
            "/api/params/multi-path/{userId}/{orderId}",
            "get",
            [
                {
                    "name": "userId",
                    "in": "path",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "orderId",
                    "in": "path",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
            ],
            _schema_ref(MULTI_PATH_PARAM_RESPONSE),
        ),
        (
            "/api/params/query",
            "get",
            [
                {
                    "name": "id",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                }
            ],
            _schema_ref(QUERY_PARAM_RESPONSE),
        ),
        (
            "/api/params/multi-query",
            "get",
            [
                {
                    "name": "name",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "age",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
            ],
            _schema_ref(MULTI_QUERY_PARAM_RESPONSE),
        ),
        (
            "/api/params/optional-query",
            "get",
            [
                {
                    "name": "id",
                    "in": "query",
                    "required": False,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=True),
                }
            ],
            _schema_ref(OPTIONAL_QUERY_PARAM_RESPONSE),
        ),
        (
            "/api/params/header",
            "get",
            [
                {
                    "name": "X-Request-ID",
                    "in": "header",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                }
            ],
            _schema_ref(HEADER_PARAM_RESPONSE),
        ),
        (
            "/api/params/multi-header",
            "get",
            [
                {
                    "name": "X-Client-ID",
                    "in": "header",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "X-API-Key",
                    "in": "header",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
            ],
            _schema_ref(MULTI_HEADER_PARAM_RESPONSE),
        ),
        (
            "/api/params/mixed/{userId}",
            "get",
            [
                {
                    "name": "userId",
                    "in": "path",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "name",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "X-Token",
                    "in": "header",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
            ],
            _schema_ref(MIXED_PARAM_RESPONSE),
        ),
    ],
)
def test_parameter_endpoints_have_expected_openapi_docs(
    openapi_spec,
    path: str,
    method: str,
    expected_params: list[dict],
    expected_response: dict,
):
    operation = _get_operation(openapi_spec, path, method)
    _assert_parameter_docs(operation, expected_params, openapi_spec)
    _assert_response_docs(operation, expected_response, openapi_spec)


@pytest.mark.parametrize(
    ("path", "method", "expected_params", "expected_request_body", "expected_response"),
    [
        (
            "/api/primitive/int64",
            "get",
            [
                {
                    "name": "id",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/int32",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int32", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/bool",
            "get",
            [
                {
                    "name": "flag",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("boolean", nullable=False),
                }
            ],
            None,
            _schema_ref(BOOL_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/float64",
            "get",
            [
                {
                    "name": "val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                }
            ],
            None,
            _schema_ref(FLOAT_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/uint64",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(STRING_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/int8",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/int16",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/uint8",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/uint16",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/uint32",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                }
            ],
            None,
            _schema_ref(STRING_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/float16",
            "get",
            [
                {
                    "name": "val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                }
            ],
            None,
            _schema_ref(FLOAT_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/float32",
            "get",
            [
                {
                    "name": "val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                }
            ],
            None,
            _schema_ref(FLOAT_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/bigint",
            "get",
            [
                {
                    "name": "n",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                }
            ],
            None,
            _schema_ref(STRING_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/decimal",
            "get",
            [
                {
                    "name": "val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                }
            ],
            None,
            _schema_ref(STRING_VALUE_RESPONSE),
        ),
        (
            "/api/primitive/body",
            "post",
            [],
            _scalar_schema("integer", fmt="int64", nullable=False),
            _schema_ref(PRIMITIVE_VALUE_RESPONSE),
        ),
    ],
)
def test_primitive_endpoints_have_expected_openapi_docs(
    openapi_spec,
    path: str,
    method: str,
    expected_params: list[dict],
    expected_request_body: dict | None,
    expected_response: dict,
):
    operation = _get_operation(openapi_spec, path, method)
    _assert_parameter_docs(operation, expected_params, openapi_spec)
    if expected_request_body is not None:
        _assert_request_body_docs(operation, expected_request_body, openapi_spec)
    else:
        assert "requestBody" not in operation
    _assert_response_docs(operation, expected_response, openapi_spec)


@pytest.mark.parametrize(
    ("path", "method", "expected_params", "expected_request_body", "expected_response"),
    [
        (
            "/api/complex/query",
            "get",
            [
                {
                    "name": "name",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "age",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "email",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "score",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                },
                {
                    "name": "isActive",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("boolean", nullable=False),
                },
                {
                    "name": "balance",
                    "in": "query",
                    "required": False,
                    "schema": _scalar_schema("number", nullable=True),
                },
            ],
            None,
            _schema_ref(USER_QUERY_RESPONSE),
        ),
        (
            "/api/complex/body",
            "post",
            [],
            _schema_ref(USER_DTO),
            _schema_ref(USER_QUERY_RESPONSE),
        ),
        (
            "/api/complex/full-query",
            "get",
            [
                {
                    "name": "boolVal",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("boolean", nullable=False),
                },
                {
                    "name": "int8Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "int16Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "int32Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int32", nullable=False),
                },
                {
                    "name": "int64Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "uint8Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "uint16Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "uint32Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "uint64Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", nullable=False),
                },
                {
                    "name": "float16Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                },
                {
                    "name": "float32Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                },
                {
                    "name": "float64Val",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                },
                {
                    "name": "bigIntVal",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "decimalVal",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("number", nullable=False),
                },
                {
                    "name": "strVal",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
                {
                    "name": "dtVal",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", fmt="date-time", nullable=False),
                },
                {
                    "name": "optInt64",
                    "in": "query",
                    "required": False,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=True),
                },
                {
                    "name": "optDateTime",
                    "in": "query",
                    "required": False,
                    "schema": _scalar_schema("string", fmt="date-time", nullable=True),
                },
                {
                    "name": "strArr",
                    "in": "query",
                    "required": True,
                    "schema": _array_schema(_scalar_schema("string", nullable=False)),
                },
                {
                    "name": "int64Arr",
                    "in": "query",
                    "required": True,
                    "schema": _array_schema(
                        _scalar_schema("integer", fmt="int64", nullable=False)
                    ),
                },
            ],
            None,
            _schema_ref(FULL_TYPE_RESPONSE),
        ),
        (
            "/api/complex/full-body",
            "post",
            [],
            _schema_ref(FULL_TYPE_DTO),
            _schema_ref(FULL_TYPE_RESPONSE),
        ),
        (
            "/api/complex/inheritance-query",
            "get",
            [
                {
                    "name": "pageIndex",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "pageSize",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "id",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=False),
                },
                {
                    "name": "age",
                    "in": "query",
                    "required": False,
                    "schema": _scalar_schema("integer", fmt="int64", nullable=True),
                },
                {
                    "name": "name",
                    "in": "query",
                    "required": True,
                    "schema": _scalar_schema("string", nullable=False),
                },
            ],
            None,
            _schema_ref(HELLO_RESPONSE),
        ),
        (
            "/api/complex/inheritance-body",
            "post",
            [],
            _schema_ref(HELLO_MODEL),
            _schema_ref(HELLO_RESPONSE),
        ),
    ],
)
def test_complex_endpoints_have_expected_openapi_docs(
    openapi_spec,
    path: str,
    method: str,
    expected_params: list[dict],
    expected_request_body: dict | None,
    expected_response: dict,
):
    operation = _get_operation(openapi_spec, path, method)
    _assert_parameter_docs(operation, expected_params, openapi_spec)
    if expected_request_body is not None:
        _assert_request_body_docs(operation, expected_request_body, openapi_spec)
    else:
        assert "requestBody" not in operation
    _assert_response_docs(operation, expected_response, openapi_spec)


@pytest.mark.parametrize(
    ("path", "method", "expected_request_body", "expected_response"),
    [
        (
            "/api/response/object",
            "post",
            _schema_ref(DATA_ITEM),
            _schema_ref(DATA_ITEM),
        ),
        (
            "/api/response/generic",
            "get",
            None,
            _schema_ref(PAGED_DATA_ITEM),
        ),
        (
            "/api/response/json-object",
            "get",
            None,
            _schema_ref(DATA_ITEM),
        ),
        (
            "/api/response/json-array-object",
            "get",
            None,
            _array_schema(_schema_ref(DATA_ITEM)),
        ),
        (
            "/api/response/json-array-primitive",
            "get",
            None,
            _array_schema(_scalar_schema("integer", fmt="int64", nullable=False)),
        ),
        (
            "/api/response/json-generic",
            "get",
            None,
            _schema_ref(PAGED_DATA_ITEM),
        ),
        (
            "/api/response/empty",
            "get",
            None,
            _schema_ref(EMPTY_RESPONSE),
        ),
        (
            "/api/response/json-dict",
            "get",
            None,
            _dictionary_schema(_schema_ref(DATA_ITEM)),
        ),
        (
            "/api/response/json-datetime",
            "get",
            None,
            _scalar_schema("string", fmt="date-time", nullable=False),
        ),
        (
            "/api/response/nullable-object",
            "get",
            None,
            _schema_ref(NULLABLE_ITEM_ENVELOPE),
        ),
        (
            "/api/response/json-value",
            "get",
            None,
            _any_schema(),
        ),
        (
            "/api/response/json-value-body",
            "post",
            _any_schema(),
            _any_schema(),
        ),
        (
            "/api/response/struct-object",
            "post",
            _schema_ref(STRUCT_DATA_ITEM),
            _schema_ref(STRUCT_DATA_ITEM),
        ),
        (
            "/api/response/enum-value",
            "get",
            None,
            _enum_schema(RESPONSE_STATE_ENUM, nullable=False),
        ),
        (
            "/api/response/json-nullable-object",
            "get",
            None,
            _nullable_ref_schema(DATA_ITEM),
        ),
    ],
)
def test_response_endpoints_have_expected_openapi_docs(
    openapi_spec,
    path: str,
    method: str,
    expected_request_body: dict | None,
    expected_response: dict,
):
    operation = _get_operation(openapi_spec, path, method)
    if expected_request_body is not None:
        _assert_request_body_docs(operation, expected_request_body, openapi_spec)
    else:
        assert "requestBody" not in operation
    _assert_response_docs(operation, expected_response, openapi_spec)


def test_nullable_reference_properties_use_nullable_allof_wrapper(openapi_spec):
    schema_name = _resolve_component_name(openapi_spec, NULLABLE_ITEM_ENVELOPE)
    schema = openapi_spec["components"]["schemas"][schema_name]

    assert "item" in schema["properties"]
    _assert_schema(
        schema["properties"]["item"],
        _nullable_ref_schema(DATA_ITEM),
        openapi_spec,
    )


def test_struct_components_expand_properties(openapi_spec):
    schema_name = _resolve_component_name(openapi_spec, STRUCT_DATA_ITEM)
    schema = openapi_spec["components"]["schemas"][schema_name]

    _assert_schema(
        schema,
        _object_schema(
            {
                "id": _scalar_schema("integer", fmt="int64", nullable=False),
                "name": _scalar_schema("string", nullable=False),
            }
        ),
        openapi_spec,
    )
