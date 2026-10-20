"""
test_static_files.py — StaticFileMiddleware 行为验证

服务器与场景：
  5001 (URL_ROOT)   — useStaticFiles 无 requestPath，直接以 / 开头访问
  5002 (URL_PREFIX) — useStaticFiles requestPath=/s，serveUnknownFileTypes=true

wwwroot 文件树：
  hello.txt          "Hello, World!"     13 bytes  text/plain
  page.html          "<h1>Hello</h1>"    14 bytes  text/html
  data.xyz           "xyz data"           8 bytes  未知类型
  sub/index.html     "<h1>Sub Index</h1>"           text/html
"""

from datetime import datetime, timezone
from conftest import get, head, req, URL_ROOT, URL_PREFIX

# 通用日期常量
_PAST   = "Sat, 01 Jan 2000 00:00:00 GMT"
_FUTURE = "Thu, 01 Jan 2099 00:00:00 GMT"


# ════════════════════════════════════════════════════════════════════════════
# 1. 根路径服务（无 requestPath，server 5001）
# ════════════════════════════════════════════════════════════════════════════

class TestRootPath:
    """useStaticFiles 无 requestPath：路径直接以 / 开头"""

    def test_get_file_returns_200(self):
        r = get(URL_ROOT, "/hello.txt")
        assert r.status_code == 200

    def test_get_file_body(self):
        r = get(URL_ROOT, "/hello.txt")
        assert r.text == "Hello, World!"

    def test_get_file_content_type(self):
        r = get(URL_ROOT, "/hello.txt")
        assert "text/plain" in r.headers["content-type"]

    def test_get_html_content_type(self):
        r = get(URL_ROOT, "/page.html")
        assert r.status_code == 200
        assert "text/html" in r.headers["content-type"]

    def test_missing_file_returns_404(self):
        r = get(URL_ROOT, "/no-such-file.txt")
        assert r.status_code == 404

    def test_unknown_type_blocked_by_default(self):
        """serveUnknownFileTypes 默认 false → .xyz 不提供 → 404"""
        r = get(URL_ROOT, "/data.xyz")
        assert r.status_code == 404

    # ── 不以 / 结尾的目录路径（静态文件中间件不处理目录）──────────────────
    def test_directory_without_slash_not_served(self):
        """StaticFileMiddleware 不处理目录路径，直接 pass-through → 404"""
        r = req("GET", URL_ROOT, "/sub", allow_redirects=False)
        assert r.status_code == 404

    # ── 以 / 结尾的目录路径（无 DefaultFiles，同样不服务）────────────────
    def test_directory_with_slash_not_served(self):
        """无 DefaultFiles 中间件，/sub/ 也不能提供目录 → 404"""
        r = get(URL_ROOT, "/sub/")
        assert r.status_code == 404

    # ── 子目录中的文件可以访问 ────────────────────────────────────────────
    def test_file_in_subdirectory(self):
        r = get(URL_ROOT, "/sub/index.html")
        assert r.status_code == 200
        assert "Sub Index" in r.text


# ════════════════════════════════════════════════════════════════════════════
# 2. 带前缀路径服务（requestPath=/s，server 5002）
# ════════════════════════════════════════════════════════════════════════════

class TestPrefixPath:
    """useStaticFiles requestPath=/s：需以 /s 前缀访问"""

    def test_with_prefix_returns_200(self):
        r = get(URL_PREFIX, "/s/hello.txt")
        assert r.status_code == 200
        assert r.text == "Hello, World!"

    def test_without_prefix_returns_404(self):
        """无前缀路径不在范围内 → 404"""
        r = get(URL_PREFIX, "/hello.txt")
        assert r.status_code == 404

    def test_prefix_root_without_slash(self):
        """/s（无尾斜杠，非文件路径）→ StaticFileMiddleware 不处理 → 404"""
        r = req("GET", URL_PREFIX, "/s", allow_redirects=False)
        assert r.status_code == 404

    def test_prefix_root_with_slash(self):
        """/s/（无默认文件）→ 404"""
        r = get(URL_PREFIX, "/s/")
        assert r.status_code == 404

    def test_unknown_type_served(self):
        """serveUnknownFileTypes=true → .xyz 文件正常提供 → 200"""
        r = get(URL_PREFIX, "/s/data.xyz")
        assert r.status_code == 200

    def test_unknown_type_content_type(self):
        r = get(URL_PREFIX, "/s/data.xyz")
        assert "application/octet-stream" in r.headers["content-type"]

    def test_known_type_in_prefix_server(self):
        r = get(URL_PREFIX, "/s/page.html")
        assert r.status_code == 200
        assert "text/html" in r.headers["content-type"]


# ════════════════════════════════════════════════════════════════════════════
# 3. 响应头验证（以根路径服务器为基准）
# ════════════════════════════════════════════════════════════════════════════

class TestResponseHeaders:
    """200 响应必须包含的标准头字段"""

    PATH = "/hello.txt"

    def test_content_length(self):
        r = get(URL_ROOT, self.PATH)
        assert r.headers.get("content-length") == "13"

    def test_etag_present_and_quoted(self):
        """ETag 值必须以双引号包裹"""
        r = get(URL_ROOT, self.PATH)
        etag = r.headers.get("etag", "")
        assert etag.startswith('"') and etag.endswith('"'), f"ETag 格式错误: {etag!r}"

    def test_last_modified_present(self):
        r = get(URL_ROOT, self.PATH)
        assert "last-modified" in r.headers

    def test_last_modified_format(self):
        """Last-Modified 格式：RFC 7231 IMF-fixdate，以 GMT 结尾"""
        r = get(URL_ROOT, self.PATH)
        lm = r.headers["last-modified"]
        assert lm.endswith("GMT"), f"Last-Modified 格式错误: {lm!r}"

    def test_accept_ranges_bytes(self):
        r = get(URL_ROOT, self.PATH)
        assert r.headers.get("accept-ranges") == "bytes"

    def test_304_no_body_but_has_etag(self):
        """304 响应应包含 ETag，不含正文"""
        etag = get(URL_ROOT, self.PATH).headers["etag"]
        r = get(URL_ROOT, self.PATH, headers={"If-None-Match": etag})
        assert r.status_code == 304
        assert r.content == b""
        assert "etag" in r.headers

    def test_404_has_no_etag(self):
        r = get(URL_ROOT, "/missing.txt")
        assert r.status_code == 404
        assert "etag" not in r.headers


# ════════════════════════════════════════════════════════════════════════════
# 4. HEAD 请求
# ════════════════════════════════════════════════════════════════════════════

class TestHeadRequest:
    PATH = "/hello.txt"

    def test_head_200(self):
        r = head(URL_ROOT, self.PATH)
        assert r.status_code == 200

    def test_head_content_type(self):
        r = head(URL_ROOT, self.PATH)
        assert "text/plain" in r.headers["content-type"]

    def test_head_content_length(self):
        r = head(URL_ROOT, self.PATH)
        assert r.headers["content-length"] == "13"

    def test_head_etag(self):
        r = head(URL_ROOT, self.PATH)
        assert "etag" in r.headers

    def test_head_body_empty(self):
        r = head(URL_ROOT, self.PATH)
        assert r.content == b""

    def test_get_no_declared_content_length(self):
        """GET 200 不应手动声明 Content-Length，由服务器自动处理，避免写入量不足报错"""
        r = get(URL_ROOT, self.PATH)
        assert r.status_code == 200
        assert r.text == "Hello, World!"
        # content-length 若存在必须与实际 body 一致
        if "content-length" in r.headers:
            assert int(r.headers["content-length"]) == len(r.content)

    def test_head_etag_matches_get(self):
        """HEAD 和 GET 返回的 ETag 应一致"""
        etag_head = head(URL_ROOT, self.PATH).headers["etag"]
        etag_get  = get(URL_ROOT, self.PATH).headers["etag"]
        assert etag_head == etag_get


# ════════════════════════════════════════════════════════════════════════════
# 5. 条件请求 — ETag
# ════════════════════════════════════════════════════════════════════════════

class TestETag:
    PATH = "/hello.txt"

    def _etag(self):
        return get(URL_ROOT, self.PATH).headers["etag"]

    def test_if_none_match_match_304(self):
        etag = self._etag()
        r = get(URL_ROOT, self.PATH, headers={"If-None-Match": etag})
        assert r.status_code == 304

    def test_if_none_match_mismatch_200(self):
        r = get(URL_ROOT, self.PATH, headers={"If-None-Match": '"stale"'})
        assert r.status_code == 200

    def test_if_none_match_wildcard_304(self):
        r = get(URL_ROOT, self.PATH, headers={"If-None-Match": "*"})
        assert r.status_code == 304

    def test_if_match_match_200(self):
        etag = self._etag()
        r = get(URL_ROOT, self.PATH, headers={"If-Match": etag})
        assert r.status_code == 200

    def test_if_match_mismatch_412(self):
        r = get(URL_ROOT, self.PATH, headers={"If-Match": '"stale"'})
        assert r.status_code == 412

    def test_if_match_wildcard_200(self):
        r = get(URL_ROOT, self.PATH, headers={"If-Match": "*"})
        assert r.status_code == 200


# ════════════════════════════════════════════════════════════════════════════
# 6. 条件请求 — 时间戳
# ════════════════════════════════════════════════════════════════════════════

class TestLastModified:
    PATH = "/hello.txt"

    def test_if_modified_since_future_ignored_200(self):
        """未来日期的 If-Modified-Since 被忽略（clock-skew guard）→ 200，对齐 ASP.NET Core 行为"""
        r = get(URL_ROOT, self.PATH, headers={"If-Modified-Since": _FUTURE})
        assert r.status_code == 200

    def test_if_modified_since_past_200(self):
        """文件在过去时间之后被修改 → 200"""
        r = get(URL_ROOT, self.PATH, headers={"If-Modified-Since": _PAST})
        assert r.status_code == 200

    def test_if_unmodified_since_future_200(self):
        """文件在未来时间前未改变 → 200"""
        r = get(URL_ROOT, self.PATH, headers={"If-Unmodified-Since": _FUTURE})
        assert r.status_code == 200

    def test_if_unmodified_since_past_412(self):
        """文件在过去时间之后被修改 → 412"""
        r = get(URL_ROOT, self.PATH, headers={"If-Unmodified-Since": _PAST})
        assert r.status_code == 412

    def test_if_modified_since_exact_last_modified_304(self):
        """If-Modified-Since 精确等于 Last-Modified → 未修改 → 304"""
        last_modified = get(URL_ROOT, self.PATH).headers["last-modified"]
        r = get(URL_ROOT, self.PATH, headers={"If-Modified-Since": last_modified})
        assert r.status_code == 304


# ════════════════════════════════════════════════════════════════════════════
# 7. Range 请求（RFC 7233）
# ════════════════════════════════════════════════════════════════════════════

class TestRange:
    # hello.txt = "Hello, World!" (13 bytes, index 0-12)
    PATH = "/hello.txt"

    def test_partial_range_206(self):
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4"})
        assert r.status_code == 206
        assert r.content == b"Hello"

    def test_partial_range_content_range_header(self):
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4"})
        assert r.headers["content-range"] == "bytes 0-4/13"

    def test_partial_range_content_length(self):
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4"})
        assert r.headers["content-length"] == "5"

    def test_mid_range(self):
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=7-12"})
        assert r.status_code == 206
        assert r.content == b"World!"

    def test_suffix_range(self):
        """bytes=-6 → 最后 6 字节"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=-6"})
        assert r.status_code == 206
        assert r.content == b"World!"

    def test_open_ended_range(self):
        """bytes=7- → 从偏移 7 到末尾"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=7-"})
        assert r.status_code == 206
        assert r.content == b"World!"

    def test_full_range(self):
        """bytes=0-12 → 206，完整内容"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-12"})
        assert r.status_code == 206
        assert r.content == b"Hello, World!"

    def test_end_clamped_to_file_length_206(self):
        """end > fileLength-1 → RFC 7233 §2.1 截断到末尾 → 206 全量内容"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-999"})
        assert r.status_code == 206
        assert r.content == b"Hello, World!"

    def test_range_start_beyond_file_416(self):
        """start >= fileLength → 范围不可满足 → 416"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=100-200"})
        assert r.status_code == 416

    def test_416_content_range_star(self):
        """416 响应：Content-Range: bytes */13"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=100-200"})
        assert r.headers["content-range"] == "bytes */13"

    def test_head_with_range_returns_200(self):
        """Range 仅适用于 GET；HEAD + Range → 200"""
        r = head(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4"})
        assert r.status_code == 200

    def test_multi_range_falls_back_to_200(self):
        """多范围不支持 → 忽略 Range，回退到 200 全量（对齐 ASP.NET Core 行为）"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4,7-12"})
        assert r.status_code == 200
        assert r.content == b"Hello, World!"

    # ── If-Range ETag ──────────────────────────────────────────────────────
    def test_if_range_etag_match_206(self):
        etag = get(URL_ROOT, self.PATH).headers["etag"]
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4", "If-Range": etag})
        assert r.status_code == 206
        assert r.content == b"Hello"

    def test_if_range_etag_mismatch_200(self):
        """If-Range ETag 不匹配 → 忽略 Range，返回 200 全量"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4", "If-Range": '"stale"'})
        assert r.status_code == 200
        assert r.content == b"Hello, World!"

    # ── If-Range 日期 ──────────────────────────────────────────────────────
    def test_if_range_date_exact_last_modified_206(self):
        """If-Range: <Last-Modified 精确值> → 文件未变化 → 206"""
        last_modified = get(URL_ROOT, self.PATH).headers["last-modified"]
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4", "If-Range": last_modified})
        assert r.status_code == 206
        assert r.content == b"Hello"

    def test_if_range_future_date_206(self):
        """If-Range: 未来日期 → 文件未在该日期后修改 → 206"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4", "If-Range": _FUTURE})
        assert r.status_code == 206
        assert r.content == b"Hello"

    def test_if_range_past_date_200(self):
        """If-Range: 过去日期 → 文件在该日期后被修改 → 忽略 Range → 200"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-4", "If-Range": _PAST})
        assert r.status_code == 200
        assert r.content == b"Hello, World!"


# ════════════════════════════════════════════════════════════════════════════
# 8. 大文件传输（> 64 KB 分块边界回归测试）
#
# 背景：body(Array<UInt8>) 每次调用会替换 body 而非追加，若分多块循环写入
#       只有最后一块被实际发送，导致截断。此组测试专门回归该 bug。
#
# 文件：index-BX8vdlTq.js  ~1.2 MB（1,246,943 字节）
# ════════════════════════════════════════════════════════════════════════════

import os as _os

_LARGE_FILE_PATH = _os.path.join(
    _os.path.dirname(__file__), "..", "wwwroot", "index-BX8vdlTq.js"
)
_LARGE_FILE_BYTES = open(_LARGE_FILE_PATH, "rb").read()
_LARGE_FILE_SIZE  = len(_LARGE_FILE_BYTES)   # 1 246 943


class TestLargeFile:
    """大文件（> 64 KB）传输完整性 — 回归 body() 替换语义导致截断的 bug"""

    PATH = "/index-BX8vdlTq.js"

    # ── 基础完整性 ────────────────────────────────────────────────────────

    def test_get_returns_200(self):
        r = get(URL_ROOT, self.PATH)
        assert r.status_code == 200

    def test_content_type_javascript(self):
        r = get(URL_ROOT, self.PATH)
        assert "javascript" in r.headers.get("content-type", "")

    def test_content_length_matches_file_size(self):
        """Content-Length 必须等于磁盘文件字节数"""
        r = get(URL_ROOT, self.PATH)
        assert int(r.headers["content-length"]) == _LARGE_FILE_SIZE

    def test_body_length_matches_file_size(self):
        """实际接收字节数必须等于磁盘文件字节数（核心回归：截断 bug）"""
        r = get(URL_ROOT, self.PATH)
        assert len(r.content) == _LARGE_FILE_SIZE

    def test_body_content_matches_file(self):
        """字节内容必须与磁盘文件完全一致（端到端完整性）"""
        r = get(URL_ROOT, self.PATH)
        assert r.content == _LARGE_FILE_BYTES

    def test_content_length_header_equals_actual_body(self):
        """Content-Length 头与实际 body 大小必须一致，不能有虚报"""
        r = get(URL_ROOT, self.PATH)
        assert int(r.headers["content-length"]) == len(r.content)

    # ── HEAD 请求 ─────────────────────────────────────────────────────────

    def test_head_content_length(self):
        """HEAD 也必须返回正确的 Content-Length"""
        r = head(URL_ROOT, self.PATH)
        assert r.status_code == 200
        assert int(r.headers["content-length"]) == _LARGE_FILE_SIZE

    def test_head_no_body(self):
        r = head(URL_ROOT, self.PATH)
        assert r.content == b""

    # ── 跨 64 KB 边界的 Range 请求 ────────────────────────────────────────

    def test_range_within_first_chunk(self):
        """bytes=0-99 — 首块内，最简单场景"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=0-99"})
        assert r.status_code == 206
        assert r.content == _LARGE_FILE_BYTES[0:100]
        assert r.headers["content-length"] == "100"

    def test_range_crossing_64k_boundary(self):
        """bytes=65000-131071 — 横跨第 1/2 块边界（64 KB = 65536）"""
        start, end = 65000, 131071
        r = get(URL_ROOT, self.PATH, headers={"Range": f"bytes={start}-{end}"})
        assert r.status_code == 206
        assert r.content == _LARGE_FILE_BYTES[start:end + 1]
        assert r.headers["content-length"] == str(end - start + 1)

    def test_range_crossing_128k_boundary(self):
        """bytes=131000-196607 — 横跨第 2/3 块边界"""
        start, end = 131000, 196607
        r = get(URL_ROOT, self.PATH, headers={"Range": f"bytes={start}-{end}"})
        assert r.status_code == 206
        assert r.content == _LARGE_FILE_BYTES[start:end + 1]

    def test_range_tail(self):
        """bytes=-1024 — 最后 1 KB"""
        r = get(URL_ROOT, self.PATH, headers={"Range": "bytes=-1024"})
        assert r.status_code == 206
        assert r.content == _LARGE_FILE_BYTES[-1024:]
        assert r.headers["content-length"] == "1024"

    def test_range_open_ended_from_middle(self):
        """bytes=1200000- — 从靠近末尾的偏移到 EOF"""
        start = 1_200_000
        r = get(URL_ROOT, self.PATH, headers={"Range": f"bytes={start}-"})
        assert r.status_code == 206
        expected = _LARGE_FILE_BYTES[start:]
        assert r.content == expected
        assert r.headers["content-length"] == str(len(expected))
