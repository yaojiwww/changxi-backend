"""
conftest.py — pytest 公共配置

服务器：

  15100  HTTP 响应集成测试服务器（routing，多端点）

用法：
  1. 启动服务器：cd integration_test_servers/soulsoft_web_hosting/test_server && cjpm run
  2. 运行测试：  cd integration_test_servers/soulsoft_web_hosting/test_server/tests && pytest -v
"""

import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15100"))
URL = os.environ.get("TEST_SERVER_URL", f"{_BASE}:{_PORT_BASE}")

_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)


def _wait(url: str, timeout: float = 15.0) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            r = _session.get(f"{url}/health", timeout=1, allow_redirects=False)
            if r.status_code == 200:
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(0.3)
    return False


@pytest.fixture(scope="session", autouse=True)
def server_ready():
    """等待 HTTP 集成测试服务器就绪，未启动则跳过整套测试。"""
    if not _wait(URL):
        pytest.skip(f"服务器未启动，请先运行 cjpm run（地址：{URL}）")


# ─── 便捷请求函数 ────────────────────────────────────────────

def get(path: str, **kwargs) -> requests.Response:
    return _session.get(f"{URL}{path}", **kwargs)


def head(path: str, **kwargs) -> requests.Response:
    return _session.head(f"{URL}{path}", **kwargs)


def req(method: str, path: str, **kwargs) -> requests.Response:
    return _session.request(method, f"{URL}{path}", **kwargs)
