# CHANGELOG — soulsoft.identity.tokens.jwt

## v1.1.0 - 2026-03-11

### Breaking Changes

- **`JwtContent.add(name: String, value: Any)`** 返回类型由隐式 `Unit` 变更为 `?Any`；
  迁移方式：若调用方忽略返回值则无需修改，若有类型约束需同步更新

### Changed

- **`JwtContent.add(name: String, value: Any): ?Any`** — 现在返回被替换/插入的旧值，
  与 `HashMap.add()` 语义对齐，支持调用方检测 key 冲突
- **`JwtContent.add(all:)`、`clear()`、`contains()`、`get()`、`isEmpty()`、
  `base64UrlEncode()`、`toClaims()`** — 补全显式返回类型注解（无语义变更）
- **`JwtPayload.addClaim()`、`addClaims()`** — 补全显式 `: Unit` 返回类型注解（无语义变更）
- **`JwtSecurityTokenHandler.createEncodedJwt()`** — 补全显式 `: String` 返回类型注解（无语义变更）

---

## v1.0.0

初始发布。
