# CHANGELOG

各模块详细变更记录见各模块目录下的 `CHANGELOG.md`。

## v1.1.0 - 2026-03-13

- [soulsoft.web.hosting](./soulsoft_web_hosting/CHANGELOG.md) — 重构托管核心基础设施，简化 IServer 接口（Breaking Change）

## v1.1.0 - 2026-03-09

- [soulsoft.identity.protocols.oidc](./soulsoft_identity_protocols_oidc/CHANGELOG.md) — 修复类型错误与 API 规范化（Breaking Change）
- [soulsoft.identity.tokens](./soulsoft_identity_tokens/CHANGELOG.md) — 修正 `JsonWebKey.x5c` 为数组类型（Breaking Change）

## v1.0.0
   1. 支持依赖注入、选项、配置、日志、Http客户端
   2. 支持web主机、通用主机请求管道和路由
   3. 内置身份认证、授权、跨域，健康检测，mvc，openapi等中间件