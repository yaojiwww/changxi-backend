# CHANGELOG — soulsoft.web.cors

## v1.1.0 - 2026-03-19

### Breaking Changes

- **`ICorsService.applyResul()`** 已重命名为 **`applyResult()`**；迁移方式：将所有对 `applyResul` 的调用替换为 `applyResult`

### Added

- **`CorsPolicyBuilder.withExposedHeaders(headers: Array<String>): CorsPolicyBuilder`** — 新增暴露响应头配置方法
- **`CorsPolicyBuilder.setIsOriginAllowedToAllowWildcardSubdomains(): CorsPolicyBuilder`** — 新增通配符子域名匹配支持
- **`CorsService.evaluatePolicy(context: HttpContext, policyName: String): CorsResult`** — 新增按策略名称求值的重载方法

### Changed

- **`CorsPolicyBuilder`** 所有 `public func` 均已显式标注返回类型 `CorsPolicyBuilder`，与 C# fluent API 风格对齐
- **`CorsPolicyBuilder.withOrigins()`** 新增 origin 标准化处理（小写、去除默认端口 80/443）
- **`CorsMiddleware`** 修正内部字段名 `_policName` → `_policyName`（拼写修复）
- **`CorsMiddleware`** preflight 处理顺序优化：先执行 `next(context)` 再应用 CORS 响应头
- **`CorsService.applyResult()`** 修正 `Vary` 响应头写法（使用 `headers.vary = ["Origin"]`）
- **`IDisableCors`** 检测逻辑从 `f is IDisableCors` 改为 `f as IDisableCors`，语义更准确

### Fixed

- 修正单测目录结构，按 basic / boundary / error 分层组织

---

## v1.0.0

初始发布。
