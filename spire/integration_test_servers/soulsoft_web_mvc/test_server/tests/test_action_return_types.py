"""
test_action_return_types.py — Action 返回类型集成测试

覆盖 ControllerRequestDelegateFactory.dispatchResult 的全部派发路径：

  IActionResult 子类
  ──────────────────────────────────────────────────────────────────────────────
  ContentResult       content(str)           → 200 text/plain
                      content(str, type)     → 200 指定 Content-Type
                      content("")            → 204（空串特殊路径）

  StatusCodeResult    ok()                   → 200
                      noContent()            → 204
                      notFound()             → 404
                      unauthorized()         → 401
                      badRequest()           → 400
                      status(418)            → 418（自定义状态码）

  ObjectResult<T>     ok<T>(value)           → 200 JSON（JsonOutputFormatter 序列化）

  JsonResult<T>       json<T>(data)          → 200 JSON（writeAsJson 直接序列化）

  RedirectResult      redirect(url)          → 302 + Location 头

  FileContentResult   file(bytes, type)      → 200，无 Content-Disposition
                      file(bytes, type, name)→ 200 + Content-Disposition: attachment

  FileStreamResult    file(stream, type)     → 200，无 Content-Disposition
                      file(stream, type,name)→ 200 + Content-Disposition: attachment

  非 IActionResult 自动派发
  ──────────────────────────────────────────────────────────────────────────────
  String              返回原始字符串         → 200 text/plain（自动包装 ContentResult）
  ISerializable       返回 DTO 对象          → 200 JSON（自动包装 ObjectResult）
  Unit                无返回值               → 204

服务器：http://localhost:5010（通过 conftest.py 的 server_ready fixture 等待就绪）
"""

import pytest
from conftest import get, _session, URL


# ══════════════════════════════════════════════════════════════════════════════
# ContentResult
# ══════════════════════════════════════════════════════════════════════════════

class TestContentResult:
    """content() 辅助方法生成 ContentResult 的各场景。"""

    def test_content_text_returns_200(self):
        """content(str) → 200 OK。"""
        r = get("/api/return-type/content-text")
        assert r.status_code == 200

    def test_content_text_body(self):
        """content(str) → 响应体原样返回。"""
        r = get("/api/return-type/content-text")
        assert r.text == "hello"

    def test_content_text_content_type(self):
        """content(str) 默认 Content-Type 为 text/plain; charset=utf-8。"""
        r = get("/api/return-type/content-text")
        assert "text/plain" in r.headers.get("content-type", "")

    def test_content_typed_returns_200(self):
        """content(str, contentType) → 200 OK。"""
        r = get("/api/return-type/content-typed")
        assert r.status_code == 200

    def test_content_typed_content_type(self):
        """content(str, "application/json") → Content-Type 为 application/json。"""
        r = get("/api/return-type/content-typed")
        assert "application/json" in r.headers.get("content-type", "")

    def test_content_typed_body_is_valid_json(self):
        """content(str, "application/json") → 响应体为有效 JSON。"""
        r = get("/api/return-type/content-typed")
        assert r.json()["ok"] is True

    def test_content_empty_returns_204(self):
        """content("") → ContentResult 检测空串，写 204 NoContent。"""
        r = get("/api/return-type/content-empty")
        assert r.status_code == 204

    def test_content_empty_no_body(self):
        """content("") → 204 响应无响应体。"""
        r = get("/api/return-type/content-empty")
        assert r.text == ""


# ══════════════════════════════════════════════════════════════════════════════
# StatusCodeResult
# ══════════════════════════════════════════════════════════════════════════════

class TestStatusCodeResult:
    """status 系列辅助方法生成 StatusCodeResult 的各场景。"""

    def test_ok_returns_200(self):
        """ok() → 200 OK。"""
        r = get("/api/return-type/status-ok")
        assert r.status_code == 200

    def test_no_content_returns_204(self):
        """noContent() → 204 No Content。"""
        r = get("/api/return-type/status-no-content")
        assert r.status_code == 204

    def test_not_found_returns_404(self):
        """notFound() → 404 Not Found。"""
        r = get("/api/return-type/status-not-found")
        assert r.status_code == 404

    def test_unauthorized_returns_401(self):
        """unauthorized() → 401 Unauthorized。"""
        r = get("/api/return-type/status-unauthorized")
        assert r.status_code == 401

    def test_bad_request_returns_400(self):
        """badRequest() → 400 Bad Request。"""
        r = get("/api/return-type/status-bad-request")
        assert r.status_code == 400

    def test_custom_status_returns_418(self):
        """status(418) → 418 I'm a Teapot（自定义状态码透传）。"""
        r = get("/api/return-type/status-custom")
        assert r.status_code == 418

    def test_status_code_only_no_body(self):
        """StatusCodeResult 仅写状态码，不写响应体。"""
        r = get("/api/return-type/status-ok")
        assert r.text == ""


# ══════════════════════════════════════════════════════════════════════════════
# ObjectResult<T>
# ══════════════════════════════════════════════════════════════════════════════

class TestObjectResult:
    """ok<T>(value) 生成 ObjectResult，经 JsonOutputFormatter 序列化。"""

    def test_ok_value_returns_200(self):
        """ok<T>(value) → 200 OK。"""
        r = get("/api/return-type/ok-value")
        assert r.status_code == 200

    def test_ok_value_content_type_json(self):
        """ok<T>(value) → Content-Type 包含 application/json。"""
        r = get("/api/return-type/ok-value")
        assert "application/json" in r.headers.get("content-type", "")

    def test_ok_value_body_fields(self):
        """ok<T>(value) → 响应体包含 DTO 的全部字段。"""
        r = get("/api/return-type/ok-value")
        data = r.json()
        assert data["id"] == 1
        assert data["name"] == "ok-dto"


# ══════════════════════════════════════════════════════════════════════════════
# JsonResult<T>
# ══════════════════════════════════════════════════════════════════════════════

class TestJsonResult:
    """json<T>(data) 生成 JsonResult，经 response.writeAsJson 直接序列化。"""

    def test_json_value_returns_200(self):
        """json<T>(data) → 200 OK。"""
        r = get("/api/return-type/json-value")
        assert r.status_code == 200

    def test_json_value_content_type_json(self):
        """json<T>(data) → Content-Type 包含 application/json。"""
        r = get("/api/return-type/json-value")
        assert "application/json" in r.headers.get("content-type", "")

    def test_json_value_body_fields(self):
        """json<T>(data) → 响应体包含 DTO 的全部字段。"""
        r = get("/api/return-type/json-value")
        data = r.json()
        assert data["id"] == 2
        assert data["name"] == "json-dto"

    def test_json_and_ok_produce_equivalent_body(self):
        """json<T> 与 ok<T> 序列化结果结构一致（字段相同，值不同仅因 fixture 不同）。"""
        ok_r = get("/api/return-type/ok-value")
        json_r = get("/api/return-type/json-value")
        assert set(ok_r.json().keys()) == set(json_r.json().keys())


# ══════════════════════════════════════════════════════════════════════════════
# RedirectResult
# ══════════════════════════════════════════════════════════════════════════════

class TestRedirectResult:
    """redirect(url) 生成 RedirectResult，写 302 + Location 头。"""

    def test_redirect_returns_302(self):
        """redirect(url) → 302 Found。"""
        r = get("/api/return-type/redirect-to", allow_redirects=False)
        assert r.status_code == 302

    def test_redirect_location_header(self):
        """redirect(url) → Location 头携带目标路径。"""
        r = get("/api/return-type/redirect-to", allow_redirects=False)
        assert r.headers.get("location") == "/api/return-type/status-ok"

    def test_redirect_follows_to_target(self):
        """allow_redirects=True 时，跟随重定向后到达目标 200。"""
        r = get("/api/return-type/redirect-to", allow_redirects=True)
        assert r.status_code == 200


# ══════════════════════════════════════════════════════════════════════════════
# FileContentResult
# ══════════════════════════════════════════════════════════════════════════════

class TestFileContentResult:
    """file(bytes, contentType[, name]) 生成 FileContentResult。"""

    def test_file_bytes_returns_200(self):
        """file(bytes, contentType) → 200 OK。"""
        r = get("/api/return-type/file-bytes")
        assert r.status_code == 200

    def test_file_bytes_content_type(self):
        """file(bytes, contentType) → Content-Type 与参数一致。"""
        r = get("/api/return-type/file-bytes")
        assert "application/octet-stream" in r.headers.get("content-type", "")

    def test_file_bytes_body(self):
        """file(bytes, contentType) → 响应体为传入字节数组（"Hello"）。"""
        r = get("/api/return-type/file-bytes")
        assert r.content == b"Hello"

    def test_file_bytes_no_content_disposition(self):
        """file(bytes, contentType) 不传下载名 → 无 Content-Disposition 头。"""
        r = get("/api/return-type/file-bytes")
        assert "content-disposition" not in r.headers

    def test_file_bytes_named_returns_200(self):
        """file(bytes, contentType, name) → 200 OK。"""
        r = get("/api/return-type/file-bytes-named")
        assert r.status_code == 200

    def test_file_bytes_named_content_disposition(self):
        """file(bytes, contentType, name) → Content-Disposition: attachment 携带文件名。"""
        r = get("/api/return-type/file-bytes-named")
        cd = r.headers.get("content-disposition", "")
        assert "attachment" in cd
        assert "hello.bin" in cd

    def test_file_bytes_named_body(self):
        """file(bytes, contentType, name) → 响应体与无名版相同。"""
        r = get("/api/return-type/file-bytes-named")
        assert r.content == b"Hello"


# ══════════════════════════════════════════════════════════════════════════════
# FileStreamResult
# ══════════════════════════════════════════════════════════════════════════════

class TestFileStreamResult:
    """file(stream, contentType[, name]) 生成 FileStreamResult。"""

    def test_file_stream_returns_200(self):
        """file(stream, contentType) → 200 OK。"""
        r = get("/api/return-type/file-stream")
        assert r.status_code == 200

    def test_file_stream_content_type(self):
        """file(stream, contentType) → Content-Type 与参数一致。"""
        r = get("/api/return-type/file-stream")
        assert "text/plain" in r.headers.get("content-type", "")

    def test_file_stream_body(self):
        """file(stream, contentType) → 响应体为流中的全部字节。"""
        r = get("/api/return-type/file-stream")
        assert r.text == "stream-data"

    def test_file_stream_no_content_disposition(self):
        """file(stream, contentType) 不传下载名 → 无 Content-Disposition 头。"""
        r = get("/api/return-type/file-stream")
        assert "content-disposition" not in r.headers

    def test_file_stream_named_returns_200(self):
        """file(stream, contentType, name) → 200 OK。"""
        r = get("/api/return-type/file-stream-named")
        assert r.status_code == 200

    def test_file_stream_named_content_disposition(self):
        """file(stream, contentType, name) → Content-Disposition: attachment 携带文件名。"""
        r = get("/api/return-type/file-stream-named")
        cd = r.headers.get("content-disposition", "")
        assert "attachment" in cd
        assert "data.txt" in cd

    def test_file_stream_named_body(self):
        """file(stream, contentType, name) → 响应体与无名版相同。"""
        r = get("/api/return-type/file-stream-named")
        assert r.text == "stream-named"


# ══════════════════════════════════════════════════════════════════════════════
# 非 IActionResult 自动派发
# ══════════════════════════════════════════════════════════════════════════════

class TestAutoDispatch:
    """dispatchResult 对非 IActionResult 返回值的自动包装行为。"""

    def test_return_string_is_200(self):
        """返回 String → 自动包装为 ContentResult，200 OK。"""
        r = get("/api/return-type/return-string")
        assert r.status_code == 200

    def test_return_string_body(self):
        """返回 String → 响应体即返回值本身。"""
        r = get("/api/return-type/return-string")
        assert r.text == "plain-string"

    def test_return_string_content_type(self):
        """返回 String → ContentResult 默认 text/plain; charset=utf-8。"""
        r = get("/api/return-type/return-string")
        assert "text/plain" in r.headers.get("content-type", "")

    def test_return_serializable_is_200(self):
        """返回 ISerializable → 自动包装为 ObjectResult，200 OK。"""
        r = get("/api/return-type/return-serializable")
        assert r.status_code == 200

    def test_return_serializable_content_type(self):
        """返回 ISerializable → ObjectResult 经 JsonOutputFormatter，Content-Type 为 application/json。"""
        r = get("/api/return-type/return-serializable")
        assert "application/json" in r.headers.get("content-type", "")

    def test_return_serializable_body(self):
        """返回 ISerializable → 响应体包含 DTO 字段。"""
        r = get("/api/return-type/return-serializable")
        data = r.json()
        assert data["id"] == 3
        assert data["name"] == "serializable-dto"

    def test_return_unit_is_204(self):
        """返回 Unit → dispatchResult 写 204 NoContent。"""
        r = get("/api/return-type/return-unit")
        assert r.status_code == 204

    def test_return_unit_no_body(self):
        """返回 Unit → 204 响应无响应体。"""
        r = get("/api/return-type/return-unit")
        assert r.text == ""
