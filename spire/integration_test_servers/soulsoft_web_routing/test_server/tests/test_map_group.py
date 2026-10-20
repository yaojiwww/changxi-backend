"""
test_map_group.py - MapGroup 路由分组功能测试

测试场景：
  TC-GROUP-01: 基础分组 - 前缀自动附加
  TC-GROUP-02: 多方法分组 - GET/POST/PUT/DELETE
  TC-GROUP-03: 分组内参数路由
  TC-GROUP-04: 嵌套分组（变量形式 + 链式形式）
  TC-GROUP-05: 带约定的分组（add() 应用 metadata）
  TC-GROUP-06: 分组路由与普通路由共存
"""
import pytest
from conftest import get, post, put, delete


# ============================================================
# TC-GROUP-01/02/03: 基础分组
# ============================================================

class TestGroupBasic:
    """基础分组：前缀 /group/api"""

    def test_tc_group_01_get_hello(self):
        """GET /group/api/hello → 200"""
        r = get("/group/api/hello")
        assert r.status_code == 200
        assert r.json()["matched"] is True
        assert r.json()["group"] == "api"

    def test_tc_group_02a_post_items(self):
        """POST /group/api/items → 200"""
        r = post("/group/api/items")
        assert r.status_code == 200
        assert r.json()["method"] == "POST"

    def test_tc_group_02b_put_items(self):
        """PUT /group/api/items → 200"""
        r = put("/group/api/items")
        assert r.status_code == 200
        assert r.json()["method"] == "PUT"

    def test_tc_group_02c_delete_items(self):
        """DELETE /group/api/items → 200"""
        r = delete("/group/api/items")
        assert r.status_code == 200
        assert r.json()["method"] == "DELETE"

    def test_tc_group_03_param_route(self):
        """GET /group/api/users/{id} 路由参数提取"""
        r = get("/group/api/users/42")
        assert r.status_code == 200
        assert r.json()["id"] == "42"

    def test_tc_group_03_param_route_string(self):
        """GET /group/api/users/{id} 字符串参数"""
        r = get("/group/api/users/alice")
        assert r.status_code == 200
        assert r.json()["id"] == "alice"

    def test_tc_group_no_match_outside_prefix(self):
        """直接访问未加前缀的子路径 → 404"""
        r = get("/hello")
        assert r.status_code == 404

    def test_tc_group_method_not_allowed(self):
        """POST /group/api/hello（仅注册 GET）→ 405"""
        r = post("/group/api/hello")
        assert r.status_code == 405


# ============================================================
# TC-GROUP-04: 嵌套分组
# ============================================================

class TestGroupNested:
    """嵌套分组：/group/v1 → /group/v1/items"""

    def test_tc_group_04a_nested_list(self):
        """GET /group/v1/items → 200"""
        r = get("/group/v1/items")
        assert r.status_code == 200
        assert r.json()["matched"] is True

    def test_tc_group_04b_nested_param(self):
        """GET /group/v1/items/{id} → 200，参数正确"""
        r = get("/group/v1/items/99")
        assert r.status_code == 200
        assert r.json()["id"] == "99"

    def test_tc_group_04c_chained_detail(self):
        """链式 mapGroup("f").mapGroup("a"): GET /group/chain/x/y/detail → 200"""
        r = get("/group/chain/x/y/detail")
        assert r.status_code == 200
        assert r.json()["matched"] is True

    def test_tc_group_04d_chained_param(self):
        """链式嵌套参数路由: GET /group/chain/x/y/items/{id} → 200"""
        r = get("/group/chain/x/y/items/123")
        assert r.status_code == 200
        assert r.json()["id"] == "123"

    def test_tc_group_04e_chained_no_match_partial_prefix(self):
        """链式嵌套：仅匹配完整前缀，/group/chain/x/detail 不存在 → 404"""
        r = get("/group/chain/x/detail")
        assert r.status_code == 404


# ============================================================
# TC-GROUP-05: 带约定的分组
# ============================================================

class TestGroupConvention:
    """分组约定：add() 应用到组内所有端点"""

    def test_tc_group_05a_dashboard_convention(self):
        """GET /group/admin/dashboard → convention 已应用"""
        r = get("/group/admin/dashboard")
        assert r.status_code == 200
        assert r.json()["convention"] is True

    def test_tc_group_05b_users_convention(self):
        """POST /group/admin/users → convention 已应用"""
        r = post("/group/admin/users")
        assert r.status_code == 200
        assert r.json()["convention"] is True


# ============================================================
# TC-GROUP-06: 分组路由与普通路由共存
# ============================================================

class TestGroupCoexist:
    """分组路由与普通路由在同一 builder 注册"""

    def test_tc_group_06a_standalone(self):
        """普通路由 GET /group/standalone → 200"""
        r = get("/group/standalone")
        assert r.status_code == 200
        assert r.json()["type"] == "standalone"

    def test_tc_group_06b_grouped(self):
        """分组路由 GET /group/coexist/a → 200"""
        r = get("/group/coexist/a")
        assert r.status_code == 200
        assert r.json()["type"] == "grouped"

    def test_tc_group_06c_standalone_not_affected(self):
        """普通路由不受分组前缀影响"""
        r = get("/group/coexist/standalone")
        assert r.status_code == 404
