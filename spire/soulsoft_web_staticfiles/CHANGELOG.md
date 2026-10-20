# CHANGELOG — soulsoft.web.staticfiles

## v1.1.0 - 2026-03-19

### Breaking Changes

- **`DefaultFileExtensions`** 接口已重命名为 **`DefaultFilesExtensions`**（文件同步重命名为 `DefaultFilesExtensions.cj`）；
  迁移方式：将所有 `DefaultFileExtensions` 引用替换为 `DefaultFilesExtensions`
- **`DefaultFileMiddleware`** 类已重命名为 **`DefaultFilesMiddleware`**（文件同步重命名为 `DefaultFilesMiddleware.cj`）；
  迁移方式：将所有 `DefaultFileMiddleware` 引用替换为 `DefaultFilesMiddleware`
- **`DefaultFilesOptions._defaultFileNames`** 访问修饰符由 `public let` 改为 `private let`；
  迁移方式：通过 `defaultFileNames` 属性（`prop`）访问，不再直接引用字段
- **`IFileInfo`、`IFileProvider`、`CompositeFileProvider`、`NotFoundFileInfo`、`PhysicalFileInfo`、`PhysicalFileProvider`**
  从 `soulsoft_web_staticfiles` 包迁移至新子包 `soulsoft_web_staticfiles.fileProviders`；
  迁移方式：在使用上述类型的文件中添加 `import soulsoft_web_staticfiles.fileProviders.*`
- **`DefaultFilesOptions.defaultFileNames`** 类型由只读 `prop`（返回 `List<String>`）改为
  `public var ArrayList<String>`；迁移方式：更新字段访问方式，并将 `List<T>` 引用改为 `ArrayList<T>`
- **`SharedOptionsBase`** 构造函数变更，现需传入 `SharedOptions` 共享实例；
  迁移方式：派生类须调用 `super(sharedOptions)` 并持有 `SharedOptions` 引用

### Changed

- **`DefaultFilesMiddleware`** 重构为路径重写语义（原实现直接提供文件内容）：
  现在仅将 `context.request.path` 重写为默认文件路径，由后续 `StaticFileMiddleware` 负责实际提供文件，
  与 ASP.NET Core `DefaultFilesMiddleware` 行为对齐
- **`DefaultFilesMiddleware`** 新增 301 重定向逻辑：当请求路径指向目录但不以 `/` 结尾时，
  重定向到规范 URL（尾部加 `/`），由 `SharedOptionsBase.redirectToAppendTrailingSlash` 控制
- **`DefaultFilesOptions`** 默认文件名顺序调整为 `["default.htm", "default.html", "index.htm", "index.html"]`，
  与 ASP.NET Core 默认顺序对齐（原顺序为 `index.html` 优先）
- **`FileServerExtensions.useFileServer(options:)`** 现在将顶层 `requestPath`/`fileProvider`
  同步到 `staticFileOptions` 和 `defaultFilesOptions`，对齐 ASP.NET Core `SharedOptions` 共享语义
- **`PhysicalFileProvider.existsSubDirectory(subPath:)`** 修复：空字符串和 `"/"` 均视为根目录存在；
  同时增加 `isDirectory()` 校验，避免将普通文件误判为子目录
- **`StaticFileContent`** 重构为完整的 HTTP 条件请求处理器，新增 ETag、Last-Modified、
  Range 请求、If-Match/If-None-Match/If-Modified-Since/If-Unmodified-Since 前置条件判断，
  以及 206 Partial Content 分段响应支持
- **`SharedOptionsBase`** 新增 `redirectToAppendTrailingSlash: Bool` 和 `fileProvider: ?IFileProvider`，
  底层实现由直接字段改为委托至 `SharedOptions` 实例的 `mut prop`；语义兼容，但构造方式已变更
- **`Helpers`** 新增 `getPathValueWithSlash(path: PathString): String` 工具函数

### Added

- **`SharedOptions`** — 新增公开共享选项类，集中管理 `requestPath`、`fileProvider`、
  `redirectToAppendTrailingSlash` 等跨中间件共享状态；`FileServerOptions` 在构造时创建唯一实例并传递给所有子选项
- **`FileServerOptions.enableDefaultFiles`** — 新增布尔字段（默认 `true`），控制是否启用默认文件中间件
- **`FileServerOptions.enableDirectoryBrowsing`** — 新增布尔字段（默认 `false`），控制是否启用目录浏览

### Removed

- 删除全部单元测试文件（`src/unittests/`）及测试辅助文件，测试迁移至 `test_server/` 集成测试服务器

---

## v1.0.0

初始发布。
