# soulsoft.extensions.healthchecks

**用于监控应用和服务健康状况的仓颉扩展库，支持并发执行、标签过滤与依赖注入集成。**
---

## 关于

`soulsoft.extensions.healthchecks` 提供了一套健康检查框架，核心接口为 `IHealthCheck` 和 `IHealthCheckService`。通过 `HealthChecksBuilder` 注册检查项，支持 Lambda 内联检查（`DelegateHealthCheck`）和自定义类型检查，执行时并发运行所有检查项并汇总为 `HealthReport`。库与 `soulsoft.extensions.injection` 深度集成，通过 `ServiceCollection.addHealthChecks()` 扩展方法一键接入依赖注入容器。

### 特性

| 特性 | 描述 |
|------|------|
| 🔍 **标准健康状态** | 三级状态枚举 `HealthStatus`：`Healthy`、`Degraded`、`Unhealthy`，聚合规则取最差状态 |
| ⚡ **并发执行** | `HealthCheckService` 使用 `spawn` 并发执行所有检查项，通过 `Future` 汇总结果 |
| 🏷️ **标签过滤** | 每个检查项支持 `tags: Array<String>`，`checkHealth(predicate)` 按谓词过滤执行子集 |
| ⏱️ **超时控制** | `HealthCheckRegistration` 携带 `timeout: Duration`，超时自动取消并返回 `Unhealthy` |
| 🔧 **Lambda 检查** | `addCheck(name, check: () -> HealthCheckResult)` 直接内联 Lambda，无需实现接口 |
| 🧩 **泛型类型注册** | `addCheck<T>(name)` 通过 `ActivatorUtilities` 从 DI 容器实例化自定义 `IHealthCheck` |
| 📦 **链式构建器** | `HealthChecksBuilder.addCheck(...)` 返回自身，支持流式链式调用 |
| 📊 **详细报告** | `HealthReport` 包含各项 `HealthReportEntry`（状态、耗时、描述、异常、标签、扩展数据） |

---

## 如何使用

### 基本注册与执行

```cj
import soulsoft_extensions_healthchecks.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_logging.*

// 构建 DI 容器
let services = ServiceCollection()
let loggerFactory = LoggerFactory.create { builder =>
    builder.setMinimumLevel(LogLevel.Off)
}
services.addSingleton<ILoggerFactory>({ _: IServiceProvider => loggerFactory })

// 注册健康检查并链式添加多个检查项
services.addHealthChecks()
    .addCheck("database", {=> HealthCheckResult.healthy(description: "连接正常") })
    .addCheck("cache", {=> HealthCheckResult.degraded(description: "响应较慢") })

// 执行检查并读取报告
let provider = services.build()
let svc = provider.getOrThrow<IHealthCheckService>()
let report = svc.checkHealth()

println(report.status)           // Degraded（聚合最差状态）

for ((name, entry) in report.entries) {
    println("${name}: ${entry.status}")
}
```

### 使用标签过滤

```cj
import soulsoft_extensions_healthchecks.*
import soulsoft_extensions_injection.*

// 注册带标签的检查项
services.addHealthChecks()
    .addCheck("db-primary", ["database", "critical"], {=> HealthCheckResult.healthy() })
    .addCheck("redis",       ["cache"],               {=> HealthCheckResult.unhealthy() })

let svc = provider.getOrThrow<IHealthCheckService>()

// 只运行带 database 标签的检查项
let report = svc.checkHealth { reg =>
    reg.tags.contains("database")
}
// report 中只包含 "db-primary"，结果为 Healthy
```

### 自定义实现类与超时控制

```cj
import soulsoft_extensions_healthchecks.*
import soulsoft_extensions_injection.*

// 自定义 IHealthCheck 实现
class DatabaseHealthCheck <: IHealthCheck {
    public func check(_: HealthCheckContext): HealthCheckResult {
        // 执行实际检查逻辑...
        HealthCheckResult.healthy(description: "数据库连接正常")
    }
}

// 泛型注册（从 DI 容器实例化），带超时与标签
services.addHealthChecks()
    .addCheck<DatabaseHealthCheck>("database", Duration.second * 5, ["db"])
```

### 构造检查结果

```cj
import soulsoft_extensions_healthchecks.*
import std.collection.*

// 健康
let ok = HealthCheckResult.healthy(description: "正常运行")

// 降级
let degraded = HealthCheckResult.degraded(description: "响应缓慢")

// 不健康（携带扩展数据）
let data = HashMap<String, Object>()
let failed = HealthCheckResult.unhealthy(description: "连接超时", data: data)
```

---

## API 参考

### IHealthCheck

| 方法 | 说明 |
|------|------|
| `check(context: HealthCheckContext): HealthCheckResult` | 执行健康检查，返回检查结果 |

### IHealthCheckService

| 方法 | 说明 |
|------|------|
| `checkHealth(): HealthReport` | 运行所有已注册的检查项，返回聚合报告 |
| `checkHealth(predicate: (HealthCheckRegistration) -> Bool): HealthReport` | 按谓词过滤后运行匹配的检查项 |

### HealthChecksBuilder

| 方法 | 说明 |
|------|------|
| `addCheck(registration: HealthCheckRegistration): HealthChecksBuilder` | 注册自定义 `HealthCheckRegistration` |
| `addCheck(name: String, check: () -> HealthCheckResult): HealthChecksBuilder` | 内联 Lambda 注册，无超时无标签 |
| `addCheck(name: String, tags: Array<String>, check: () -> HealthCheckResult): HealthChecksBuilder` | 内联 Lambda 注册，带标签 |
| `addCheck(name: String, timeout: Duration, tags: Array<String>, check: () -> HealthCheckResult): HealthChecksBuilder` | 内联 Lambda 注册，带超时与标签 |
| `addCheck<T>(name: String): HealthChecksBuilder` | 泛型注册，从 DI 容器实例化 `T` |
| `addCheck<T>(name: String, tags: Array<String>): HealthChecksBuilder` | 泛型注册，带标签 |
| `addCheck<T>(name: String, timeout: Duration, tags: Array<String>): HealthChecksBuilder` | 泛型注册，带超时与标签 |

### HealthCheckResult

| 方法 | 说明 |
|------|------|
| `static healthy(description!: ?String): HealthCheckResult` | 创建 `Healthy` 结果 |
| `static healthy(description!: ?String, data!: HashMap<String, Object>): HealthCheckResult` | 创建 `Healthy` 结果，携带扩展数据 |
| `static degraded(description!: ?String, exception!: ?Exception): HealthCheckResult` | 创建 `Degraded` 结果 |
| `static degraded(description!: ?String, exception!: ?Exception, data!: HashMap<String, Object>): HealthCheckResult` | 创建 `Degraded` 结果，携带扩展数据 |
| `static unhealthy(description!: ?String, exception!: ?Exception): HealthCheckResult` | 创建 `Unhealthy` 结果 |
| `static unhealthy(description!: ?String, exception!: ?Exception, data!: HashMap<String, Object>): HealthCheckResult` | 创建 `Unhealthy` 结果，携带扩展数据 |

| 属性 | 类型 | 说明 |
|------|------|------|
| `status` | `HealthStatus` | 检查状态 |
| `description` | `?String` | 可选描述信息 |
| `exception` | `?Exception` | 可选异常信息 |
| `data` | `ReadOnlyMap<String, Object>` | 扩展数据 |

### HealthReport

| 属性 | 类型 | 说明 |
|------|------|------|
| `status` | `HealthStatus` | 聚合状态（取所有检查项中最差的状态） |
| `totalDuration` | `Duration` | 所有检查项耗时之和 |
| `entries` | `ReadOnlyMap<String, HealthReportEntry>` | 各检查项结果，键为检查名称 |

### HealthReportEntry

| 属性 | 类型 | 说明 |
|------|------|------|
| `status` | `HealthStatus` | 该检查项的状态 |
| `duration` | `Duration` | 该检查项的执行耗时 |
| `description` | `?String` | 可选描述 |
| `exception` | `?Exception` | 可选异常 |
| `tags` | `Array<String>` | 检查项标签 |
| `data` | `ReadOnlyMap<String, Object>` | 扩展数据 |

### HealthStatus

| 枚举值 | 说明 |
|--------|------|
| `Healthy` | 正常 |
| `Degraded` | 降级（功能可用但性能下降） |
| `Unhealthy` | 不健康（功能不可用） |

---

## 相关包

- `soulsoft_extensions_options` - 选项模式支持，用于 `HealthCheckServiceOptions` 配置管理
- `soulsoft_extensions_logging` - 日志接口，`HealthCheckService` 用于记录超时与异常信息
- `soulsoft_extensions_injection` - 依赖注入容器，提供 `ServiceCollection`、`IServiceProvider` 等核心类型

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 HealthChecks 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
