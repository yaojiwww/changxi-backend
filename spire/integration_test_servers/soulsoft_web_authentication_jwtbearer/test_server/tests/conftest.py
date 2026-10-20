"""
conftest.py — JWT Bearer 集成测试公共配置

三个独立服务器：

  portBase + 0  基础JWT认证（令牌生成、受保护端点、用户信息）
  portBase + 1  角色授权测试（AdminOnly/UserOnly策略）
  portBase + 2  错误处理测试（过期令牌、无效签名、详细验证）

用法：
  1. 启动服务器：cd integration_test_servers/soulsoft_web_authentication_jwtbearer/test_server && cjpm run
  2. 运行测试：  cd integration_test_servers/soulsoft_web_authentication_jwtbearer/test_server/tests && pytest -v
"""

import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15060"))

URL_BASIC  = f"{_BASE}:{_PORT_BASE + 0}"   # 基础JWT认证
URL_ROLE   = f"{_BASE}:{_PORT_BASE + 1}"   # 角色授权
URL_ERROR  = f"{_BASE}:{_PORT_BASE + 2}"   # 错误处理

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
    """等待服务器健康检查通过"""
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
    """等待全部三个服务器就绪，任一未起则跳过整套测试。"""
    for url, name in [
        (URL_BASIC,  f"{_PORT_BASE + 0}/basic-jwt"),
        (URL_ROLE,   f"{_PORT_BASE + 1}/role-based"),
        (URL_ERROR,  f"{_PORT_BASE + 2}/error-handling"),
    ]:
        if not _wait(url):
            pytest.skip(f"服务器 {name} 未启动，请先运行 cjpm run（地址：{url}）")


# ═══ 便捷请求函数 ═══════════════════════════════════════════════════════════

def get(url_base: str, path: str, **kwargs) -> requests.Response:
    """发送 GET 请求"""
    return _session.get(f"{url_base}{path}", **kwargs)


def post(url_base: str, path: str, **kwargs) -> requests.Response:
    """发送 POST 请求"""
    return _session.post(f"{url_base}{path}", **kwargs)


def get_with_auth(url_base: str, path: str, token: str, **kwargs) -> requests.Response:
    """发送带 Bearer Token 的 GET 请求"""
    headers = kwargs.pop("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    return _session.get(f"{url_base}{path}", headers=headers, **kwargs)


def post_with_auth(url_base: str, path: str, token: str, **kwargs) -> requests.Response:
    """发送带 Bearer Token 的 POST 请求"""
    headers = kwargs.pop("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    return _session.post(f"{url_base}{path}", headers=headers, **kwargs)


# ═══ JWT Token 辅助函数 ═════════════════════════════════════════════════════

def obtain_token(url_base: str, username: str = "test-user", role: str = "user") -> str:
    """从服务器获取 JWT 令牌"""
    r = _session.post(
        f"{url_base}/token",
        json={"username": username, "role": role}
    )
    assert r.status_code == 200, f"获取令牌失败: {r.text}"
    data = r.json()
    assert "access_token" in data, f"响应中缺少 access_token: {data}"
    return data["access_token"]


def obtain_role_token(url_base: str, username: str = "test-user", role: str = "user") -> str:
    """从角色服务器获取 JWT 令牌"""
    r = _session.post(
        f"{url_base}/api/token",
        json={"username": username, "role": role}
    )
    assert r.status_code == 200, f"获取令牌失败: {r.text}"
    data = r.json()
    assert "access_token" in data, f"响应中缺少 access_token: {data}"
    return data["access_token"]
