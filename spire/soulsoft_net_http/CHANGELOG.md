# Changelog

## [1.1.0] - 2026-03-06

### Breaking Changes

- **`HttpResponseMessage.status`** 重命名为 **`statusCode`**，类型从 `UInt16` 变更为 `Int64`；
  迁移方式：将所有 `response.status` 调用替换为 `response.statusCode`

### Added

- **`HttpResponseMessage`** 实现 `Resource` 接口，新增 `close()` 与 `isClosed()` 方法，支持 `try-with-resource` 语法
- **`HttpClient()`** 静态工厂方法，创建跳过 TLS 证书验证的客户端（仅用于测试）
- **`HttpClient.create(configure:)`** 静态工厂方法，接受 `ClientBuilder` 回调以自定义 TLS/超时等配置
- **`HttpHeadersBase`** 新增头部集合基类，统一 `HttpRequestHeaders` 与 `HttpResponseHeaders` 的公共 API
- **`KnownHeaders`** 新增已知头部分类表，支持按 `HttpHeaderType` 区分请求/响应/内容头部
- **`HttpStatusCode`** 新增 HTTP 状态码枚举

### Removed

- **`HttpResponseMessage.status: UInt16`** — 已重命名为 `statusCode: Int64`

### Changed

- **`HttpResponseMessage.status: UInt16`** → **`statusCode: Int64`** — 返回 `Int64` 便于与整数字面量直接比较，避免隐式类型转换
- **`HttpRequestHeaders`** 改为继承 `HttpHeadersBase`，新增头部类型校验，拒绝向请求头集合写入 `Content` 或 `Response` 专属头部
- **`HttpResponseHeaders`** 改为继承 `HttpHeadersBase`，复用统一的头部操作实现

Upstream: https://github.com/dotnet/runtime/tree/main/src/libraries/System.Net.Http
