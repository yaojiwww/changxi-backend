import re

from conftest import get


def test_health_endpoint_is_reachable():
    response = get("/health", timeout=3)

    assert response.status_code == 200
    assert response.text.strip() == "OK"


def test_openapi_ui_root_redirects_to_index():
    response = get("/openapi", timeout=3, allow_redirects=False)

    assert response.status_code in (301, 302, 307, 308)
    assert response.headers["Location"].endswith("/openapi/index.html")


def test_openapi_ui_index_is_served():
    response = get("/openapi/index.html", timeout=3)

    assert response.status_code == 200
    assert "swagger-ui" in response.text


def test_openapi_document_has_required_top_level_fields(openapi_spec):
    assert re.fullmatch(r"3\.(0|1)\.\d+", openapi_spec["openapi"])
    assert isinstance(openapi_spec["info"]["title"], str)
    assert openapi_spec["info"]["title"]
    assert isinstance(openapi_spec["info"]["version"], str)
    assert openapi_spec["info"]["version"]
    assert isinstance(openapi_spec["paths"], dict)
    assert openapi_spec["paths"]
    assert isinstance(openapi_spec["components"]["schemas"], dict)
    assert openapi_spec["components"]["schemas"]
