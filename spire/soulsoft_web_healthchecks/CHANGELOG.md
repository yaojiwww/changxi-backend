# CHANGELOG — soulsoft.web.healthchecks

## v1.1.0 - 2026-03-19

### Breaking Changes

- **`IHealthCheckApplicationBuilderExtensions`** 接口重命名为 **`HealthCheckApplicationBuilderExtensions`**；
  迁移方式：将实现代码中所有 `IHealthCheckApplicationBuilderExtensions` 替换为 `HealthCheckApplicationBuilderExtensions`
- **`HealthCheckEndpointRouteBuilderExtensions.mapHealthChecks(pattern:options:)`** 返回类型由隐式 `Unit` 改为 `EndpointConventionBuilder`；
  迁移方式：如有忽略返回值的调用无需修改，如需链式调用约定（如 `.requireAuthorization()`）可直接使用返回值
- **`HealthCheckOptions.allowCachingResponses`** 默认值由 `true` 改为 `false`；
  迁移方式：若原先依赖默认开启缓存，需显式设置 `opts.allowCachingResponses = true`

### Changed

- **`HealthCheckApplicationBuilderExtensions.useHealthChecks(path:options:)`** 内部实现由内联 `use` 中间件改为通过 `mapWhen` 实现条件路由，
  消除 `/health` 与 `/health/detailed` 等路径重叠时的顺序敏感问题；路径精确匹配，允许尾部斜杠
- **`HealthCheckMiddleware.init(path:checkService:optins:)`** 参数名 `optins`（拼写错误）修正为 `options`；
  该构造函数为 `internal`，不影响公开 API
- **`HealthCheckOptions.responseWriter`** 默认实现新增 `contentType = "text/plain"` 设置，
  避免响应缺少 Content-Type 头
- `useHealthChecks` 和 `HealthCheckMiddleware` 中抛出的 `Exception` 替换为语义更精确的 `UnsupportedException`

### Added

- 测试服务器（`test_server`）重构为最小化场景，统一使用 `${SPIRE_PATH}` 环境变量替代硬编码相对路径，
  精简依赖项至核心 7 个，新增按名称/tag 过滤、`allowCachingResponses`、`mapHealthChecks` 端点路由等场景覆盖
- `test_server/cjpm.toml` 编译选项新增 `-lcangjie-dynamicLoader-opensslFFI`

### Removed

- **`test_server/src/controller/CustomHealthChecks.cj`** — 旧版复杂测试桩（`MysqlHealthCheck`/`PgsqlHealthCheck`/`TimeoutHealthCheck` 等）已移除，
  由 test_server `main.cj` 中的内联 Lambda 检查项替代
- **`test_server/src/controller/TestController.cj`** — 旧版 MVC 控制器测试已移除，控制器场景由专项测试覆盖
- **`tests_client/`** 目录（仓颉客户端测试套件）已整体移除，替换为外部 Python 测试脚本

---

## v1.0.0

初始发布。
