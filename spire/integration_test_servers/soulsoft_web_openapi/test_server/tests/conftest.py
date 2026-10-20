"""
conftest.py — OpenAPI 集成测试公共配置

服务器：
  15120  OpenAPI 测试服务器

用法：
  1. 启动服务器：
     cd integration_test_servers/soulsoft_web_openapi/test_server && cjpm run -- --HTTP_PORTS 15120
  2. 运行测试：
     cd integration_test_servers/soulsoft_web_openapi/test_server/tests && pytest -v

如果服务实际监听的不是 15120，可通过 TEST_SERVER_URL 覆盖，例如：
  TEST_SERVER_URL=http://127.0.0.1:5000 pytest -v
"""

import os
import time

import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15120"))
URL = os.environ.get("TEST_SERVER_URL", f"{_BASE}:{_PORT_BASE}")

_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)
_session.mount("https://", _adapter)


def _on_response_error(response: requests.Response, *args, **kwargs):
    """5xx 时抛出带上下文的 AssertionError，便于快速定位服务端异常。"""
    if response.status_code >= 500:
        body = response.text.strip() or "(empty body)"
        raise AssertionError(
            f"Server {response.status_code} @ "
            f"{response.request.method} {response.request.url}\n{body}"
        )


_session.hooks["response"].append(_on_response_error)


def _wait(url: str, path: str = "/health", timeout: float = 15.0) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            r = _session.get(f"{url}{path}", timeout=1, allow_redirects=False)
            if r.status_code == 200:
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(0.3)
    return False


@pytest.fixture(scope="session", autouse=True)
def server_ready():
    """等待 OpenAPI 测试服务器就绪，未启动则跳过整套测试。"""
    if not _wait(URL, "/health"):
        pytest.skip(
            "OpenAPI 测试服务器未启动，请先运行 cjpm run -- --HTTP_PORTS 15120 "
            f"（或通过 TEST_SERVER_URL 指定实际地址，当前：{URL}/health）"
        )


@pytest.fixture(scope="session")
def openapi_spec():
    response = _session.get(f"{URL}/openapi/v1.json", timeout=10)
    assert response.status_code == 200
    return response.json()


def get(path: str, **kwargs) -> requests.Response:
    return _session.get(f"{URL}{path}", **kwargs)


def post(path: str, **kwargs) -> requests.Response:
    return _session.post(f"{URL}{path}", **kwargs)

