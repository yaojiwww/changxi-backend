# soulsoft.web.hosting

**Web 应用托管核心库，提供 HTTP 上下文管理、请求处理管道与应用生命周期管理。**
---

## 关于

`soulsoft.web.hosting` 是 Spire Web 框架的核心托管层，以 `WebHost` 为入口，通过 `WebHostBuilder` 组装依赖注入容器、配置、日志和路由，最终启动内嵌 HTTP 服务器并驱动中间件管道。库实现了 `EndpointRouteBuilder`，支持路由端点注册与中间件链路编排；通过 `HostedServiceExecutor` 统一管理后台托管服务的启停；内置 `ApplicationLifetime` 负责信号感知和有序关闭。

### 特性

| 特性 | 描述 |
|------|------|
| 🚀 **一键创建主机** | `WebHost.createBuilder(args)` 自动读取环境变量、命令行参数与 `appsettings.json`，返回可配置的 `WebHostBuilder` |
| 🔗 **中间件管道** | `WebHost` 实现 `EndpointRouteBuilder`，通过 `use` 注册中间件，支持任意数量的中间件链路组合 |
| 🗺️ **路由端点注册** | 内置路由中间件，调用 `mapGet`/`mapPost` 等方法注册 REST 端点，有端点时自动挂载路由中间件 |
| ⚙️ **服务器配置** | `configureServer` 接受 `(ServerBuilder) -> Unit` 回调，可自定义端口、TLS 等底层 HTTP 服务器选项 |
| 🔄 **托管服务** | 注册实现 `IHostedService` 的后台服务后，`start()` 时统一启动，`stop()` 时统一停止 |
| 🌍 **Web 环境感知** | `IWebHostEnvironment` 提供 `webRootPath`、`contentRootPath`、`environmentName` 等运行时环境信息 |
| 🍪 **完整请求解析** | `HttpRequest` 提供 Cookie、查询字符串、表单（含 multipart）、请求头、路由值等全套解析能力 |
| 🔑 **HTTP 上下文访问** | `addHttpContextAccessor()` 将 `IHttpContextAccessor` 注入 DI，中间件之外的代码也可获取当前请求上下文 |

---

## 如何使用

### 创建并启动 Web 主机

```cj
import soulsoft_web_hosting.*

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)

    // 向 DI 容器注册服务
    builder.services.addHttpContextAccessor()

    let app = builder.build()

    // 添加中间件
    app.use { next => context =>
        println("请求路径: ${context.request.path}")
        next(context)
    }

    // 注册路由端点
    app.mapGet("/hello") { context =>
        context.response.write("Hello, World!")
    }

    // 阻塞运行，直到收到关闭信号
    app.run("http://0.0.0.0:5000")
    return 0
}
```

### 配置 HTTP 服务器

```cj
import soulsoft_web_hosting.*
import stdx.net.http.ServerBuilder

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)

    // 自定义底层服务器参数
    builder.configureServer { server: ServerBuilder =>
        server.addr("0.0.0.0")
        server.port(UInt16(8080))
    }

    let app = builder.build()
    app.run()
    return 0
}
```

### 访问请求数据

```cj
app.mapPost("/login") { context =>
    let req = context.request

    // 读取 Cookie
    if (let Some(token) <- req.cookies.get("session")) {
        println("会话 Token: ${token}")
    }

    // 读取查询字符串
    if (let Some(page) <- req.query.get("page")) {
        println("页码: ${page}")
    }

    // 读取 POST 表单
    let username = req.form.get("username") ?? ""
    let password = req.form.get("password") ?? ""

    context.response.statusCode = StatusCodes.Ok
    context.response.write("登录成功")
}
```

---

## API 参考

### WebHost

| 方法 / 属性 | 说明 |
|------------|------|
| `static func createBuilder(args: Array<String>): WebHostBuilder` | 创建构建器，自动配置环境、配置源与日志 |
| `func run(): Unit` | 启动主机并阻塞，收到关闭信号后释放资源 |
| `func run(urls: String): Unit` | 以指定地址启动主机并阻塞 |
| `func start(): Unit` | 启动托管服务和 HTTP 服务器，不阻塞调用线程 |
| `func waitForShutdown(): Unit` | 阻塞等待关闭信号，收到后执行有序关闭 |
| `func stop(): Unit` | 有序停止托管服务并通知生命周期结束 |
| `func close(): Unit` | 释放服务容器，幂等 |
| `func isClosed(): Bool` | 返回主机是否已关闭 |
| `prop logger: ILogger` | 主机内部日志记录器 |
| `prop lifetime: IHostApplicationLifetime` | 应用生命周期管理对象 |
| `prop environment: IHostEnvironment` | 运行时环境信息 |
| `prop configuration: IConfiguration` | 应用配置 |

### WebHostBuilder

| 方法 / 属性 | 说明 |
|------------|------|
| `func build(): WebHost` | 构建并返回 `WebHost` 实例 |
| `func configureServer(configure: (ServerBuilder) -> Unit): This` | 添加 HTTP 服务器配置回调，支持链式调用 |
| `prop services: ServiceCollection` | DI 服务注册容器 |
| `prop logging: LoggingBuilder` | 日志构建器 |
| `prop configuration: ConfigurationManager` | 配置管理器 |
| `prop environment: IWebHostEnvironment` | Web 主机环境 |
| `prop properties: HashMap<String, Any>` | 扩展属性字典 |

### IWebHostEnvironment

| 属性 | 类型 | 说明 |
|------|------|------|
| `webRootPath` | `String` | 静态文件根目录路径，默认 `wwwroot` |
| `contentRootPath` | `String` | 应用内容根目录路径 |
| `environmentName` | `String` | 运行环境名称（如 `Production`、`Development`） |
| `applicationName` | `String` | 应用名称 |

### IServer

| 方法 | 说明 |
|------|------|
| `func start(app: RequestDelegate): Unit` | 以给定请求委托启动 HTTP 服务器 |

---

## 相关包

- `soulsoft_web_http` - HTTP 抽象层，定义 `HttpContext`、`HttpRequest`、`HttpResponse` 等核心接口
- `soulsoft_web_routing` - 路由中间件与端点注册，提供 `EndpointRouteBuilder` 实现
- `soulsoft_identity_claims` - 身份声明模型，提供 `ClaimsPrincipal`
- `soulsoft_extensions_hosting` - 应用托管抽象，定义 `IHostedService`、`IHostEnvironment` 等
- `soulsoft_extensions_logging` - 日志抽象与 `LoggingBuilder`
- `soulsoft_extensions_options` - 选项模式支持
- `soulsoft_extensions_injection` - 依赖注入容器 `ServiceCollection`
- `soulsoft_extensions_configuration` - 配置抽象与 `ConfigurationManager`
- `soulsoft_extensions_logging_configuration` - 从配置文件读取日志级别

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 Hosting 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
