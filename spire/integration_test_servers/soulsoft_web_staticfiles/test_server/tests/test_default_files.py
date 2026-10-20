"""
test_default_files.py — DefaultFilesMiddleware + StaticFileMiddleware 行为验证

服务器：5003（URL_DEFAULT）
  useDefaultFiles（无 requestPath） + useStaticFiles（无 requestPath）

wwwroot 文件树：
  hello.txt          直接文件
  sub/index.html     目录默认文件

默认文件请求三种情况：
  1. 路径以 / 结尾（如 /sub/）  → DefaultFiles 重写为 /sub/index.html → 200
  2. 路径无 / 结尾（如 /sub）   → DefaultFiles 触发 301 重定向到 /sub/
  3. 直接访问文件名（如 /sub/index.html） → 跳过 DefaultFiles，StaticFiles 直接提供 → 200
"""

from conftest import get, req, head, URL_DEFAULT, URL_SUB_ROOT


# ════════════════════════════════════════════════════════════════════════════
# 情况 1：路径以 / 结尾 → DefaultFiles 重写路径 → StaticFiles 提供默认文件
# ════════════════════════════════════════════════════════════════════════════

class TestTrailingSlash:
    """路径以 / 结尾：DefaultFilesMiddleware 将路径重写为默认文件，StaticFiles 提供"""

    def test_with_slash_200(self):
        r = get(URL_DEFAULT, "/sub/")
        assert r.status_code == 200

    def test_default_file_content(self):
        r = get(URL_DEFAULT, "/sub/")
        assert "Sub Index" in r.text

    def test_default_file_content_type(self):
        r = get(URL_DEFAULT, "/sub/")
        assert "text/html" in r.headers["content-type"]

    def test_default_file_has_etag(self):
        """默认文件响应也应包含 ETag（由 StaticFileMiddleware 设置）"""
        r = get(URL_DEFAULT, "/sub/")
        assert "etag" in r.headers

    def test_default_file_has_last_modified(self):
        r = get(URL_DEFAULT, "/sub/")
        assert "last-modified" in r.headers

    def test_default_file_has_accept_ranges(self):
        r = get(URL_DEFAULT, "/sub/")
        assert r.headers.get("accept-ranges") == "bytes"

    def test_nonexistent_directory_404(self):
        """不存在的目录 → DefaultFiles 无法重写 → StaticFiles 找不到文件 → 404"""
        r = get(URL_DEFAULT, "/nosuchdir/")
        assert r.status_code == 404

    def test_root_slash_no_default_file_404(self):
        """根路径 / 若 wwwroot 根目录无默认文件则回退 404"""
        r = get(URL_DEFAULT, "/")
        assert r.status_code == 404

    def test_head_with_slash_200(self):
        """HEAD 方法对有默认文件的目录路径返回 200"""
        r = head(URL_DEFAULT, "/sub/")
        assert r.status_code == 200


# ════════════════════════════════════════════════════════════════════════════
# 情况 2：路径无 / 结尾 → DefaultFilesMiddleware 触发 301 重定向
# ════════════════════════════════════════════════════════════════════════════

class TestNoTrailingSlash:
    """路径缺少末尾斜杠：DefaultFilesMiddleware 触发 301 跳转"""

    def test_no_slash_returns_301(self):
        r = req("GET", URL_DEFAULT, "/sub", allow_redirects=False)
        assert r.status_code == 301

    def test_redirect_location_ends_with_slash(self):
        r = req("GET", URL_DEFAULT, "/sub", allow_redirects=False)
        assert r.headers["location"].endswith("/sub/")

    def test_redirect_preserves_query_string(self):
        r = req("GET", URL_DEFAULT, "/sub?foo=bar", allow_redirects=False)
        assert r.status_code == 301
        assert "foo=bar" in r.headers["location"]

    def test_redirect_follows_to_200(self):
        """自动跟随 301 → 最终 200"""
        r = get(URL_DEFAULT, "/sub")  # allow_redirects=True (default)
        assert r.status_code == 200

    def test_head_no_slash_also_301(self):
        """HEAD 方法同样触发 301"""
        r = head(URL_DEFAULT, "/sub", allow_redirects=False)
        assert r.status_code == 301

    def test_nonexistent_dir_no_slash_passthrough(self):
        """不存在的目录路径（无斜杠）→ DefaultFiles 不介入 → StaticFiles 不处理 → 404"""
        r = req("GET", URL_DEFAULT, "/nosuchdir", allow_redirects=False)
        assert r.status_code == 404


# ════════════════════════════════════════════════════════════════════════════
# 情况 3：直接访问文件名 → DefaultFiles 不介入，StaticFiles 直接提供
# ════════════════════════════════════════════════════════════════════════════

class TestDirectFileName:
    """直接使用完整文件路径访问，DefaultFilesMiddleware 不介入"""

    def test_direct_subdir_index_200(self):
        """直接访问 /sub/index.html，不触发 DefaultFiles 重定向或重写"""
        r = get(URL_DEFAULT, "/sub/index.html")
        assert r.status_code == 200

    def test_direct_subdir_index_content(self):
        r = get(URL_DEFAULT, "/sub/index.html")
        assert "Sub Index" in r.text

    def test_direct_subdir_index_no_redirect(self):
        """直接文件路径不触发 301"""
        r = req("GET", URL_DEFAULT, "/sub/index.html", allow_redirects=False)
        assert r.status_code == 200

    def test_direct_subdir_css_200(self):
        """子目录中的 CSS 文件可直接访问"""
        r = get(URL_DEFAULT, "/sub/style.css")
        assert r.status_code == 200
        assert "text/css" in r.headers["content-type"]

    def test_direct_subdir_unknown_type_blocked(self):
        """serveUnknownFileTypes 默认 false → /sub/data.xyz 不提供 → 404"""
        r = get(URL_DEFAULT, "/sub/data.xyz")
        assert r.status_code == 404

    def test_direct_nested_file_200(self):
        """嵌套子目录中的文件可直接访问"""
        r = get(URL_DEFAULT, "/sub/nested/page.html")
        assert r.status_code == 200
        assert "Nested" in r.text

    def test_direct_root_file_200(self):
        """直接访问根目录下的普通文件"""
        r = get(URL_DEFAULT, "/hello.txt")
        assert r.status_code == 200
        assert r.text == "Hello, World!"

    def test_direct_root_file_content_type(self):
        r = get(URL_DEFAULT, "/hello.txt")
        assert "text/plain" in r.headers["content-type"]

    def test_direct_file_has_etag(self):
        r = get(URL_DEFAULT, "/sub/index.html")
        assert "etag" in r.headers

    def test_direct_file_has_last_modified(self):
        r = get(URL_DEFAULT, "/sub/index.html")
        assert "last-modified" in r.headers

    def test_missing_file_404(self):
        r = get(URL_DEFAULT, "/no-such.txt")
        assert r.status_code == 404


# ════════════════════════════════════════════════════════════════════════════
# 补充：根路径有默认文件（Server 5004，fileProvider=wwwroot/sub）
# ════════════════════════════════════════════════════════════════════════════

class TestRootWithDefaultFile:
    """
    Server 5004 — fileProvider=approot，根目录含 index.html
    approot 文件树：
      index.html        根默认文件   "<h1>App Home</h1>"
      about.html        普通页面     "<h1>About</h1>"
      assets/style.css  子目录文件   "body{margin:0}"
    """

    # ── 情况 1：/ 结尾 → 提供根默认文件 ─────────────────────────────────────

    def test_root_slash_200(self):
        """根路径 / 存在默认文件 → DefaultFiles 重写为 /index.html → 200"""
        r = get(URL_SUB_ROOT, "/")
        assert r.status_code == 200

    def test_root_slash_content(self):
        r = get(URL_SUB_ROOT, "/")
        assert "App Home" in r.text

    def test_root_slash_content_type(self):
        r = get(URL_SUB_ROOT, "/")
        assert "text/html" in r.headers["content-type"]

    def test_root_slash_has_etag(self):
        r = get(URL_SUB_ROOT, "/")
        assert "etag" in r.headers

    def test_root_slash_has_last_modified(self):
        r = get(URL_SUB_ROOT, "/")
        assert "last-modified" in r.headers

    def test_root_slash_has_accept_ranges(self):
        r = get(URL_SUB_ROOT, "/")
        assert r.headers.get("accept-ranges") == "bytes"

    # ── 情况 2：无 / 结尾的根路径 → 不适用（根路径本身就是 /，无需 301）──

    # ── 情况 3：直接访问文件名 ─────────────────────────────────────────────

    def test_direct_index_html_200(self):
        """直接访问 /index.html，不触发重写"""
        r = get(URL_SUB_ROOT, "/index.html")
        assert r.status_code == 200
        assert "App Home" in r.text

    def test_direct_about_html_200(self):
        r = get(URL_SUB_ROOT, "/about.html")
        assert r.status_code == 200
        assert "About" in r.text

    def test_subdir_file_200(self):
        """子目录文件可正常访问"""
        r = get(URL_SUB_ROOT, "/assets/style.css")
        assert r.status_code == 200
        assert "text/css" in r.headers["content-type"]

    def test_subdir_no_slash_404(self):
        """assets 目录下无默认文件 → DefaultFiles 无法重写 → 404
        （触发 301 重定向后跟随，最终 StaticFiles 找不到默认文件）"""
        r = get(URL_SUB_ROOT, "/assets/")
        assert r.status_code == 404

    def test_missing_file_404(self):
        r = get(URL_SUB_ROOT, "/no-such.txt")
        assert r.status_code == 404


# ════════════════════════════════════════════════════════════════════════════
# 补充：默认文件的条件请求（ETag）
# ════════════════════════════════════════════════════════════════════════════

class TestDefaultFileConditional:
    """确认 DefaultFiles 重写后，StaticFiles 的条件请求头仍正常工作"""

    PATH = "/sub/"

    def _etag(self):
        return get(URL_DEFAULT, self.PATH).headers["etag"]

    def test_if_none_match_304(self):
        etag = self._etag()
        r = get(URL_DEFAULT, self.PATH, headers={"If-None-Match": etag})
        assert r.status_code == 304

    def test_if_none_match_mismatch_200(self):
        r = get(URL_DEFAULT, self.PATH, headers={"If-None-Match": '"stale"'})
        assert r.status_code == 200

    def test_if_modified_since_future_ignored_200(self):
        """未来日期的 If-Modified-Since 被忽略（clock-skew guard）→ 200，对齐 ASP.NET Core 行为"""
        r = get(URL_DEFAULT, self.PATH,
                headers={"If-Modified-Since": "Thu, 01 Jan 2099 00:00:00 GMT"})
        assert r.status_code == 200
