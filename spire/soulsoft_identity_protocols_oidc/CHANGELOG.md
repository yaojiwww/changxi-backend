# CHANGELOG — soulsoft.identity.protocols.oidc

## v1.1.0 - 2026-03-09

### Breaking Changes

- **`OpenIdConnectConfiguration.frontchannelLogoutSessionSupported`** 类型由 `String` 变更为 `Bool`，默认值由 `String.empty` 改为 `false`；迁移方式：将字符串比较替换为布尔比较

### Removed

- **`OpenIdConnectScopes.OpenIdProfile`** — 与 `OpenIdConnectScopes.Profile`（值同为 `"profile"`）重复，已删除；迁移方式：改用 `OpenIdConnectScopes.Profile`

### Fixed

- **`OpenIdConnectConfiguration.create(json: String)`** — 补全缺失的返回类型 `OpenIdConnectConfiguration`
- **`OpenIdConnectConfiguration.write(configuration: OpenIdConnectConfiguration)`** — 补全缺失的返回类型 `String`
- **`OpenIdConnectConfigurationRetriever`** — 修复局部变量 `json` 遮蔽外层同名参数的问题，重命名为 `jwksJson`
- **`DataModelExtensions`** — 修复循环变量误用名称 `pattern`，重命名为 `value` 以准确表达语义
- **`OpenIdConnectParameterNames`** — 所有 `static let` 常量改为 `static const`，确保编译期内联

---

## v1.0.0

初始发布。
