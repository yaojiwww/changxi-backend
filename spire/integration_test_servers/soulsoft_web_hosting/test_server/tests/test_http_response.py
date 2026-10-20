"""
test_http_response.py — HTTP 响应基础行为验证

端点一览（均在 :5101）：
  GET /health              健康检查
  GET /text                纯文本响应
  GET /json                JSON 响应
  GET /status/201          自定义状态码 201
  GET /status/404          自定义状态码 404
  GET /content-len         显式 Content-Length=5
  GET /on-starting         OnStarting 注入 x-custom 头
  GET /on-completed/trigger  OnCompleted 回调计数
  GET /on-completed/count    返回计数值
  GET /error/on-starting-header 异常前注册 OnStarting，500 仍带回调 header
  GET /error/cookie-before-start 异常前写入 cookie，500 仍带 Set-Cookie
  GET /error/framing-headers  异常前预设 framing 头，500 兜底响应应清理并保留合法 transfer-encoding
  GET /error               抛异常 → 500
  GET /error-started       先写后抛 → 部分 body，不覆盖状态码
  GET /started/status-mutation 先写后改 status → 抛错但保留部分响应
  GET /started/header-mutation 先写后改 header → 抛错但保留部分响应
  GET /redirect            302 → /text
"""

import time
import pytest
from conftest import get, head, req


# ════════════════════════════════════════════════════════════════════════════
# 1. 基本文本响应
# ════════════════════════════════════════════════════════════════════════════

class TestBasicResponse:

    def test_status_200(self):
        r = get("/text")
        assert r.status_code == 200

    def test_body_content(self):
        r = get("/text")
        assert r.text == "hello world"

    def test_date_header_present(self):
        """stdx 框架自动注入 Date 头"""
        r = get("/text")
        assert "date" in r.headers

    def test_connection_header_present(self):
        r = get("/text")
        assert "connection" in r.headers


# ════════════════════════════════════════════════════════════════════════════
# 2. JSON 响应
# ════════════════════════════════════════════════════════════════════════════

class TestJsonResponse:

    def test_status_200(self):
        r = get("/json")
        assert r.status_code == 200

    def test_content_type_json(self):
        r = get("/json")
        assert "application/json" in r.headers["content-type"]

    def test_body_is_valid_json(self):
        r = get("/json")
        data = r.json()
        assert data["key"] == "value"


# ════════════════════════════════════════════════════════════════════════════
# 3. 自定义状态码
# ════════════════════════════════════════════════════════════════════════════

class TestStatusCodes:

    def test_201_created(self):
        r = get("/status/201")
        assert r.status_code == 201

    def test_201_no_body(self):
        """201 无 body 路由的响应体应为空"""
        r = get("/status/201")
        assert r.content == b""

    def test_404_status(self):
        r = get("/status/404")
        assert r.status_code == 404

    def test_404_body(self):
        r = get("/status/404")
        assert r.text == "not found"


# ════════════════════════════════════════════════════════════════════════════
# 4. Content-Length 精确传输（不追加 Transfer-Encoding: chunked）
# ════════════════════════════════════════════════════════════════════════════

class TestContentLength:

    def test_status_200(self):
        r = get("/content-len")
        assert r.status_code == 200

    def test_body_correct(self):
        r = get("/content-len")
        assert r.text == "hello"

    def test_content_length_header(self):
        r = get("/content-len")
        assert r.headers.get("content-length") == "5"

    def test_body_size_matches_content_length(self):
        r = get("/content-len")
        assert len(r.content) == int(r.headers["content-length"])

    def test_no_chunked_when_content_length_set(self):
        """显式 Content-Length 时，OnStarting 回调不应追加 transfer-encoding: chunked"""
        r = get("/content-len")
        te = r.headers.get("transfer-encoding", "")
        assert "chunked" not in te


# ════════════════════════════════════════════════════════════════════════════
# 5. OnStarting 回调
# ════════════════════════════════════════════════════════════════════════════

class TestOnStarting:

    def test_status_200(self):
        r = get("/on-starting")
        assert r.status_code == 200

    def test_custom_header_injected(self):
        """OnStarting 回调在 headers 发送前向响应注入 x-custom"""
        r = get("/on-starting")
        assert r.headers.get("x-custom") == "from-callback"

    def test_body_after_on_starting(self):
        """OnStarting 不影响响应体"""
        r = get("/on-starting")
        assert r.text == "ok"


# ════════════════════════════════════════════════════════════════════════════
# 6. OnCompleted 回调
# ════════════════════════════════════════════════════════════════════════════

class TestOnCompleted:

    def test_trigger_returns_200(self):
        r = get("/on-completed/trigger")
        assert r.status_code == 200

    def test_callback_increments_counter(self):
        """OnCompleted 回调触发后，计数器应递增"""
        before = int(get("/on-completed/count").text)
        get("/on-completed/trigger")        # 触发一次
        time.sleep(0.05)                    # 等待服务端异步执行
        after = int(get("/on-completed/count").text)
        assert after == before + 1

    def test_multiple_triggers_accumulate(self):
        """多次触发，计数器单调递增"""
        before = int(get("/on-completed/count").text)
        for _ in range(3):
            get("/on-completed/trigger")
        time.sleep(0.1)
        after = int(get("/on-completed/count").text)
        assert after >= before + 3


# ════════════════════════════════════════════════════════════════════════════
# 7. 异常处理
# ════════════════════════════════════════════════════════════════════════════

class TestErrorHandling:

    def test_unhandled_exception_returns_500(self):
        """pipeline 抛出异常且 hasStarted=false → 框架返回 500"""
        r = get("/error")
        assert r.status_code == 500

    def test_error_response_runs_on_starting_callbacks(self):
        """异常响应也应走 HttpResponse 流程，保留 OnStarting 注入的 header"""
        r = get("/error/on-starting-header")
        assert r.status_code == 500
        assert r.headers.get("x-error-callback") == "applied"

    def test_error_response_preserves_cookies_set_before_start(self):
        """异常前写入的 cookie 不应因宿主层 500 响应而丢失"""
        r = get("/error/cookie-before-start")
        assert r.status_code == 500
        set_cookie = r.headers.get("set-cookie", "")
        assert "failure=1" in set_cookie

    def test_error_response_clears_invalid_framing_headers(self):
        """异常兜底响应应清理冲突头，并保留合法的 transfer-encoding"""
        r = get("/error/framing-headers")
        assert r.status_code == 500
        assert "content-length" not in r.headers
        assert "chunked" in r.headers.get("transfer-encoding", "")
        assert "trailer" not in r.headers
        assert len(r.content) > 0

    def test_500_body_is_internal_server_error(self):
        """写入前抛异常时，框架应返回固定的 500 错误体"""
        r = get("/error")
        assert r.status_code == 500
        assert r.text == "Internal Server Error"

    def test_error_after_partial_write(self):
        """hasStarted=true 时抛异常 → 框架无法覆盖响应头，body 可能截断"""
        r = get("/error-started")
        # 响应已开始，状态码不会被改为 500
        assert r.status_code == 200
        # body 包含已写出的部分内容
        assert "partial" in r.text

    def test_server_still_functional_after_error(self):
        """出错请求不影响后续请求处理"""
        get("/error")
        r = get("/text")
        assert r.status_code == 200
        assert r.text == "hello world"


# ════════════════════════════════════════════════════════════════════════════
# 8. 响应开始后的非法修改
# ════════════════════════════════════════════════════════════════════════════

class TestStartedResponseMutation:

    def test_status_mutation_after_write_keeps_original_response(self):
        """响应已开始后修改状态码应失败，已写出的 body 仍然返回给客户端"""
        r = get("/started/status-mutation")
        assert r.status_code == 200
        assert r.text == "partial"

    def test_header_mutation_after_write_keeps_original_response(self):
        """响应已开始后修改 header 应失败，且不会把过晚的 header 发出去"""
        r = get("/started/header-mutation")
        assert r.status_code == 200
        assert r.text == "partial"
        assert "x-too-late" not in r.headers


# ════════════════════════════════════════════════════════════════════════════
# 9. 重定向
# ════════════════════════════════════════════════════════════════════════════

class TestRedirect:

    def test_302_location(self):
        """GET /redirect → 302，Location 指向 /text"""
        r = req("GET", "/redirect", allow_redirects=False)
        assert r.status_code == 302
        assert r.headers["location"].endswith("/text")

    def test_redirect_follows_to_200(self):
        """自动跟随重定向后得到 200 正文"""
        r = get("/redirect")
        assert r.status_code == 200
        assert r.text == "hello world"
