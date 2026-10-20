"""
test_ch09_dict.py - 第九章：RouteValueDictionary [P2]
测试用例：TC196-204

通过 /meta/dict/tcXXX 端点验证各字典操作的语义。
"""
from conftest import get


class TestRouteValueDictionary:
    """9.1 RouteValueDictionary 基本操作"""

    def test_tc196_add_then_get(self):
        """TC196: add('id','1'); get('id') → Some(Some('1'))"""
        r = get("/meta/dict/tc196")
        assert r.status_code == 200
        result = r.json()["result"]
        assert "1" in result, f"期望结果包含 '1'，实际: {result}"

    def test_tc197_get_missing_key(self):
        """TC197: get('missing') → None"""
        r = get("/meta/dict/tc197")
        assert r.status_code == 200
        assert r.json()["result"] == "None"

    def test_tc198_add_none_then_get(self):
        """TC198: add('id', None); get('id') → Some(None)"""
        r = get("/meta/dict/tc198")
        assert r.status_code == 200
        result = r.json()["result"]
        assert "None" in result, f"期望结果包含 'None'，实际: {result}"

    def test_tc199_add_twice_overwrites(self):
        """TC199: add('id','1'); add('id','2'); get('id') → '2'（覆盖）"""
        r = get("/meta/dict/tc199")
        assert r.status_code == 200
        result = r.json()["result"]
        assert "2" in result, f"期望结果包含 '2'，实际: {result}"
        assert "1" not in result.replace("2", ""), f"不应包含旧值 '1'，实际: {result}"

    def test_tc200_from_array(self):
        """TC200: fromArray([('id','1'),('name','tom')]); get('name') → Some(Some('tom'))"""
        r = get("/meta/dict/tc200")
        assert r.status_code == 200
        result = r.json()["result"]
        assert "tom" in result, f"期望结果包含 'tom'，实际: {result}"

    def test_tc201_contains_after_add(self):
        """TC201: contains('id') 在 add 后 → true"""
        r = get("/meta/dict/tc201")
        assert r.status_code == 200
        assert r.json()["result"] is True

    def test_tc202_contains_before_add(self):
        """TC202: contains('x') 在未 add 时 → false"""
        r = get("/meta/dict/tc202")
        assert r.status_code == 200
        assert r.json()["result"] is False

    def test_tc203_add_if_absent_when_exists(self):
        """TC203: addIfAbsent('id','new') 在已有 id 时 → 原值 'original' 保留"""
        r = get("/meta/dict/tc203")
        assert r.status_code == 200
        assert r.json()["result"] == "original"

    def test_tc204_add_if_absent_when_missing(self):
        """TC204: addIfAbsent('x','v') 在无 x 时 → 写入 x='v'"""
        r = get("/meta/dict/tc204")
        assert r.status_code == 200
        assert r.json()["result"] == "v"
