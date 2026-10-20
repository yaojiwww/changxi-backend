"""
test_no_body_statuses.py — 无响应体状态码的协议约束验证

覆盖点：
  1. 204/205/304 不应携带 Transfer-Encoding: chunked
  2. 即使上游误设 transfer-encoding，宿主层也会在 OnStarting 清理
  3. 204/205/304 下尝试写 body 会被宿主层拦截，并落为 500
"""

import socket
from urllib.parse import urlparse
import os

from conftest import get


_BASE = os.environ.get("TEST_SERVER_HOST", "http://localhost").rstrip("/")
_PORT_BASE = int(os.environ.get("TEST_SERVER_PORT_BASE", "15100"))
_URL = os.environ.get("TEST_SERVER_URL", f"{_BASE}:{_PORT_BASE}")
_PARSED = urlparse(_URL)
_HOST = _PARSED.hostname or "127.0.0.1"
_PORT = _PARSED.port or 15100


def raw_get(path: str) -> bytes:
    request = (
        f"GET {path} HTTP/1.1\r\n"
        f"Host: {_HOST}\r\n"
        "Connection: close\r\n"
        "\r\n"
    ).encode("ascii")

    with socket.create_connection((_HOST, _PORT), timeout=5) as sock:
        sock.sendall(request)
        chunks = []
        while True:
            data = sock.recv(4096)
            if not data:
                break
            chunks.append(data)
    return b"".join(chunks)


class TestNoBodyStatuses:

    def test_204_has_no_body(self):
        r = get("/status/204")
        assert r.status_code == 204
        assert r.content == b""

    def test_204_has_no_transfer_encoding(self):
        r = get("/status/204")
        assert "transfer-encoding" not in r.headers

    def test_304_has_no_body(self):
        r = get("/status/304")
        assert r.status_code == 304
        assert r.content == b""

    def test_205_has_no_body(self):
        r = get("/status/205")
        assert r.status_code == 205
        assert r.content == b""

    def test_304_has_no_transfer_encoding(self):
        r = get("/status/304")
        assert "transfer-encoding" not in r.headers

    def test_205_has_no_transfer_encoding(self):
        r = get("/status/205")
        assert "transfer-encoding" not in r.headers

    def test_204_manual_chunked_is_stripped(self):
        raw = raw_get("/status/204-manual-chunked").decode("iso-8859-1")
        assert "HTTP/1.1 204 No Content" in raw
        assert "Transfer-Encoding: chunked" not in raw
        assert "transfer-encoding: chunked" not in raw

    def test_205_manual_chunked_is_stripped(self):
        raw = raw_get("/status/205-manual-chunked").decode("iso-8859-1")
        assert "HTTP/1.1 205 Reset Content" in raw
        assert "Transfer-Encoding: chunked" not in raw
        assert "transfer-encoding: chunked" not in raw

    def test_304_manual_chunked_is_stripped(self):
        raw = raw_get("/status/304-manual-chunked").decode("iso-8859-1")
        assert "HTTP/1.1 304 Not Modified" in raw
        assert "Transfer-Encoding: chunked" not in raw
        assert "transfer-encoding: chunked" not in raw

    def test_write_body_under_204_becomes_500(self):
        r = get("/status/204-write-body")
        assert r.status_code == 500
        assert len(r.content) > 0

    def test_write_body_under_205_becomes_500(self):
        r = get("/status/205-write-body")
        assert r.status_code == 500
        assert len(r.content) > 0

    def test_write_body_under_304_becomes_500(self):
        r = get("/status/304-write-body")
        assert r.status_code == 500
        assert len(r.content) > 0
