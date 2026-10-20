"""
conftest.py — pytest 公共配置

四个独立服务器（各司其职，互不干扰）：

  portBase + 0  useStaticFiles，无 requestPath（根路径）
  portBase + 1  useStaticFiles，requestPath=/s，serveUnknownFileTypes=true
  portBase + 2  useDefaultFiles + useStaticFiles，fileProvider=wwwroot（根目录无默认文件）
  portBase + 3  useDefaultFiles + useStaticFiles，fileProvider=wwwroot/sub（根目录有默认文件）

用法：
  1. 启动服务器：cd integration_test_servers/soulsoft_web_staticfiles/test_server && cjpm run
  2. 运行测试：  cd integration_test_servers/soulsoft_web_staticfiles/test_server/tests && pytest -v
"""

import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15140"))

URL_ROOT     = f"{_BASE}:{_PORT_BASE + 0}"   # 无 requestPath
URL_PREFIX   = f"{_BASE}:{_PORT_BASE + 1}"   # requestPath = /s
URL_DEFAULT  = f"{_BASE}:{_PORT_BASE + 2}"   # defaultFiles + staticFiles，wwwroot 根目录无默认文件
URL_SUB_ROOT = f"{_BASE}:{_PORT_BASE + 3}"   # defaultFiles + staticFiles，approot 根目录有 index.html

_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)
_session.mount("https://", _adapter)


def _on_response_error(response: requests.Response, *args, **kwargs):
    """5xx 时直接将服务端异常栈作为 AssertionError 抛出，方便定位问题。"""
    if response.status_code >= 500:
        body = response.text.strip() or "(empty body)"
        raise AssertionError(
            f"Server {response.status_code} @ "
            f"{response.request.method} {response.request.url}\n{body}"
        )


_session.hooks["response"].append(_on_response_error)


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
def all_servers_ready():
    """等待全部四个服务器就绪，任一未起则跳过整套测试。"""
    for url, name in [
        (URL_ROOT,     f"{_PORT_BASE + 0}/root"),
        (URL_PREFIX,   f"{_PORT_BASE + 1}/prefix"),
        (URL_DEFAULT,  f"{_PORT_BASE + 2}/default-files"),
        (URL_SUB_ROOT, f"{_PORT_BASE + 3}/sub-root"),
    ]:
        if not _wait(url):
            pytest.skip(f"服务器 {name} 未启动，请先运行 cjpm run（地址：{url}）")


# ─── 便捷请求函数（在各测试文件中 from conftest import ... 使用）────────────

def get(url_base: str, path: str, **kwargs) -> requests.Response:
    return _session.get(f"{url_base}{path}", **kwargs)


def head(url_base: str, path: str, **kwargs) -> requests.Response:
    return _session.head(f"{url_base}{path}", **kwargs)


def req(method: str, url_base: str, path: str, **kwargs) -> requests.Response:
    return _session.request(method, f"{url_base}{path}", **kwargs)
