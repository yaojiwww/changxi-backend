"""
conftest.py — 模型绑定集成测试公共配置

服务器：
  15110  MVC 模型绑定测试服务器

用法：
  1. 启动服务器：cd integration_test_servers/soulsoft_web_mvc/test_server && cjpm run
  2. 运行测试：  cd integration_test_servers/soulsoft_web_mvc/test_server/tests && pytest -v
"""

import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15110"))
URL = os.environ.get("TEST_SERVER_URL", f"{_BASE}:{_PORT_BASE}")

_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)
_session.mount("https://", _adapter)


def _on_response_error(response: requests.Response, *args, **kwargs):
    """5xx 时将服务端异常信息作为 AssertionError 抛出，方便定位问题。"""
    if response.status_code >= 500:
        body = response.text.strip() or "(empty body)"
        raise AssertionError(
            f"Server {response.status_code} @ "
            f"{response.request.method} {response.request.url}\n{body}"
        )


_session.hooks["response"].append(_on_response_error)


def _wait(url: str, path: str = "/health", timeout: float = 15.0) -> bool:
    """等待服务器健康检查通过。"""
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
    """等待绑定测试服务器就绪，未启动则跳过整套测试。"""
    if not _wait(URL, "/health"):
        pytest.skip(
            f"绑定测试服务器未启动，请先运行 cjpm run（地址：{URL}/health）"
        )


# ═══ 便捷请求函数 ═══════════════════════════════════════════════════════════════

def get(path: str, **kwargs) -> requests.Response:
    return _session.get(f"{URL}{path}", **kwargs)


def post(path: str, **kwargs) -> requests.Response:
    return _session.post(f"{URL}{path}", **kwargs)


def assert_problem_error_key(response: requests.Response, key: str) -> list:
    assert response.status_code == 400
    payload = response.json()
    assert payload["status"] == 400
    assert key in payload["errors"]
    messages = payload["errors"][key]
    assert messages
    return messages
