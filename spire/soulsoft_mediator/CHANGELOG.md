# CHANGELOG — soulsoft_mediator

## v1.0.0 - 2026-03-31

### Breaking Changes

- **包名** 由 `mediator` 重命名为 `soulsoft_mediator`；所有调用方需将 `import mediator.*` 更新为 `import soulsoft_mediator.*`
- **`ISender.send()`** 参数名由 `command` 重命名为 `request`；使用具名参数 `send(command: ...)` 的调用方需更新为 `send(request: ...)`

### Changed

- **`cjpm.toml`** 包名从 `mediator` 改为 `soulsoft_mediator`，与组织命名规范统一
- **`cjpm.toml`** `cjc-version` 升级至 `1.1.0`
- **`cjpm.toml`** 依赖版本约束从精确锁定 `1.0.20260327` 改为范围约束 `[1.0.20260327,)`，允许自动获取兼容的更新版本
- **`Mediator.cj`** 格式化 Lambda 体缩进，提升代码可读性

---

初始公开发布。
