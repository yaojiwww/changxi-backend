# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-09

### Breaking Changes

- **泛型约束变更**：`IConfigurationManager<T>`、`ConfigurationManager<T>`、`StaticConfigurationManager<T>` 现在要求泛型参数 `T` 必须是引用类型（`where T <: Object`）；之前可以使用值类型，现在必须使用引用类型（类、接口等）

### Changed

- **`ConfigurationManager<T>`** 重构线程安全实现，从 Mutex + 普通变量改为基于原子操作（`AtomicOptionReference`、`AtomicBool`、`AtomicReference`），提升并发性能
- **`ConfigurationManager<T>.getConfiguration()`** 实现 stale-while-revalidate 策略，后台刷新时返回缓存配置，避免阻塞调用方
- **`ConfigurationManager<T>.requestRefresh()`** 新增节流机制，首次调用立即生效，后续受 `refreshInterval` 限制
- **`HttpDocumentRetriever.getDocument()`** 新增 HTTP 状态码检查（`ensureSuccessStatusCode()`），非成功状态码抛出异常
- **`HttpDocumentRetriever`** 异常类型从 `UnsupportedException` 改为 `IllegalArgumentException`（非 HTTPS 地址时）
- **`Utility.isHttps()`** 修正检查逻辑，从 `startsWith("https")` 改为 `startsWith("https://")`，避免误判

### Added

- **`ConfigurationManager<T>.init()`** 新增 address 空值检查，空字符串抛出 `IllegalArgumentException`
- **README.md** 完全重写为规范的库文档，新增特性表格、多场景使用示例、完整 API 参考表格
- **开源声明** 新增上游参考说明，标注参考了 Microsoft.IdentityModel 配置管理模块

### Fixed

- **`FileDocumentRetriever.getDocument()`** 修复资源泄漏，使用 try-with-resources 确保文件正确关闭
