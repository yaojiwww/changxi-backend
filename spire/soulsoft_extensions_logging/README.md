# soulsoft.extensions.logging

**面向仓颉的日志记录扩展库，提供分级过滤、多提供者与扩展集成能力。**
---

## 关于

soulsoft.extensions.logging 是面向仓颉的日志记录扩展库，参考 .NET `Microsoft.Extensions.Logging` 设计，提供 `ILogger`/`ILoggerFactory`/`ILoggerProvider` 三层抽象。通过 `LoggingBuilder` 流式 API 配置全局最低级别、按分类/提供者名的过滤规则，并支持通过扩展提供者接入外部日志输出。

`LoggerFactory` 基于 `ConcurrentHashMap` 缓存日志器，线程安全。

### 特性

| 特性 | 描述 |
|------|------|
| 🎚️ **七级日志级别** | `Trace`/`Debug`/`Info`/`Warn`/`Error`/`Fatal`/`Off`，支持 `Comparable` 比较与 `ToString` 输出 |
| 🔧 **流畅构建器** | `LoggingBuilder` 链式 API 配置级别、过滤器、提供者，支持 DI 集成 |
| 🎯 **灵活过滤** | 支持按提供者名、分类名（含 `*` 通配符）和日志级别组合的精细过滤规则 |
| 🧩 **扩展接入** | 通过提供者扩展接入不同输出目标 |
| 🔒 **线程安全** | `LoggerFactory` 基于 `ConcurrentHashMap` 缓存日志器，并发安全 |
| 📦 **多提供者** | 支持同时注册多个 `ILoggerProvider`，同一条日志可分发至多个提供者 |

---

## 如何使用

### 基本使用

```cj
import soulsoft_extensions_logging.*

// 使用静态工厂方法快速创建
let factory = LoggerFactory.create { builder =>
    builder.setMinimumLevel(LogLevel.Info)
           .addProvider(/* custom provider */)
}

let logger = factory.createLogger("MyApp")
logger.info("应用启动")
logger.warn("内存使用率偏高")
logger.error("数据库连接失败")
logger.fatal("系统崩溃")

// 带异常的错误日志
try {
    // ...业务代码
} catch (ex: Exception) {
    logger.error(ex, "处理请求时发生异常")
}
```

### 设置最小级别与过滤规则

```cj
import soulsoft_extensions_logging.*

let factory = LoggerFactory.create { builder =>
    builder.setMinimumLevel(LogLevel.Warn)                  // 全局最低 Warn
           .addFilter { _, _, level => level >= LogLevel.Error } // 自定义函数过滤
           .addFilter("App.Data", LogLevel.Error)           // App.Data 分类只输出 Error
           .addProvider(/* custom provider */)
}

let loggerA = factory.createLogger("App.Data")
loggerA.warn("被规则过滤")   // App.Data 的规则要求 Error，此条不输出
loggerA.error("会输出")

let loggerB = factory.createLogger("App.Service")
loggerB.warn("会输出")       // 使用全局 minLevel Warn
```

### 通过 DI 注册

```cj
import soulsoft_extensions_logging.*
import soulsoft_extensions_injection.*

let services = ServiceCollection()
services.addLogging { builder =>
    builder.setMinimumLevel(LogLevel.Info)
           .addProvider(/* custom provider */)
}

let provider = services.build()
let factory = provider.getOrThrow<ILoggerFactory>()
let logger = factory.createLogger("MyApp.Service")
logger.info("通过 DI 创建日志器")
```

---

## API 参考

### ILogger

| 方法 | 说明 |
|------|------|
| `log<TState>(logLevel: LogLevel, eventId: EventId, state: TState, exception: ?Exception, formatter: (TState, ?Exception) -> String): Unit where TState <: ToString` | 核心日志方法，输出指定级别的状态对象 |
| `log(logLevel: LogLevel, message: ?String): Unit` | 按级别输出消息 |
| `log(logLevel: LogLevel, exception: ?Exception, message: ?String): Unit` | 按级别输出消息与异常 |
| `log(logLevel: LogLevel, eventId: EventId, exception: ?Exception, message: ?String): Unit` | 按级别、事件和异常输出消息 |
| `isEnabled(logLevel: LogLevel): Bool` | 检查指定级别是否启用；`Off` 始终返回 `false` |
| `trace/debug/info/warn/error/fatal` 各组快捷方法 | 每组均提供 `message`、`eventId + message`、`exception + message`、`eventId + exception + message` 四个重载 |

### ILoggerFactory

| 方法 | 说明 |
|------|------|
| `createLogger(categoryName: String): ILogger` | 按分类名创建或获取缓存的日志器 |
| `createLogger<T>(): ILogger` | 按类型全限定名创建日志器 |

### ILoggerProvider

| 成员 | 说明 |
|------|------|
| `alias: String` | 提供者别名，用于过滤规则匹配 |
| `createLogger(categoryName: String): ILogger` | 为指定分类创建日志器实例 |

### LogLevel

| 枚举值 | 说明 |
|------|------|
| `Trace` | 最低级别，记录最细粒度的跟踪信息 |
| `Debug` | 记录调试信息 |
| `Info` | 记录常规运行信息 |
| `Warn` | 记录警告信息 |
| `Error` | 记录错误信息 |
| `Fatal` | 记录严重错误信息 |
| `Off` | 禁用所有日志输出 |

枚举值从低到高依次为：`Trace`、`Debug`、`Info`、`Warn`、`Error`、`Fatal`、`Off`。实现 `Comparable` 与 `ToString`。

### LoggingBuilder

| 方法 | 说明 |
|------|------|
| `setMinimumLevel(level: LogLevel): LoggingBuilder` | 设置全局最低日志级别 |
| `addFilter(filter: (String, String, LogLevel) -> Bool)` | 添加按提供者、分类和级别过滤的规则 |
| `addFilter(categoryLevelFilter: (String, LogLevel) -> Bool)` | 添加按分类和级别过滤的规则 |
| `addFilter(levelFilter: (LogLevel) -> Bool)` | 添加仅按级别过滤的规则 |
| `addFilter(category: String, level: LogLevel)` | 按分类名添加最低级别规则 |
| `addFilter(category: String, levelFilter: (LogLevel) -> Bool)` | 按分类名添加级别过滤函数 |
| `addProvider(provider: ILoggerProvider)` | 注册日志提供者 |
| `clearProviders()` | 清除所有已注册的提供者 |

> 说明：`LoggingBuilder` 负责在配置回调中注册日志能力，可用于 `LoggerFactory.create(...)` 或 DI 中的 `ServiceCollection.addLogging(...)`。

### LoggingServiceCollectionExtensions

| 方法 | 说明 |
|------|------|
| `addLogging()` | 注册默认日志服务 |
| `addLogging(configure: (LoggingBuilder) -> Unit)` | 注册日志服务并执行自定义配置 |

### LoggerFilterRule

| 构造函数 | 说明 |
|------|------|
| `init(providerName: ?String, categoryName: ?String, logLevel: ?LogLevel, filter: ?(?String, ?String, LogLevel) -> Bool)` | 创建一条可按提供者、分类、最低级别和自定义过滤函数组合匹配的规则 |

| 属性 | 类型 | 说明 |
|------|------|------|
| `providerName` | `?String` | 匹配的提供者名称，`None` 表示匹配所有 |
| `categoryName` | `?String` | 匹配的分类名，支持 `*` 通配符，`None` 表示匹配所有 |
| `logLevel` | `?LogLevel` | 最低日志级别 |
| `filter` | `?(?String, ?String, LogLevel) -> Bool` | 自定义过滤函数 |

返回 `true` 表示允许该条日志记录，`false` 表示过滤掉。

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Logging` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
