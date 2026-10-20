"""
test_ch08_dfa_builder.py - 第八章：DFA 构建行为 DfaMatcherBuilder [P2]
测试用例：TC188-195

说明：DFA 内部结构无法直接通过 HTTP 检查，通过行为验证间接确认 DFA 构建正确性。
"""
import pytest
from conftest import get


# ============================================================
# 8.1 字面量前缀共享 (TC188-190)
# ============================================================

class TestPrefixSharing:
    """8.1 字面量前缀共享"""

    def test_tc188_api_users(self):
        """TC188: /api/users 与 /api/posts 共享 /api 节点 → /api/users 命中"""
        r = get("/ch08/api/users")
        assert r.status_code == 200
        assert r.json()["matched"] is True

    def test_tc188_api_posts(self):
        """TC188: /api/posts 命中"""
        r = get("/ch08/api/posts")
        assert r.status_code == 200

    def test_tc189_api_v1(self):
        """TC189: /api/v1 命中"""
        r = get("/ch08/api/v1")
        assert r.status_code == 200

    def test_tc189_api_v2(self):
        """TC189: /api/v2 命中"""
        r = get("/ch08/api/v2")
        assert r.status_code == 200

    def test_tc190_users_root(self):
        """TC190: /users 命中（根节点分叉）"""
        r = get("/ch08/users")
        assert r.status_code == 200

    def test_tc190_posts_root(self):
        """TC190: /posts 命中（根节点分叉）"""
        r = get("/ch08/posts")
        assert r.status_code == 200

    def test_tc188_api_other_404(self):
        """TC188 逆向: /api/other → 无匹配（404）"""
        r = get("/ch08/api/other")
        assert r.status_code == 404


# ============================================================
# 8.2 字面量与参数节点共存 (TC191-192)
# ============================================================

class TestLiteralParamCoexist:
    """8.2 字面量与参数节点共存"""

    def test_tc191_literal_me_wins(self):
        """TC191: /users/me + /users/{id} → /me 走字面量节点"""
        r = get("/ch08/mixed/me")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_me"

    def test_tc191_param_for_numeric(self):
        """TC191: /users/42 → 走参数节点"""
        r = get("/ch08/mixed/42")
        assert r.status_code == 200
        assert r.json()["route"] == "param"
        assert r.json()["id"] == "42"

    def test_tc191_param_for_string(self):
        """TC191: /users/alice → 走参数节点"""
        r = get("/ch08/mixed/alice")
        assert r.status_code == 200
        assert r.json()["route"] == "param"
        assert r.json()["id"] == "alice"

    def test_tc192_three_way_literal(self):
        """TC192: /three/me → 走字面量节点"""
        r = get("/ch08/three/me")
        assert r.status_code == 200
        assert r.json()["route"] == "literal_me"

    def test_tc192_three_way_constrained(self):
        """TC192: /three/42 → 走约束参数节点（int 约束通过）"""
        r = get("/ch08/three/42")
        assert r.status_code == 200
        assert r.json()["route"] == "constrained"
        assert r.json()["id"] == "42"

    def test_tc192_three_way_unconstrained(self):
        """TC192: /three/abc → 走普通参数节点（约束失败回退）"""
        r = get("/ch08/three/abc")
        assert r.status_code == 200
        assert r.json()["route"] == "unconstrained"
        assert r.json()["name"] == "abc"


# ============================================================
# 8.3 Catch-all 自循环节点 (TC193-194)
# ============================================================

class TestCatchAllSelfLoop:
    """8.3 Catch-all 自循环节点"""

    def test_tc193_single_segment(self):
        """TC193: catch-all 单段命中"""
        r = get("/ch08/catchall/a")
        assert r.status_code == 200
        assert r.json()["path"] == "a"

    def test_tc194_five_segments(self):
        """TC194: catch-all 5 段深度命中（验证自循环）"""
        r = get("/ch08/catchall/a/b/c/d/e")
        assert r.status_code == 200
        assert r.json()["path"] == "a/b/c/d/e"

    def test_tc194_ten_segments(self):
        """TC194: catch-all 10 段深度命中"""
        segments = "/".join(str(i) for i in range(10))
        r = get(f"/ch08/catchall/{segments}")
        assert r.status_code == 200
        assert r.json()["path"] == segments

    def test_tc194_empty_catchall(self):
        """TC194: catch-all 为空（/ch08/catchall/）"""
        r = get("/ch08/catchall/")
        assert r.status_code == 200
        assert r.json()["path"] == ""


# ============================================================
# 8.4 必需值参数转为字面量 (TC195)
# ============================================================

class TestRequiredValues:
    """8.4 必需值参数转为字面量"""

    def test_tc195_defaults_used_when_omitted(self):
        """TC195: /{controller=Home}/{action=Index} + / → 使用默认值"""
        r = get("/ch08/mvc/")
        assert r.status_code == 200
        data = r.json()
        assert data["controller"] == "Home"
        assert data["action"] == "Index"

    def test_tc195_defaults_overridden(self):
        """TC195: /{controller=Home}/{action=Index} + /About/Edit → 使用提供值"""
        r = get("/ch08/mvc/About/Edit")
        assert r.status_code == 200
        data = r.json()
        assert data["controller"] == "About"
        assert data["action"] == "Edit"
