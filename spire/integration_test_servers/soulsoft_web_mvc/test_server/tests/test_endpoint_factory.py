"""
test_endpoint_factory.py — ActionEndpointFactory 端点生成集成测试

验证 ActionEndpointFactory.applyApiController 的全部路由生成逻辑：

  场景 1  [controller] 占位符替换
          @Route["[controller]"] 在 EpFactoryController → 前缀 /epfactory

  场景 2  相对路径合并
          controller 有前缀 + action 模板不以 '/' 开头 → /epfactory/{actionTemplate}

  场景 3  绝对路径覆盖
          action 模板以 '/' 开头 → 忽略 controller 前缀，直接使用该路径

  场景 4  多 HTTP 方法注解 → 多 Endpoint
          同一 action 上 @HttpGet["multi"] + @HttpPost["multi"]
          → 生成两个独立 Endpoint，各携带正确的 HttpMethodMetadata

  场景 5  [action] 占位符替换
          @HttpGet["[action]"] 在 func actionPlaceholder() → /epfactory/actionplaceholder

  场景 6  controller 无 @Route 前缀 + 绝对路径 action
          default = None，action 以 '/' 开头 → 直接使用 action 路径

  场景 7  controller 无 @Route 前缀 + 相对路径 action
          default = None，action 不以 '/' 开头 → action 模板原值解析为路由

服务器：http://localhost:5010（通过 conftest.py 的 server_ready fixture 等待就绪）
"""

import pytest
from conftest import get, post, _session, URL


# ══════════════════════════════════════════════════════════════════════════════
# 场景 1 & 2：[controller] 占位符 + 相对路径合并
# ══════════════════════════════════════════════════════════════════════════════

class TestControllerPrefixMerge:
    """@Route["[controller]"] 占位符替换 + 相对路径与前缀合并。"""

    def test_controller_placeholder_resolved_to_lowercase(self):
        """[controller] → 类名去掉 Controller 后缀转小写 = epfactory，路由应为 /epfactory/relative。"""
        r = get("/epfactory/relative")
        assert r.status_code == 200
        assert r.json()["route"] == "relative"

    def test_relative_path_not_reachable_without_prefix(self):
        """相对路径必须通过带前缀的 URL 访问，不带前缀应返回 404。"""
        r = get("/relative")
        assert r.status_code == 404


# ══════════════════════════════════════════════════════════════════════════════
# 场景 3：绝对路径覆盖（action 模板以 '/' 开头）
# ══════════════════════════════════════════════════════════════════════════════

class TestAbsolutePathOverride:
    """action 模板以 '/' 开头时，完全忽略 controller 前缀。"""

    def test_absolute_path_accessible_at_declared_route(self):
        """GET /epfactory-abs 应直接可访问（不含 controller 前缀）。"""
        r = get("/epfactory-abs")
        assert r.status_code == 200
        assert r.json()["route"] == "absolute"

    def test_absolute_path_not_merged_with_prefix(self):
        """controller 前缀不应出现在绝对路径中，/epfactory/epfactory-abs 应返回 404。"""
        r = get("/epfactory/epfactory-abs")
        assert r.status_code == 404

    def test_absolute_path_method_name_route_not_created(self):
        """action 方法名（absoluteoverride）本身不会被注册为路由，应返回 404。"""
        r = get("/epfactory/absoluteoverride")
        assert r.status_code == 404


# ══════════════════════════════════════════════════════════════════════════════
# 场景 4：多 HTTP 方法注解 → 多个独立 Endpoint + HttpMethodMetadata
# ══════════════════════════════════════════════════════════════════════════════

class TestMultipleHttpMethodAnnotations:
    """同一 action 上的多个 HTTP 方法注解分别生成独立 Endpoint，各自约束 HTTP 方法。"""

    def test_get_annotation_generates_get_endpoint(self):
        """@HttpGet["multi"] 生成的 Endpoint 接受 GET 请求。"""
        r = get("/epfactory/multi")
        assert r.status_code == 200
        assert r.json()["route"] == "multi"

    def test_post_annotation_generates_post_endpoint(self):
        """@HttpPost["multi"] 生成的 Endpoint 接受 POST 请求。"""
        r = post("/epfactory/multi")
        assert r.status_code == 200
        assert r.json()["route"] == "multi"

    def test_wrong_method_returns_405(self):
        """路径匹配但 HTTP 方法不在 HttpMethodMetadata 中，应返回 405。"""
        r = _session.delete(f"{URL}/epfactory/multi")
        assert r.status_code == 405

    def test_put_returns_405(self):
        """PUT 方法未在注解中声明，应返回 405。"""
        r = _session.put(f"{URL}/epfactory/multi", json={})
        assert r.status_code == 405

    def test_get_and_post_endpoints_are_independent(self):
        """GET 和 POST 各自独立，均应正常响应且返回相同业务数据。"""
        get_resp = get("/epfactory/multi")
        post_resp = post("/epfactory/multi")
        assert get_resp.status_code == 200
        assert post_resp.status_code == 200
        assert get_resp.json() == post_resp.json()


# ══════════════════════════════════════════════════════════════════════════════
# 场景 5：[action] 占位符替换
# ══════════════════════════════════════════════════════════════════════════════

class TestActionPlaceholder:
    """[action] 占位符替换为 action 方法名小写。"""

    def test_action_placeholder_resolved_to_method_name(self):
        """@HttpGet["[action]"] 在 func actionPlaceholder() → /epfactory/actionplaceholder。"""
        r = get("/epfactory/actionplaceholder")
        assert r.status_code == 200
        assert r.json()["route"] == "action-placeholder"

    def test_action_placeholder_literal_not_registered(self):
        """路由中不应存在字面量 [action]，该路径应返回 404。"""
        r = get("/epfactory/[action]")
        assert r.status_code == 404


# ══════════════════════════════════════════════════════════════════════════════
# 场景 6 & 7：controller 无 @Route 前缀
# ══════════════════════════════════════════════════════════════════════════════

class TestNoControllerPrefix:
    """controller 上无 @Route 注解时，action 模板直接作为完整路径（default = None）。"""

    def test_absolute_action_used_directly_without_prefix(self):
        """controller 无前缀 + action 以 '/' 开头 → /epfactory-noprefix 直接可访问。"""
        r = get("/epfactory-noprefix")
        assert r.status_code == 200
        assert r.json()["route"] == "no-prefix-absolute"

    def test_relative_action_used_as_route_without_prefix(self):
        """controller 无前缀 + action 相对路径 → action 模板原值直接注册为路由。"""
        r = get("/epfactory-noprefix-rel")
        assert r.status_code == 200
        assert r.json()["route"] == "no-prefix-relative"
