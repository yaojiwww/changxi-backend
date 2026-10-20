"""
test_ch05_complex_seg.py - 第五章：复合段匹配 [P1]
测试用例：TC128-145
"""
import pytest
from conftest import get


# ============================================================
# 5.1 前缀字面量 + 参数 (TC128-132)
# ============================================================

class TestPrefixParam:
    """5.1 前缀字面量 + 参数"""

    def test_tc128_prefix_v_match(self):
        """TC128: v{version} + 'v2' → version='2'"""
        r = get("/ch05/prefix/v2")
        assert r.status_code == 200
        assert r.json()["version"] == "2"

    def test_tc129_prefix_v_empty_param(self):
        """TC129: v{version} + 'v' → 失败（参数值为空）"""
        r = get("/ch05/prefix/v")
        assert r.status_code == 404

    def test_tc130_prefix_v_missing(self):
        """TC130: v{version} + '2' → 失败（前缀 'v' 不存在）"""
        r = get("/ch05/prefix/2")
        assert r.status_code == 404

    def test_tc132_prefix_api_dash(self):
        """TC132: api-{name} + 'api-hello' → name='hello'"""
        r = get("/ch05/prefix/api-hello")
        assert r.status_code == 200
        assert r.json()["name"] == "hello"


# ============================================================
# 5.2 参数 + 后缀字面量 (TC133-136)
# ============================================================

class TestSuffixParam:
    """5.2 参数 + 后缀字面量"""

    def test_tc133_suffix_html(self):
        """TC133: {name}.html + 'readme.html' → name='readme'"""
        r = get("/ch05/suffix/readme.html")
        assert r.status_code == 200
        assert r.json()["name"] == "readme"

    def test_tc134_wrong_suffix(self):
        """TC134: {name}.html + 'readme.txt' → 失败（后缀不匹配）"""
        r = get("/ch05/suffix/readme.txt")
        assert r.status_code == 404

    def test_tc135_empty_param_with_suffix(self):
        """TC135: {name}.html + '.html' → 失败（参数值为空）"""
        r = get("/ch05/suffix/.html")
        assert r.status_code == 404

    def test_tc136_extra_suffix(self):
        """TC136: {name}.html + 'readme.html.bak' → 失败（后缀不在末尾）"""
        r = get("/ch05/suffix/readme.html.bak")
        assert r.status_code == 404


# ============================================================
# 5.3 参数-分隔符-参数 (TC137-142)
# ============================================================

class TestSeparatorParams:
    """5.3 参数-分隔符-参数"""

    def test_tc137_dash_separator(self):
        """TC137: {a}-{b} + 'foo-bar' → a='foo', b='bar'"""
        r = get("/ch05/sep/dash/foo-bar")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "foo"
        assert data["b"] == "bar"

    def test_tc138_greedy_left_match(self):
        """TC138: {a}-{b} + 'foo-bar-baz' → a='foo-bar', b='baz'（从左贪婪匹配）"""
        r = get("/ch05/sep/dash/foo-bar-baz")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "foo-bar"
        assert data["b"] == "baz"

    def test_tc139_no_separator(self):
        """TC139: {a}-{b} + 'foo' → 失败（无分隔符）"""
        r = get("/ch05/sep/dash/foo")
        assert r.status_code == 404

    def test_tc140_empty_first_param(self):
        """TC140: {a}-{b} + '-bar' → 失败（a 为空）"""
        r = get("/ch05/sep/dash/-bar")
        assert r.status_code == 404

    def test_tc141_empty_second_param(self):
        """TC141: {a}-{b} + 'foo-' → 失败（b 为空）"""
        r = get("/ch05/sep/dash/foo-")
        assert r.status_code == 404

    def test_tc142_dot_separator(self):
        """TC142: {a}.{b} + 'readme.md' → a='readme', b='md'"""
        r = get("/ch05/sep/dot/readme.md")
        assert r.status_code == 200
        data = r.json()
        assert data["a"] == "readme"
        assert data["b"] == "md"


# ============================================================
# 5.4 末尾 optional 参数 (TC143-145)
# ============================================================

class TestOptionalSuffixParam:
    """5.4 末尾 optional 参数"""

    def test_tc143_optional_ext_provided(self):
        """TC143: {name}.{ext?} + 'readme.md' → name='readme', ext='md'"""
        r = get("/ch05/optSuffix/readme.md")
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "readme"
        assert data["ext"] == "md"

    def test_tc144_optional_ext_omitted(self):
        """TC144: {name}.{ext?} + 'readme' → name='readme', ext=null"""
        r = get("/ch05/optSuffix/readme")
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "readme"
        assert data["ext"] is None

    def test_tc145_optional_ext_empty(self):
        """TC145: {name}.{ext?} + 'readme.' → 失败（'.' 结尾但 ext 为空）"""
        r = get("/ch05/optSuffix/readme.")
        assert r.status_code == 404
