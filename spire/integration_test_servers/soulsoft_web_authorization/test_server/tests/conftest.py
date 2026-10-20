"""
conftest.py — Authorization 集成测试公共配置

三个独立服务器：

  portBase + 0  MiniAPI 基础授权（匿名、requireAuthorization()、allowAnonymous()、用户信息）
  portBase + 1  MiniAPI 策略授权（命名策略、内联策略、直接策略对象、Assertion、多要求）
  portBase + 2  MVC 控制器授权（类级 @Authorize、@AllowAnonymous 覆盖、命名策略方法级注解）

用法：
  1. 启动服务器：cd integration_test_servers/soulsoft_web_authorization/test_server && cjpm run
  2. 运行测试：  cd integration_test_servers/soulsoft_web_authorization/test_server/tests && pytest -v
"""

import os
import time
import pytest
import requests
from requests.adapters import HTTPAdapter

_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15070"))

URL_BASIC  = f"{_BASE}:{_PORT_BASE + 0}"   # MiniAPI 基础授权
URL_POLICY = f"{_BASE}:{_PORT_BASE + 1}"   # MiniAPI 策略授权
URL_MVC    = f"{_BASE}:{_PORT_BASE + 2}"   # MVC 控制器授权

_session = requests.Session()
_adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
_session.mount("http://", _adapter)
_session.mount("https://", _adapter)


def _on_response_error(response: requests.Response, *args, **kwargs):
    """5xx 时将服务端异常栈作为 AssertionError 抛出，方便定位问题。"""
    if response.status_code >= 500:
        body = response.text.strip() or "(empty body)"
        raise AssertionError(
            f"Server {response.status_code} @ "
            f"{response.request.method} {response.request.url}\n{body}"
        )


_session.hooks["response"].append(_on_response_error)


def _wait(url: str, path: str = "/health", timeout: float = 15.0) -> bool:
    """等待服务器健康检查通过"""
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
def all_servers_ready():
    """等待全部三个服务器就绪，任一未起则跳过整套测试。"""
    checks = [
        (URL_BASIC,              "/health",             f"{_PORT_BASE + 0}/miniapi-basic"),
        (URL_POLICY,             "/health",             f"{_PORT_BASE + 1}/miniapi-policy"),
        (URL_MVC,                "/health",             f"{_PORT_BASE + 2}/mvc-auth"),
    ]
    for url, path, name in checks:
        if not _wait(url, path):
            pytest.skip(f"服务器 {name} 未启动，请先运行 cjpm run（地址：{url}{path}）")


# ═══ 便捷请求函数 ═══════════════════════════════════════════════════════════

def get(url_base: str, path: str, **kwargs) -> requests.Response:
    return _session.get(f"{url_base}{path}", **kwargs)


def post(url_base: str, path: str, **kwargs) -> requests.Response:
    return _session.post(f"{url_base}{path}", **kwargs)


def get_auth(url_base: str, path: str, token: str, **kwargs) -> requests.Response:
    """发送带 Bearer Token 的 GET 请求"""
    headers = kwargs.pop("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    return _session.get(f"{url_base}{path}", headers=headers, **kwargs)


def post_auth(url_base: str, path: str, token: str, **kwargs) -> requests.Response:
    """发送带 Bearer Token 的 POST 请求"""
    headers = kwargs.pop("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    return _session.post(f"{url_base}{path}", headers=headers, **kwargs)


# ═══ JWT Token 辅助函数 ═════════════════════════════════════════════════════

def obtain_token(
    url_base: str,
    username: str = "test-user",
    role: str = "user",
    **extra_claims,
) -> str:
    """从服务器 POST /token 获取 JWT 令牌，支持额外 claims（department、seniority 等）"""
    body = {"username": username, "role": role, **extra_claims}
    r = _session.post(f"{url_base}/token", json=body)
    assert r.status_code == 200, f"获取令牌失败: {r.text}"
    data = r.json()
    assert "access_token" in data, f"响应中缺少 access_token: {data}"
    return data["access_token"]


def obtain_mvc_token(
    username: str = "test-user",
    role: str = "user",
    **extra_claims,
) -> str:
    """从 MVC 服务器 POST /api/token 获取 JWT 令牌"""
    body = {"username": username, "role": role, **extra_claims}
    r = _session.post(f"{URL_MVC}/api/token", json=body)
    assert r.status_code == 200, f"获取 MVC 令牌失败: {r.text}"
    data = r.json()
    assert "access_token" in data, f"响应中缺少 access_token: {data}"
    return data["access_token"]
