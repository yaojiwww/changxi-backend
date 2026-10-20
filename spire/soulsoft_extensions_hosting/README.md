# soulsoft.extensions.hosting

**通用主机库，提供后台服务、控制台应用、Web 应用的统一启动入口与基础设施。**
---

## 关于

`soulsoft.extensions.hosting` 是 ASP.NET Core 通用主机（Generic Host）的仓颉移植版，提供依赖注入、日志、配置管理和应用程序生命周期管理的统一基础设施。通过 `Host.createBuilder()` 可快速搭建一个具备完整生命周期的应用主机，支持注册任意数量的后台服务（`IHostedService`）并行运行。

`ApplicationLifetime` 基于 `AtomicBool` 和 `Mutex` 实现，生命周期回调（`onStarted`/`onStopping`/`onStopped`）注册与触发均线程安全。在 Linux/macOS 平台上，`ConsoleLifetime` 通过 `std.runtime` 信号注册机制接收 SIGINT/SIGTERM，触发优雅关闭流程。

### 特性

| 特性 | 描述 |
|------|------|
| 🏗️ **通用主机** | `Host.createBuilder(args)` 一行创建主机，自动整合环境变量、JSON 配置、命令行参数 |
| ⚙️ **后台服务** | 继承 `BackgroundService`，实现 `run()` 即可注册为托管服务，支持 Future 取消 |
| 🔔 **生命周期事件** | `IHostApplicationLifetime` 提供 `onStarted`/`onStopping`/`onStopped` 回调注册 |
| 🛑 **优雅关闭** | Linux/macOS 下捕获 SIGINT/SIGTERM，通过 `stopApplication()` 触发完整关闭流程 |
| 🌍 **环境感知** | `IHostEnvironment` 提供 `isDevelopment()`/`isStaging()`/`isProduction()` 环境判断 |
| 💉 **DI 集成** | `addHostedService<T>()` 扩展方法将服务注册到 `ServiceCollection` |
| 📄 **配置分层** | 自动加载 `appsettings.json` + `appsettings.{env}.json`，支持环境变量覆盖 |

---

## 如何使用

### 创建主机并运行

```cj
import soulsoft_extensions_hosting.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args).build()
    host.run()
    return 0
}
```

### 注册后台服务

继承 `BackgroundService`，实现 `run()` 方法，通过 `configureServices` + `addHostedService<T>()` 注册：

```cj
import soulsoft_extensions_hosting.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_injection.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args)
        .configureServices { services =>
            // 注册后台服务
            services.addHostedService<TimerWorker>()
        }
        .build()
    host.run()
    return 0
}

// 实现后台服务
public class TimerWorker <: BackgroundService {
    private let _logger: ILogger

    public init(factory: ILoggerFactory) {
        _logger = factory.createLogger("TimerWorker")
    }

    public func run(): Unit {
        // 检查取消标志，实现可中断循环
        while (!Thread.currentThread.hasPendingCancellation) {
            _logger.info("Worker running...")
            sleep(Duration.second * 5)
        }
    }
}
```

### 使用生命周期事件

```cj
import soulsoft_extensions_hosting.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args).build()

    // 注册生命周期回调
    host.lifetime.onStarted {
        println("应用已启动")
    }
    host.lifetime.onStopping {
        println("应用正在停止，执行清理...")
    }
    host.lifetime.onStopped {
        println("应用已停止")
    }

    host.run()
    return 0
}
```

### 手动控制主机

```cj
import soulsoft_extensions_hosting.*

main(args: Array<String>): Int64 {
    let host = Host.createBuilder(args).build()

    // 手动启动，等待关闭信号，再停止
    host.start()
    // ... 执行其他逻辑 ...
    host.waitForShutdown()

    return 0
}
```

---

## API 参考

### IHost

| 方法 / 属性 | 说明 |
|-------------|------|
| `run(): Unit` | 启动主机并阻塞，直到关闭信号到达后完整执行关闭流程 |
| `start(): Unit` | 启动主机（非阻塞） |
| `stop(): Unit` | 停止主机，通知所有托管服务停止 |
| `waitForShutdown(): Unit` | 阻塞直到收到关闭信号，然后调用 `stop()` |
| `prop logger: ILogger` | 主机内置日志器 |
| `prop lifetime: IHostApplicationLifetime` | 应用程序生命周期对象 |
| `prop services: IServiceProvider` | 依赖注入服务容器 |
| `prop environment: IHostEnvironment` | 主机运行环境信息 |
| `prop configuration: IConfiguration` | 合并后的配置对象 |
| `static func createBuilder(args: Array<String>): HostBuilder` | 创建主机构建器，自动加载环境变量、JSON 配置和命令行参数 |

### IHostBuilder

| 属性 | 类型 | 说明 |
|------|------|------|
| `prop logging: LoggingBuilder` | `LoggingBuilder` | 日志构建器，可添加日志提供者 |
| `prop services: ServiceCollection` | `ServiceCollection` | 服务注册集合 |
| `prop environment: IHostEnvironment` | `IHostEnvironment` | 当前环境信息 |
| `prop configuration: ConfigurationManager` | `ConfigurationManager` | 配置管理器，可追加配置源 |
| `prop properties: HashMap<String, Any>` | `HashMap<String, Any>` | 自定义元数据 |
| `func build(): IHost` | — | 构建并返回主机实例 |
| `func configureServices(configure: (ServiceCollection) -> Unit): HostBuilder` | — | 注册服务，回调接收 `ServiceCollection`，支持链式调用 |

### IHostedService

| 方法 | 说明 |
|------|------|
| `start(): Unit` | 主机启动时调用，开始后台任务 |
| `stop(): Unit` | 主机停止时调用，结束后台任务 |

### BackgroundService

继承此抽象类可快速实现托管后台服务，子类只需实现 `run()` 方法。

| 方法 | 说明 |
|------|------|
| `func run(): Unit` | **抽象方法**，在独立 `Future` 中执行，子类必须实现 |
| `func start(): Unit` | 在新 Future 中启动 `run()`，由主机调用 |
| `func stop(): Unit` | 取消 Future，中断 `run()` 执行 |
| `func close(): Unit` | 幂等关闭，通过 `AtomicBool` 保证只取消一次 |
| `func isClosed(): Bool` | 返回服务是否已关闭 |

### IHostEnvironment

| 方法 / 属性 | 说明 |
|-------------|------|
| `prop environmentName: String` | 当前环境名称（如 `"Production"`） |
| `prop contentRootPath: String` | 应用内容根路径 |
| `prop applicationName: String` | 应用名称 |
| `func isEnvironment(name: String): Bool` | 判断当前环境是否为指定名称 |
| `func isDevelopment(): Bool` | 是否为开发环境 |
| `func isStaging(): Bool` | 是否为预发布环境 |
| `func isProduction(): Bool` | 是否为生产环境 |

### IHostApplicationLifetime

| 方法 | 说明 |
|------|------|
| `func onStarted(callback: () -> Unit): Unit` | 注册应用启动完成回调 |
| `func onStopping(callback: () -> Unit): Unit` | 注册应用开始停止回调 |
| `func onStopped(callback: () -> Unit): Unit` | 注册应用停止完成回调 |
| `func stopApplication(): Unit` | 触发应用关闭流程（幂等，线程安全） |

### Environments

| 常量 | 值 | 说明 |
|------|----|------|
| `Environments.Development` | `"Development"` | 开发环境 |
| `Environments.Staging` | `"Staging"` | 预发布环境 |
| `Environments.Production` | `"Production"` | 生产环境（默认） |

---

## 相关包

- `soulsoft_extensions_injection` - 依赖注入容器，提供 `ServiceCollection` 与 `IServiceProvider`
- `soulsoft_extensions_logging` - 日志抽象与实现，提供 `ILogger`/`ILoggerFactory`
- `soulsoft_extensions_configuration` - 配置管理，提供 `ConfigurationManager`/`IConfiguration`
- `soulsoft_extensions_options` - 强类型选项模式支持
- `soulsoft_extensions_logging_configuration` - 基于配置文件的日志级别控制

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Hosting` 模块，原始代码版权归 .NET Foundation 及贡献者所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
