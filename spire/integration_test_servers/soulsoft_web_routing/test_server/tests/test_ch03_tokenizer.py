"""
test_ch03_tokenizer.py - 第三章：路径分词 FastPathTokenizer [P1]
测试用例：TC64-75

通过 /meta/tokenize?path=xxx 端点验证分词结果。
"""
import urllib.parse
from conftest import get


def tokenize(path: str) -> dict:
    """调用 /meta/tokenize 端点"""
    encoded = urllib.parse.quote(path, safe="")
    r = get(f"/meta/tokenize?path={encoded}")
    assert r.status_code == 200
    return r.json()


# ============================================================
# 3.1 正常分词 (TC64-68)
# ============================================================

class TestNormalTokenization:
    """3.1 正常分词"""

    def test_tc64_root_path(self):
        """TC64: / → 0 段"""
        d = tokenize("/")
        assert d["count"] == 0
        assert d["segments"] == []

    def test_tc65_empty_string(self):
        """TC65: '' → 0 段"""
        d = tokenize("")
        assert d["count"] == 0
        assert d["segments"] == []

    def test_tc66_single_segment(self):
        """TC66: /users → 1 段 ['users']"""
        d = tokenize("/users")
        assert d["count"] == 1
        assert d["segments"] == ["users"]

    def test_tc67_three_segments(self):
        """TC67: /api/v1/users → 3 段"""
        d = tokenize("/api/v1/users")
        assert d["count"] == 3
        assert d["segments"] == ["api", "v1", "users"]

    def test_tc68_four_segments(self):
        """TC68: /api/v1/users/42 → 4 段"""
        d = tokenize("/api/v1/users/42")
        assert d["count"] == 4
        assert d["segments"] == ["api", "v1", "users", "42"]


# ============================================================
# 3.2 尾随斜杠处理 (TC69-70)
# ============================================================

class TestTrailingSlash:
    """3.2 尾随斜杠处理"""

    def test_tc69_trailing_slash_single(self):
        """TC69: /users/ → 1 段（尾随空段被过滤）"""
        d = tokenize("/users/")
        assert d["count"] == 1
        assert d["segments"] == ["users"]

    def test_tc70_trailing_slash_multi(self):
        """TC70: /api/v1/ → 2 段（尾随空段被过滤）"""
        d = tokenize("/api/v1/")
        assert d["count"] == 2
        assert d["segments"] == ["api", "v1"]


# ============================================================
# 3.3 连续斜杠处理 (TC71-73)
# ============================================================

class TestConsecutiveSlashes:
    """3.3 连续斜杠处理"""

    def test_tc71_leading_double_slash(self):
        """TC71: //users → 1 段（头部空段被过滤）"""
        d = tokenize("//users")
        assert d["count"] == 1
        assert d["segments"] == ["users"]

    def test_tc72_middle_double_slash(self):
        """TC72: /a//b → 2 段（中间空段被过滤）"""
        d = tokenize("/a//b")
        assert d["count"] == 2
        assert d["segments"] == ["a", "b"]

    def test_tc73_multiple_double_slashes(self):
        """TC73: /a//b//c → 3 段（多处空段全部过滤）"""
        d = tokenize("/a//b//c")
        assert d["count"] == 3
        assert d["segments"] == ["a", "b", "c"]


# ============================================================
# 3.4 PathSegment 区间正确性 (TC74-75)
# ============================================================

class TestPathSegmentInterval:
    """3.4 PathSegment 区间正确性"""

    def test_tc74_segment_interval(self):
        """TC74: /api/users → segment[1] 区间 [start:end] 还原为 'users'"""
        d = tokenize("/api/users")
        assert d["count"] == 2
        assert d["segments"][1] == "users"
        # 验证区间正确性
        path = "/api/users"
        start = d["starts"][1]
        end = d["ends"][1]
        assert path[start:end] == "users", (
            f"区间 [{start}:{end}] 从 '{path}' 提取应为 'users'，实际 '{path[start:end]}'"
        )

    def test_tc75_case_preserved_in_interval(self):
        """TC75: /Users/42 → segment[0]='Users'（原始大小写保留）"""
        d = tokenize("/Users/42")
        assert d["count"] == 2
        assert d["segments"][0] == "Users"  # 原始大小写保留
        # 验证区间提取
        path = "/Users/42"
        start = d["starts"][0]
        end = d["ends"][0]
        assert path[start:end] == "Users", (
            f"区间 [{start}:{end}] 从 '{path}' 提取应为 'Users'，实际 '{path[start:end]}'"
        )
