# soulsoft_web_staticfiles/test_server — StaticFiles 集成测试服务器

> 仓颉语言实现的 HTTP 测试服务器，验证 `soulsoft.web.staticfiles` 库的核心行为，
> 供 Python 客户端（`tests/`）发送真实 HTTP 请求进行断言验证。

---

## 目录结构

```
soulsoft_web_staticfiles/test_server/
├── src/
│   └── main.cj              # 入口：挂载三个场景段中间件，监听 :5000
├── tests/
│   ├── conftest.py           # pytest 公共配置（服务器就绪检查、请求封装）
│   ├── test_static_files.py  # /s/* 和 /u/* 场景（基础服务、条件请求、Range）
│   └── test_default_files.py # /d/* 场景（默认文件、301 trailing slash）
├── wwwroot/                  # 测试用静态文件根目录
│   ├── hello.txt             # "Hello, World!" (13 bytes, text/plain)
│   ├── page.html             # "<h1>Hello</h1>" (text/html)
│   ├── data.xyz              # "xyz data" (未知类型，用于 serveUnknownFileTypes 测试)
│   └── sub/
│       └── index.html        # "<h1>Sub Index</h1>" (默认文件测试)
└── cjpm.toml                 # 仓颉项目配置
```

---

## 快速开始

### 前置条件

| 工具 | 版本要求 |
|------|---------|
| 仓颉编译器 (`cjc`) | ≥ 1.1.0 |
| `cjpm` | 随编译器附带 |
| Python | ≥ 3.8 |
| pip | 任意版本 |

### 第一步：构建并启动测试服务器

```bash
cd integration_test_servers/soulsoft_web_staticfiles/test_server
cjpm run          # 默认监听 http://0.0.0.0:5000
```

> **注意**：服务器必须从 `integration_test_servers/soulsoft_web_staticfiles/test_server/` 目录启动，`wwwroot/` 路径相对于工作目录解析。

验证服务器就绪：

```bash
curl http://localhost:5000/health
# 输出: ok
```

### 第二步：安装 Python 依赖

```bash
pip install requests pytest
```

### 第三步：运行 Python 测试

```bash
cd integration_test_servers/soulsoft_web_staticfiles/test_server/tests
pytest -v
```

常用过滤：

```bash
# 只运行某一个文件
pytest -v test_static_files.py
pytest -v test_default_files.py

# 只运行某一个测试类
pytest -v test_static_files.py::TestRange
pytest -v test_static_files.py::TestETag

# 只运行某一个测试方法
pytest -v test_default_files.py::TestTrailingSlashRedirect::test_redirect_location_is_absolute_uri
```

如果服务器不在 `localhost:5000`：

```bash
TEST_SERVER_URL=http://192.168.1.10:5000 pytest -v
```

---

## 中间件段说明

`main.cj` 按顺序挂载三个场景段，每段对应不同的测试侧重点：

| URL 前缀 | 中间件 | 说明 |
|---------|--------|------|
| `/s/*` | `useStaticFiles` | 基础静态文件服务，仅提供已知 Content-Type |
| `/u/*` | `useStaticFiles`（`serveUnknownFileTypes=true`） | 未知类型文件也提供服务，回退到 `application/octet-stream` |
| `/d/*` | `useDefaultFiles` + `useStaticFiles` | 目录默认文件 + 301 trailing slash 重定向 |
| `/health` | 内联中间件 | 服务器就绪检查，返回 200 `ok` |
| `/**` | 最终回退 | 所有未命中请求返回 404 |

---

## 测试覆盖说明

### `test_static_files.py`

| 测试类 | 验证点 |
|--------|--------|
| `TestBasicServing` | GET 200、Content-Type、Content-Length、ETag/Last-Modified/Accept-Ranges 头、不存在文件→404 |
| `TestHeadRequest` | HEAD 200、响应头与 GET 一致、body 为空 |
| `TestUnknownContentType` | `/s` 拒绝未知类型→404；`/u` 放行→200 `application/octet-stream` |
| `TestETag` | If-None-Match 匹配→304、不匹配→200、`*`→304；If-Match 匹配→200、不匹配→412、`*`→200 |
| `TestLastModified` | If-Modified-Since 未来→304、过去→200；If-Unmodified-Since 未来→200、过去→412 |
| `TestRange` | 206 部分/后缀/开放端/全量；416 超出范围+Content-Range 头；HEAD+Range→200；If-Range ETag 匹配→206、不匹配→200 全量 |

### `test_default_files.py`

| 测试类 | 验证点 |
|--------|--------|
| `TestTrailingSlashRedirect` | 无尾斜杠→301；Location 为绝对 URI（`http://`）；Location 以 `/d/sub/` 结尾；查询字符串保留；已有尾斜杠不重定向 |
| `TestDefaultFileServing` | `/d/sub/`→200；提供 `sub/index.html` 内容；Content-Type text/html；普通文件不受影响；不存在目录→404 |

---

## 已知行为说明

| 场景 | 期望 | 说明 |
|------|------|------|
| GET 已知类型文件 | 200 + ETag + Last-Modified | 每次响应附带缓存相关头 |
| GET 未知类型（`/s`） | 404（回退） | `serveUnknownFileTypes` 默认 false |
| GET 未知类型（`/u`） | 200 + `application/octet-stream` | `defaultContentType` 未设置时的默认值 |
| Range 请求（GET） | 206 + Content-Range | 支持单范围，不支持多范围 |
| 无效 Range | 416 + `Content-Range: bytes */<size>` | RFC 7233 §4.4 |
| HEAD + Range | 200（忽略 Range） | Range 仅适用于 GET |
| GET 目录无尾斜杠 | 301 + 绝对 URI Location | RFC 7231 §7.1.2 推荐绝对 URI |
| GET 目录有尾斜杠 | 200（默认文件） | 路径重写到 `index.html` 后由 StaticFileMiddleware 提供 |
