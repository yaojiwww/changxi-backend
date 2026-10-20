"""
conftest.py - pytest 公共配置

用法：
    1. 启动测试服务器：cd integration_test_servers/soulsoft_web_routing/test_server && cjpm run
    2. 运行测试：cd integration_test_servers/soulsoft_web_routing/test_server/tests && pytest -v

服务器默认地址：http://127.0.0.1:15130
可通过环境变量 TEST_SERVER_HOST / TEST_SERVER_PORT_BASE / TEST_SERVER_URL 覆盖。
"""
import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_HOST = os.environ.get("TEST_SERVER_HOST", "http://127.0.0.1").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15130"))
BASE_URL = os.environ.get("TEST_SERVER_URL", f"{_HOST}:{_PORT_BASE}").rstrip("/")

# Session 级别连接池，复用 TCP 连接，避免每次请求重新握手
_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)
_session.mount("https://", _adapter)


def _on_response_error(response: requests.Response, *args, **kwargs):
    """服务端错误拦截器：5xx 时将响应体（异常信息）作为 AssertionError 抛出，
    使 pytest 失败输出中直接显示服务端的原始异常栈，而非仅 status_code。"""
    if response.status_code >= 500:
        body = response.text.strip() or "(empty response body)"
        raise AssertionError(
            f"Server {response.status_code} @ {response.request.method} {response.request.url}\n"
            f"{body}"
        )


_session.hooks["response"].append(_on_response_error)


def wait_for_server(url: str, timeout: float = 10.0) -> bool:
    """等待服务器启动就绪"""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            r = _session.get(f"{url}/health", timeout=1)
            if r.status_code == 200:
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(0.3)
    return False


@pytest.fixture(scope="session", autouse=True)
def server_ready():
    """Session 级别 fixture，确保服务器在测试前已启动"""
    ok = wait_for_server(BASE_URL)
    if not ok:
        pytest.skip(
            f"测试服务器未启动，请先运行：cjpm run（地址：{BASE_URL}）"
        )


def get(path: str, **kwargs) -> requests.Response:
    return _session.get(f"{BASE_URL}{path}", **kwargs)


def get_raw(path: str, **kwargs) -> requests.Response:
    """跳过 5xx 错误拦截器，用于断言预期为错误响应的场景。"""
    return requests.get(f"{BASE_URL}{path}", **kwargs)


def post(path: str, **kwargs) -> requests.Response:
    return _session.post(f"{BASE_URL}{path}", **kwargs)


def put(path: str, **kwargs) -> requests.Response:
    return _session.put(f"{BASE_URL}{path}", **kwargs)


def patch(path: str, **kwargs) -> requests.Response:
    return _session.patch(f"{BASE_URL}{path}", **kwargs)


def delete(path: str, **kwargs) -> requests.Response:
    return _session.delete(f"{BASE_URL}{path}", **kwargs)


def request(method: str, path: str, **kwargs) -> requests.Response:
    return _session.request(method, f"{BASE_URL}{path}", **kwargs)
