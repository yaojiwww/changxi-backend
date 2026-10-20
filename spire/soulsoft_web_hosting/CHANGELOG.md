# CHANGELOG — soulsoft.web.hosting

## v1.1.1 - 2026-04-01

### Added

- **`HttpResponse.onStarting(callback: () -> Unit)`** — 注册回调，在响应 headers 发送前执行
- **`HttpResponse.onCompleted(callback: () -> Unit)`** — 注册回调，在响应发送完毕后执行
- **`HttpResponse.body: IOStream`** — 流式写入接口，替代直接 write 方法
- **`HttpResponse.hasStarted: Bool`** — 标记响应体是否已开始发送
- **`HttpResponse.httpContext`** — 反向引用，供 body 流使用
- **`HttpResponse.registerForDispose(resource: Resource)`** — 扩展方法，自动在响应结束时释放资源

### Changed

- **`DefaultHttpResponse`** 重构：移除 `HttpResponseBuilder` 直接依赖，改为通过 `HttpResponseWriter` 流式写入
- **`HttpResponse.write`** 语义变更：首次调用时自动触发 OnStarting 并发送 headers，后续调用直接透传到底层流
- **`DefaultServer`** 错误处理改进：区分 `hasStarted` 状态——未开始时返回 500，已开始时仅记录日志
- **`StaticFileContent`**：200 响应（包括 HEAD）统一设置 `Content-Length`，确保大文件传输完整性
- **`HttpResponse.writeAsJson`**：直接写入 body 流，替代内存 Buffer 中转

### Fixed

- 大文件（>64KB）传输截断问题：修复 body 写入语义由"替换"改为"追加透传"
- Range 请求跨 64KB 边界计算错误

### Removed

- **`DefaultHttpResponse.flushResponseHeaders()`** — 替换为 `flushToBuilder()`
- **`HttpResponse.write(stream: InputStream)`** — 移除 InputStream 重载

---

## v1.1.0 - 2026-03-13

### Breaking Changes

- **`IServer.start(app, builder)`** 签名变更为 `start(app: RequestDelegate): Unit`，移除 `ServerBuilder` 参数；
  迁移方式：通过 `WebHostBuilder.configureServer { server => ... }` 回调注入服务器配置，不再在 `start()` 时传入
- **`DefaultHttpRequest.path`** 由只读属性（`prop`）改为可变属性（`mut prop`），
  与 `HttpRequest` 抽象基类的 `mut prop` 声明对齐；
  迁移方式：子类若覆写 `path`，须同步改为 `mut prop`
- **`DefaultHttpContext.finishResponse()`** 访问修饰符由 `public` 改为 `internal`，
  外部模块不再可见；迁移方式：此方法为框架内部实现细节，外部代码不应直接调用

### Changed

- **`RequestCookieCollection`** 底层存储由 `Form` 改为 `HashMap<String, String>`，
  Cookie 解析逻辑由 `parseCookies` 自行实现，正确支持含 `=` 的 Base64 值与 URL 编码

### Added

- **`WebHostBuilder.configureServer(configure: (ServerBuilder) -> Unit): This`** — 支持链式注册多个服务器配置回调
- **`HeaderDictionary`** — 新增 IHeaderDictionary 实现类，包装 `HttpHeaders` 提供完整接口支持
- **`QueryCollection`** — 新增 IQueryCollection 实现类，包装 `Form` 提供查询集合功能

### Changed

- **`FormCollection`** 访问修饰符由 `public` 改为 `protected`，仅限模块内部使用
- **`DefaultHttpRequest.headers`** 返回类型改为 `HeaderDictionary` 实例，替代直接使用 `HttpHeaders`
- **`DefaultHttpRequest.query`** 使用 `QueryCollection` 替代 `FormCollection` 包装查询参数
- **`DefaultHttpResponse.headers`** 使用 `HeaderDictionary` 替代 `HttpHeaders`，确保与 `IHeaderDictionary` 接口兼容

---

## v1.0.0

初始发布。
