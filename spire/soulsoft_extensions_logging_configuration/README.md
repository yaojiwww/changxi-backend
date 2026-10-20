# soulsoft.extensions.logging.configuration

**通过 `IConfiguration` 管理日志过滤规则，日常场景以 `appsettings.json` 的 `logging` 节为主。**

---

## 关于

`soulsoft.extensions.logging.configuration` 是 `soulsoft_extensions_logging` 的配置桥接扩展，负责把 `IConfiguration` 里的日志规则接到 `LoggingBuilder`。它主要用于读取 `appsettings.json` 中 `logging` 节的全局过滤规则和 provider 专属规则。

---

## 特性

| 特性 | 描述 |
|------|------|
| 📋 **配置驱动日志规则** | 通过 `addConfiguration(IConfiguration)` 从配置系统加载过滤规则 |
| 🌐 **全局 `logLevel` 规则** | 支持 `logging:logLevel:*` |
| 🔧 **provider 专属规则** | 支持 `logging:console:logLevel:*`、`logging:<provider>:logLevel:*` |
| 🔡 **键名大小写无关** | `logLevel`、`LOGLEVEL`、`loglevel` 都可识别 |
| 🗂️ **多配置源叠加** | 可叠加 JSON、环境变量等配置源，后者覆盖前者 |
| 🎯 **`default` 全局规则** | `default` 自动映射为兜底规则 |
| ✅ **七种级别解析** | 支持 `Trace/Debug/Info/Warn/Error/Fatal/Off` |

---

## 如何使用

### 最常见用法：appsettings.json + logging 节

`appsettings.json`

```json
{
  "logging": {
    "logLevel": {
      "default": "Info",
      "soulsoft": "Warn"
    },
    "console": {
      "logLevel": {
        "default": "Debug",
        "soulsoft.Hosting.Lifetime": "Info"
      }
    }
  }
}
```

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_logging_configuration.*
import soulsoft_extensions_logging_console.*

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: true)
    .build()

let factory = LoggerFactory.create { builder =>
    builder.addConfiguration(configuration.getSection("logging"))
    builder.addConsole()
}

factory.close()
```

这也是最贴近实际项目的接法：

- 整个配置文件里有一个 `logging` 节
- 日志模块只消费 `logging` 这一段

### 配合 soulsoft.hosting

如果项目本身使用 `soulsoft.hosting`，通常不需要自己手动构建配置对象。  
`Host.createBuilder(args)` 一般会先加载 `appsettings.json`，再把 `logging` 节接到日志系统。

```cj
import soulsoft_extensions_hosting.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args).build()
    host.run()
    return 0
}
```

这个场景下，`soulsoft_extensions_logging_configuration` 的主要价值就是：  
让 `logging` 节里的规则能被日志系统识别。

### 全局规则和 provider 规则的关系

`appsettings.json`

```json
{
  "logging": {
    "logLevel": {
      "default": "Warn",
      "soulsoft": "Error"
    },
    "console": {
      "logLevel": {
        "default": "Debug"
      }
    }
  }
}
```

含义是：

- 全局默认规则：`Warn`
- 全局 `soulsoft.*`：`Error`
- 但 `console` provider 自己的默认规则：`Debug`

所以某些日志在全局看会被压掉，但在 `console` provider 上仍然可能输出。

### 手动构建 configuration 再注入 logging 节

```cj
import soulsoft_extensions_configuration.*
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

这里的关键点不是传整个配置根，而是传：

```cj
configuration.getSection("logging")
```

这样 README 和真实项目结构才一致。

## 配置键约定

在传入 `configuration.getSection("logging")` 的前提下，模块识别这些结构：

| 配置路径 | 语义 |
|---|---|
| `logLevel:default` | 全局兜底规则 |
| `logLevel:<分类名>` | 全局分类规则 |
| `console:logLevel:default` | `console` provider 专属兜底规则 |
| `console:logLevel:<分类名>` | `console` provider 专属分类规则 |
| `<provider>:logLevel:default` | 其他 provider 专属兜底规则 |
| `<provider>:logLevel:<分类名>` | 其他 provider 专属分类规则 |

支持的日志级别：

`Trace`、`Debug`、`Info`、`Warn`、`Error`、`Fatal`、`Off`

非法值会抛出 `UnsupportedException`。

---

## API 参考

### LoggingBuilderConfigurationExtension

| 方法 | 说明 |
|------|------|
| `addConfiguration(): LoggingBuilder` | 注册 provider 配置解析所需基础服务 |
| `addConfiguration(configuration: IConfiguration): LoggingBuilder` | 从指定配置节读取过滤规则并注册到构建器 |

## 相关包

- `soulsoft_extensions_logging` - 日志核心抽象，提供 `LoggingBuilder`、`ILoggerFactory`、`LogLevel`
- `soulsoft_extensions_configuration` - 配置系统，提供 `IConfiguration`、`ConfigurationManager`
- `soulsoft_extensions_logging_console` - 控制台日志 provider，可直接消费 `logging:console:*`

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Logging.Configuration` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
