# CHANGELOG — soulsoft.web.routing

## v1.1.0 - 2026-03-18

### Breaking Changes

- **`IEndpointHttpContextExtensions`** 接口重命名为 **`EndpointHttpContextExtensions`**（去除 `I` 前缀）；
  迁移方式：将所有 `IEndpointHttpContextExtensions` 引用替换为 `EndpointHttpContextExtensions`

### Added

- **`ParameterPolicyFactory`** 支持 `regex(pattern)` 内联约束语法，例如 `{id:regex(^\\d+$)}`

### Changed
- DFA trie 文字节点改为统一小写存储（`addLiteralNode` 内部归一化），

### Removed

- **`cjpm.toml`** 移除对 `soulsoft_identity_claims` 的依赖

---

## v1.0.0

初始发布。
