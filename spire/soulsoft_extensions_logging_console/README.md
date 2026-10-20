# soulsoft.extensions.logging.console

**控制台日志扩展库，提供 `simple`、`json`、`systemd` 三种控制台格式化输出。**

---

## 关于

`soulsoft.extensions.logging.console` 是 `soulsoft_extensions_logging` 的控制台输出扩展，负责把日志写到标准输出或标准错误。它内置 `simple`、`json`、`systemd` 三种 formatter，并提供 `LoggingBuilder` 扩展和自定义 formatter 注册能力。

### 特性

| 特性 | 描述 |
|------|------|
| 🖥️ **三种内置 formatter** | 内置 `simple`、`json`、`systemd` 三种控制台输出格式 |
| 🔧 **LoggingBuilder 扩展注册** | 支持 `addConsole()`、`addSimpleConsole()`、`addJsonConsole()`、`addSystemdConsole()` |
| ⚙️ **配置驱动** | 支持从 `IConfiguration` 读取 `console:*` 和 `console:formatterOptions:*` 配置 |
| 🧩 **自定义 formatter** | 支持注册自定义 `ConsoleFormatter` 与自定义 options 类型 |
| 📦 **依赖注入集成** | 与 `soulsoft_extensions_injection`、`soulsoft_extensions_options`、`soulsoft_extensions_configuration` 协同工作 |
| 🔤 **小写 formatter 名称** | formatter 名称按 ASCII 小写归一化，`" JSON "` 会被识别为 `json` |
| 🧱 **派生 options 绑定** | 派生 formatter options 可通过 `IConfigurationBinding` 绑定继承链字段 |

---

## 如何使用

### 注册默认控制台日志

```cj
import soulsoft_extensions_injection.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_logging_console.*

let services = ServiceCollection()

services.addLogging { builder =>
    builder.addConsole()
}

let provider = services.build()
let factory = provider.getOrThrow<ILoggerFactory>()
let logger = factory.createLogger("App.Service")

logger.info("hello console")
```

如果只想快速调整默认控制台日志的常用选项，可以直接在注册时写：

```cj
services.addLogging { builder =>
    builder.addConsole { options =>
        options.formatterName = ConsoleFormatterNames.Simple
        options.logToStandardErrorThreshold = LogLevel.Error
        options.maxQueueLength = 2048
    }

    builder.addSimpleConsole { options =>
        options.singleLine = true
        options.timestampFormat = Some("HH:mm:ss ")
    }
}
```

### 通过 appsettings.json 配置控制台选项

日常项目里更常见的做法，是配合 `soulsoft.hosting` 使用 `appsettings.json`。  
`Host.createBuilder(args)` 会自动加载 `appsettings.json`，并把 `logging` 节交给日志系统。

```json
{
  "logging": {
    "console": {
      "formatterName": "simple",
      "maxQueueLength": 1024,
      "queueFullMode": "DropWrite",
      "logToStandardErrorThreshold": "Error",
      "logLevel": {
        "default": "Debug",
        "soulsoft.hosting": "Info"
      },
      "formatterOptions": {
        "singleLine": false,
        "colorBehavior": "Default",
        "timestampFormat": "yyyy-MM-dd HH:mm:ss ",
        "useUtcTimestamp": false
      }
    },
    "logLevel": {
      "default": "Info",
      "soulsoft.hosting": "Debug"
    }
  }
}
```

```cj
import soulsoft_extensions_hosting.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args).build()
    host.run()
    return 0
}
```

其中：

- `logging.logLevel` 是全局日志过滤规则
- `logging.console.logLevel` 是 `console` provider 专属过滤规则
- `logging.console.formatterOptions` 是当前 console formatter 的输出选项
- `jsonWriterOptions` 只在 `formatterName = "json"` 时有效

例如上面的配置表示：

- 默认全局级别是 `Info`
- `soulsoft.hosting` 全局放宽到 `Debug`
- 但 `console` provider 自己又把默认级别设成 `Debug`
- 同时把 `soulsoft.hosting` 在 `console` 输出里限制回 `Info`

如果你不是通过 `soulsoft.hosting` 接入，而是手动创建 `LoggingBuilder`，推荐这样写：

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_logging_configuration.*
import soulsoft_extensions_logging_console.*

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: true)
    .build()

let services = ServiceCollection()
services.addLogging { builder =>
    builder.addConfiguration(configuration.getSection("logging"))
    builder.addConsole()
}
```

### 直接配置内置 formatter

```cj
import soulsoft_extensions_logging.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_logging_console.*

let services = ServiceCollection()

services.addLogging { builder =>
    builder.addSimpleConsole { options =>
        options.singleLine = true
        options.colorBehavior = LoggerColorBehavior.Enabled
        options.timestampFormat = Some("HH:mm:ss")
    }
}
```

```cj
services.addLogging { builder =>
    builder.addJsonConsole { options =>
        options.useUtcTimestamp = true
        options.timestampFormat = Some("yyyy-MM-ddTHH:mm:ss")
    }
}
```

```cj
services.addLogging { builder =>
    builder.addSystemdConsole { options =>
        options.useUtcTimestamp = true
        options.timestampFormat = Some("yyyy-MM-dd HH:mm:ss ")
    }
}
```

### 注册自定义 formatter

```json
{
  "logging": {
    "console": {
      "formatterName": "custom",
      "formatterOptions": {
        "suffix": "done"
      }
    }
  }
}
```

```cj
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging_console.*
import soulsoft_extensions_logging_configuration.*

class CustomConsoleFormatterOptions <: ConsoleFormatterOptions & IConfigurationBinding {
    public var suffix: String = ""

    public override func configure(configuration: IConfiguration): Unit {
        configuration.bind(this)
    }

    public func bind(name: String, value: Any): Unit {
        if (name == "timestampFormat" && let value: ?String <- value) {
            timestampFormat = value
            return
        }
        if (name == "useUtcTimestamp" && let value: Bool <- value) {
            useUtcTimestamp = value
            return
        }
        if (name == "suffix" && let value: String <- value) {
            suffix = value
        }
    }
}

class CustomConsoleFormatter <: ConsoleFormatter {
    private let _options: IOptionsMonitor<CustomConsoleFormatterOptions>

    public init(options: IOptionsMonitor<CustomConsoleFormatterOptions>) {
        super("custom")
        _options = options
    }

    public override func format<TState>(logEntry: LogEntry<TState>): String where TState <: ToString {
        let suffix = _options.currentValue.suffix
        return "${logEntry.category}: ${logEntry.formatter(logEntry.state, logEntry.exception)} ${suffix}\n"
    }
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: true)
    .build()

let services = ServiceCollection()
services.addLogging { builder =>
    builder.addConfiguration(configuration.getSection("logging"))
    builder.addConsole()
    builder.addConsoleFormatter<CustomConsoleFormatter, CustomConsoleFormatterOptions>()
}
```

### formatter options 继承字段绑定

`ConsoleFormatterOptions` 本身提供 `timestampFormat` 和 `useUtcTimestamp`。  
如果派生 options 需要同时绑定自身字段和父类字段，建议实现 `IConfigurationBinding`，这样配置绑定可以沿继承链写回。

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging_console.*

class MyFormatterOptions <: ConsoleFormatterOptions & IConfigurationBinding {
    public var extraFlag: Bool = false

    public override func configure(configuration: IConfiguration): Unit {
        configuration.bind(this)
    }

    public func bind(name: String, value: Any): Unit {
        if (name == "timestampFormat" && let value: ?String <- value) {
            timestampFormat = value
            return
        }
        if (name == "useUtcTimestamp" && let value: Bool <- value) {
            useUtcTimestamp = value
            return
        }
        if (name == "extraFlag" && let value: Bool <- value) {
            extraFlag = value
        }
    }
}
```

---

## 配置约定

如果前面传入的是 `configuration.getSection("logging")`，那么控制台 provider 默认读取它下面的 `console` 子节：

```text
logging:
  console:
    formatterName: json
    queueFullMode: DropWrite
    maxQueueLength: 1024
    logToStandardErrorThreshold: Error
    formatterOptions:
      timestampFormat: yyyy-MM-ddTHH:mm:ss
      useUtcTimestamp: true
```

常用键如下：

| 键 | 说明 |
|---|---|
| `console:formatterName` | 当前启用的 formatter 名称，支持 `simple` / `json` / `systemd` / 自定义名称 |
| `console:queueFullMode` | 队列满时行为，支持 `Wait` / `DropWrite` |
| `console:maxQueueLength` | 队列最大长度 |
| `console:logToStandardErrorThreshold` | 写入标准错误流的最小日志级别 |
| `console:formatterOptions:*` | 当前 formatter 的选项节 |

---

## API 参考

### ConsoleLoggerExtensions

| 方法 | 说明 |
|---|---|
| `addConsole(): LoggingBuilder` | 注册默认控制台 provider 与内置 formatter |
| `addConsole(configure: (ConsoleLoggerOptions) -> Unit): LoggingBuilder` | 通过委托配置控制台公共选项 |
| `addSimpleConsole(): LoggingBuilder` | 使用 `simple` formatter |
| `addSimpleConsole(configure: (SimpleConsoleFormatterOptions) -> Unit): LoggingBuilder` | 配置 `simple` formatter 选项 |
| `addSimpleConsole(configuration: IConfiguration): LoggingBuilder` | 从配置源配置 `simple` formatter |
| `addJsonConsole(): LoggingBuilder` | 使用 `json` formatter |
| `addJsonConsole(configure: (JsonConsoleFormatterOptions) -> Unit): LoggingBuilder` | 配置 `json` formatter 选项 |
| `addJsonConsole(configuration: IConfiguration): LoggingBuilder` | 从配置源配置 `json` formatter |
| `addSystemdConsole(): LoggingBuilder` | 使用 `systemd` formatter |
| `addSystemdConsole(configure: (ConsoleFormatterOptions) -> Unit): LoggingBuilder` | 配置 `systemd` formatter 选项 |
| `addSystemdConsole(configuration: IConfiguration): LoggingBuilder` | 从配置源配置 `systemd` formatter |
| `addConsoleFormatter<TFormatter, TOptions>(): LoggingBuilder` | 注册自定义 formatter |
| `addConsoleFormatter<TFormatter, TOptions>(configure: (TOptions) -> Unit): LoggingBuilder` | 注册并配置自定义 formatter |
| `addConsoleFormatter<TFormatter, TOptions>(configuration: IConfiguration): LoggingBuilder` | 从配置源注册自定义 formatter |

### ConsoleLoggerOptions

| 属性 | 类型 | 说明 |
|---|---|---|
| `formatterName` | `?String` | 当前 formatter 名称 |
| `queueFullMode` | `ConsoleLoggerQueueFullMode` | 队列满时的处理方式 |
| `maxQueueLength` | `Int64` | 队列最大长度，默认 `2500` |
| `logToStandardErrorThreshold` | `LogLevel` | 写入标准错误流的最小日志级别 |

### ConsoleFormatterOptions

| 属性 | 类型 | 说明 |
|---|---|---|
| `timestampFormat` | `?String` | 时间戳格式 |
| `useUtcTimestamp` | `Bool` | 是否使用 UTC 时间 |

### SimpleConsoleFormatterOptions

| 属性 | 类型 | 说明 |
|---|---|---|
| `timestampFormat` | `?String` | 继承自 `ConsoleFormatterOptions` |
| `useUtcTimestamp` | `Bool` | 继承自 `ConsoleFormatterOptions` |
| `colorBehavior` | `LoggerColorBehavior` | 颜色策略 |
| `singleLine` | `Bool` | 是否单行输出 |

### JsonConsoleFormatterOptions

| 属性 | 类型 | 说明 |
|---|---|---|
| `timestampFormat` | `?String` | 继承自 `ConsoleFormatterOptions` |
| `useUtcTimestamp` | `Bool` | 继承自 `ConsoleFormatterOptions` |
| `jsonWriterOptions` | `JsonWriterOptions` | 控制 JSON 输出格式 |

### JsonWriterOptions

| 属性 | 类型 | 说明 |
|---|---|---|
| `depth` | `Int64` | 传递给 `toJsonString(depth, ...)` 的深度参数 |
| `indent` | `String` | `bracketInNewLine = true` 时使用的缩进字符串 |
| `bracketInNewLine` | `Bool` | `false` 时使用 `JsonObject.toString()` 输出单行；`true` 时走格式化输出 |

### ConsoleFormatterNames

| 常量 | 值 |
|---|---|
| `Simple` | `"simple"` |
| `Json` | `"json"` |
| `Systemd` | `"systemd"` |

### ConsoleLoggerQueueFullMode

| 枚举值 | 说明 |
|---|---|
| `Wait` | 队列满时等待 |
| `DropWrite` | 队列满时直接丢弃新日志 |

### LoggerColorBehavior

| 枚举值 | 说明 |
|---|---|
| `Default` | 使用默认颜色策略 |
| `Enabled` | 强制启用颜色 |
| `Disabled` | 强制禁用颜色 |

### ConsoleFormatter

| 成员 | 说明 |
|---|---|
| `prop name: String` | formatter 名称 |
| `format<TState>(logEntry: LogEntry<TState>): String` | 将日志条目格式化为字符串 |

---

## 相关包

- `soulsoft_extensions_logging` - 基础日志抽象与 `LoggingBuilder`
- `soulsoft_extensions_configuration` - 配置系统，提供 `IConfiguration`
- `soulsoft_extensions_options` - 选项模式与 `IOptionsMonitor<T>`
- `soulsoft_extensions_injection` - 依赖注入容器
- `soulsoft_extensions_logging_configuration` - 日志 provider 配置桥接
- `soulsoft_extensions_options_configuration` - 从配置源绑定 options

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Logging.Console` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
