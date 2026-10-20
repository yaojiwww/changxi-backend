# CHANGELOG — soulsoft.web.authentication.jwtbearer

## v1.1.0 - 2025-03-30

### Breaking Changes

- **`JwtBearerEvents.onForbidden`** 类型从 `?(ForbiddenContext) -> Unit` 变更为 `(ForbiddenContext) -> Unit`
  - 迁移方式：使用 `{ _ => }` 空函数替代 `None`，或使用具体函数替代
- **`JwtBearerEvents.onChallenge`** 类型从 `?(JwtBearerChallengeContext) -> Unit` 变更为 `(JwtBearerChallengeContext) -> Unit`
  - 迁移方式：使用 `{ _ => }` 空函数替代 `None`
- **`JwtBearerEvents.onTokenValidated`** 类型从 `?(TokenValidatedContext) -> ?String` 变更为 `(TokenValidatedContext) -> Unit`
  - 迁移方式：回调不再需要返回字符串，使用 `{ _ => }` 或具体处理函数
- **`JwtBearerEvents.onMessageReceived`** 类型从 `?(MessageReceivedContext) -> ?String` 变更为 `(MessageReceivedContext) -> Unit`
  - 迁移方式：回调不再需要返回字符串，使用 `{ _ => }` 或具体处理函数
- **`JwtBearerEvents.onAuthenticationFailed`** 类型从 `?(AuthenticationFailedContext) -> ?String` 变更为 `(AuthenticationFailedContext) -> Unit`
  - 迁移方式：回调不再需要返回字符串，使用 `{ _ => }` 或具体处理函数

### Changed

- **事件回调机制简化** — 移除 Optional 包装，改为使用默认空函数实现
  - 调用方不再需要处理 `None` 情况，简化代码逻辑
  - 回调函数调用方式从 `if (let Some(invoker) <- onXxx) { invoker(context) }` 简化为直接调用 `onXxx(context)`

---

## v1.0.0

初始发布。
