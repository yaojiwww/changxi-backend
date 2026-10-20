# CHANGELOG — soulsoft.web.authentication

## v1.1.0 - 2025-03-23

### Changed

- **`AuthenticationSchemeBuilder.displayName`** — 修正拼写错误（原 `displyName`）
- **`AuthenticationSchemeBuilder.handlerType`** — 修正拼写错误（原 `handleType`）
- **`AuthenticationSchemeBuilder.build()`** 返回类型从 `Unit` 改为 `AuthenticationScheme`，使其真正构建并返回方案实例

### Added

- **`IAuthenticationFeature`** — 新增接口，定义身份验证功能的原始路径访问能力
- **`AuthenticationFeature`** — 新增类，实现 IAuthenticationFeature 接口，用于在 HTTP 上下文中存储原始请求路径

### Fixed

- 修正 AuthenticationBuilder 中 build() 方法的返回类型，确保正确返回 AuthenticationScheme 实例
