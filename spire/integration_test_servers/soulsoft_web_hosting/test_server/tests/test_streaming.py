"""
test_streaming.py — 流式传输与 SSE 行为验证

端点：
  GET /chunked   多次 write() → Transfer-Encoding: chunked
  GET /sse       Server-Sent Events（3 个事件，text/event-stream）

SSE 格式（RFC 8895）：
  每个事件以 "data: <msg>\\n\\n" 表示，双换行为事件分隔符。
  服务端发完全部事件后关闭连接，客户端收到完整 body。
"""

import pytest
from conftest import get


# ════════════════════════════════════════════════════════════════════════════
# 1. 流式分块响应（Transfer-Encoding: chunked）
# ════════════════════════════════════════════════════════════════════════════

class TestChunkedResponse:

    def test_status_200(self):
        r = get("/chunked")
        assert r.status_code == 200

    def test_body_concatenated(self):
        """多次 write() 的内容由 HTTP 客户端自动拼接"""
        r = get("/chunked")
        assert r.text == "part1part2part3"

    def test_transfer_encoding_chunked(self):
        """无 Content-Length 时框架自动追加 Transfer-Encoding: chunked"""
        r = get("/chunked")
        assert "chunked" in r.headers.get("transfer-encoding", "")

    def test_no_content_length_when_chunked(self):
        """使用 chunked 时不应同时出现 Content-Length"""
        r = get("/chunked")
        assert "content-length" not in r.headers

    def test_body_length_correct(self):
        """实际接收的字节数与预期一致"""
        r = get("/chunked")
        assert len(r.content) == len(b"part1part2part3")


# ════════════════════════════════════════════════════════════════════════════
# 2. Server-Sent Events（SSE）
# ════════════════════════════════════════════════════════════════════════════

class TestSSE:

    def test_status_200(self):
        r = get("/sse")
        assert r.status_code == 200

    def test_content_type_event_stream(self):
        """SSE 响应的 Content-Type 必须为 text/event-stream"""
        r = get("/sse")
        assert "text/event-stream" in r.headers["content-type"]

    def test_cache_control_no_cache(self):
        """SSE 应携带 Cache-Control: no-cache，防止代理缓存"""
        r = get("/sse")
        assert "no-cache" in r.headers.get("cache-control", "")

    def test_transfer_encoding_chunked(self):
        """SSE 无预设长度，使用 Transfer-Encoding: chunked"""
        r = get("/sse")
        assert "chunked" in r.headers.get("transfer-encoding", "")

    def test_body_contains_event1(self):
        r = get("/sse")
        assert "data: event1" in r.text

    def test_body_contains_event2(self):
        r = get("/sse")
        assert "data: event2" in r.text

    def test_body_contains_event3(self):
        r = get("/sse")
        assert "data: event3" in r.text

    def test_events_separated_by_double_newline(self):
        """SSE 协议要求事件之间以 \\n\\n 分隔"""
        r = get("/sse")
        assert "data: event1\n\n" in r.text

    def test_event_count(self):
        """共收到 3 个 SSE 事件（以 data: 前缀计数）"""
        r = get("/sse")
        events = [line for line in r.text.splitlines() if line.startswith("data:")]
        assert len(events) == 3

    def test_event_order(self):
        """事件按 event1 → event2 → event3 顺序到达"""
        r = get("/sse")
        events = [line for line in r.text.splitlines() if line.startswith("data:")]
        assert events == ["data: event1", "data: event2", "data: event3"]

    def test_sse_streaming_via_iter_lines(self):
        """使用 stream=True + iter_lines 逐行读取，模拟真实 SSE 客户端"""
        r = get("/sse", stream=True)
        assert r.status_code == 200
        lines = [line.decode() for line in r.iter_lines()]
        data_lines = [l for l in lines if l.startswith("data:")]
        assert data_lines == ["data: event1", "data: event2", "data: event3"]

    def test_multiple_sse_requests(self):
        """SSE 端点可被多次独立请求，每次均返回完整事件序列"""
        for _ in range(3):
            r = get("/sse")
            assert r.status_code == 200
            events = [l for l in r.text.splitlines() if l.startswith("data:")]
            assert len(events) == 3
