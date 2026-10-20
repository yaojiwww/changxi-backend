# soulsoft.extensions.http

**仿照 Microsoft.Extensions.Http 设计的 HTTP 客户端工厂库，提供命名客户端注册、处理器管道配置与生命周期管理。**
---

## 关于

`soulsoft.extensions.http` 是面向仓颉语言的 HTTP 客户端工厂库，核心接口为 `IHttpClientFactory` 和 `IHttpMessageHandlerFactory`，由单例 `DefaultHttpClientFactory` 实现。通过 `ServiceCollection` 扩展方法注册命名客户端，可灵活配置处理器管道、设置处理器生命周期，并通过 `IHttpMessageHandlerBuilderFilter` 以洋葱模型统一拦截处理器构建过程。

### 特性

| 特性 | 描述 |
|------|------|
| 🔗 **命名客户端** | 通过 `addHttpClient(name)` 注册独立配置的命名客户端，按需获取对应 `HttpClient` |
| ⏱️ **处理器生命周期管理** | 默认生命周期 2 分钟，可通过 `setHandlerLifetime` 自定义，`Duration.Zero` 表示永不过期 |
| 🔧 **处理器管道** | 通过 `addHttpMessageHandler` 添加 `DelegatingHandler` 中间件，构建链式处理管道 |
| 🧅 **过滤器链** | 实现 `IHttpMessageHandlerBuilderFilter` 以洋葱模型包装所有客户端的处理器构建过程 |
| 🎯 **类型化客户端** | 通过 `addTypedClient<TClient, TImpl>` 将命名客户端绑定到类型，支持 DI 自动注入 |
| 🌐 **全局默认配置** | `configureHttpClientDefaults` 对所有未命名客户端应用统一配置 |
| 🧩 **DI 集成** | 扩展 `ServiceCollection`，注册即用，与 `soulsoft_extensions_injection` 无缝协作 |
| 🔒 **线程安全** | `DefaultHttpClientFactory` 基于 `ConcurrentHashMap`、`Mutex` 和 `AtomicBool` 实现，线程安全。 |

---

## 如何使用

### 基本注册与创建

通过 `ServiceCollection` 注册命名客户端，构建 DI 容器后从 `IHttpClientFactory` 创建实例：

```cj
import soulsoft_extensions_http.*
import soulsoft_extensions_injection.*

let services = ServiceCollection()

// 注册命名客户端
let _ = services.addHttpClient("github-api")

let sp = services.build()
let factory = sp.getOrThrow<IHttpClientFactory>()

// 创建命名客户端
let client = factory.createClient("github-api")
// ... 使用 client 发送请求
client.close()

// 创建无名客户端（使用默认名称）
let defaultClient = factory.createClient()
defaultClient.close()
```

### 配置客户端与处理器管道

链式调用 `HttpClientBuilder` 配置 `HttpClient`、添加中间件并设置处理器生命周期：

```cj
import soulsoft_extensions_http.*
import soulsoft_extensions_injection.*
import soulsoft_net_http.*

let services = ServiceCollection()

let _ = services
    .addHttpClient("my-api", { client =>
        // 配置 HttpClient 实例
        client.baseAddress = "https://api.example.com"
    })
    .addHttpMessageHandler({ => MyLoggingHandler() })               // 添加中间件
    .configurePrimaryHttpMessageHandler({ => HttpClientHandler() }) // 替换主处理器
    .setHandlerLifetime(Duration.minute * 5)                        // 设置处理器生命周期

let sp = services.build()
let client = sp.getOrThrow<IHttpClientFactory>().createClient("my-api")
client.close()
```

### 处理器过滤器（洋葱模型）

实现 `IHttpMessageHandlerBuilderFilter` 统一拦截所有客户端的处理器构建过程：

```cj
import soulsoft_extensions_http.*
import soulsoft_extensions_injection.*

class TracingFilter <: IHttpMessageHandlerBuilderFilter {
    public func configure(
        next: (HttpMessageHandlerBuilder) -> Unit
    ): (HttpMessageHandlerBuilder) -> Unit {
        return { builder =>
            // 前置逻辑（如注入追踪 handler）
            next(builder)
        }
    }
}

let services = ServiceCollection()
// 注册过滤器（单例）
services.tryAddSingleton<IHttpMessageHandlerBuilderFilter> { _ => TracingFilter() }
let _ = services.addHttpClient("traced-api")

let client = services.build().getOrThrow<IHttpClientFactory>().createClient("traced-api")
client.close()
```

### 全局默认配置

`configureHttpClientDefaults` 对所有未命名客户端应用统一配置：

```cj
import soulsoft_extensions_http.*
import soulsoft_extensions_injection.*

let services = ServiceCollection()
let _ = services.configureHttpClientDefaults({ builder =>
    let _ = builder.setHandlerLifetime(Duration.minute * 10)
})

let client = services.build().getOrThrow<IHttpClientFactory>().createClient()
client.close()
```

---

## API 参考

### IHttpClientFactory

| 方法 | 说明 |
|------|------|
| `createClient(): HttpClient` | 使用默认名称创建 `HttpClient` |
| `createClient(name: String): HttpClient` | 创建指定名称的 `HttpClient`，应用对应的配置 action |

### IHttpMessageHandlerFactory

| 方法 | 说明 |
|------|------|
| `createHandler(name: String): HttpMessageHandler` | 创建指定名称的 `HttpMessageHandler`，同名调用复用缓存实例 |

### IHttpMessageHandlerBuilderFilter

| 方法 | 说明 |
|------|------|
| `configure(next: (HttpMessageHandlerBuilder) -> Unit): (HttpMessageHandlerBuilder) -> Unit` | 包装 `next`，返回新的构建函数，实现洋葱模型拦截 |

### HttpClientBuilder

| 方法 | 说明 |
|------|------|
| `setHandlerLifetime(handlerLifetime: Duration): HttpClientBuilder` | 设置处理器生命周期，最小 1 秒，`Duration.Zero` 永不过期 |
| `configureHttpClient(configureClient: (HttpClient) -> Unit): HttpClientBuilder` | 注册 `HttpClient` 配置回调 |
| `configureHttpClient(configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder` | 注册带 DI 容器的 `HttpClient` 配置回调 |
| `addHttpMessageHandler(configureHandler: () -> DelegatingHandler): HttpClientBuilder` | 向处理器管道追加中间件 |
| `addHttpMessageHandler(configureHandler: (IServiceProvider) -> DelegatingHandler): HttpClientBuilder` | 向处理器管道追加从 DI 容器解析的中间件 |
| `addHttpMessageHandler<THandler>(): HttpClientBuilder` | 从 DI 容器解析 `THandler` 并追加到管道 |
| `configurePrimaryHttpMessageHandler(configureHandler: () -> HttpMessageHandler): HttpClientBuilder` | 替换底层主处理器 |
| `configurePrimaryHttpMessageHandler(configureHandler: (IServiceProvider) -> HttpMessageHandler): HttpClientBuilder` | 从 DI 容器解析并替换主处理器 |
| `configurePrimaryHttpMessageHandler<THandler>(): HttpClientBuilder` | 从 DI 容器解析 `THandler` 作为主处理器 |
| `configureHttpMessageHandlerBuilder(configureBuilder: (HttpMessageHandlerBuilder) -> Unit): HttpClientBuilder` | 直接操作 `HttpMessageHandlerBuilder` |
| `addTypedClient<TClient, TImpl>(): HttpClientBuilder` | 将命名客户端绑定到类型化服务（DI 自动注入） |
| `addTypedClient<TClient, TImpl>(factory: (HttpClient) -> TImpl): HttpClientBuilder` | 使用工厂函数创建类型化服务 |
| `addTypedClient<TClient, TImpl>(factory: (HttpClient, IServiceProvider) -> TImpl): HttpClientBuilder` | 使用带 DI 的工厂函数创建类型化服务 |

### HttpClientFactoryOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `handlerLifetime` | `Duration` | `Duration.minute * 2` | 处理器生命周期；`Duration.Zero` 永不过期，最小 1 秒 |
| `httpClientActions` | `List<(HttpClient) -> Unit>` | 空列表 | `createClient` 时依次执行的配置回调 |
| `httpMessageHandlerBuilderActions` | `List<(HttpMessageHandlerBuilder) -> Unit>` | 空列表 | `createHandler` 时依次执行的构建回调 |

### HttpMessageHandlerBuilder

| 成员 | 类型 | 说明 |
|------|------|------|
| `name` | `?String` | 当前客户端名称 |
| `services` | `IServiceProvider` | 当前请求作用域的 DI 容器 |
| `primaryHandler` | `HttpMessageHandler` | 管道底层处理器（可替换） |
| `additionalHandlers` | `List<DelegatingHandler>` | 附加中间件列表（按注册顺序从外到内） |
| `build(): HttpMessageHandler` | — | 构建完整处理器管道并返回管道头节点 |

---

## 相关包

- `soulsoft_net_http` — 提供 `HttpClient`、`HttpMessageHandler`、`DelegatingHandler` 等核心 HTTP 类型
- `soulsoft_extensions_options` — 提供 `IOptionsMonitor<T>`、命名选项配置模型
- `soulsoft_extensions_injection` — 提供 `ServiceCollection`、`IServiceProvider`、DI 容器基础设施

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Http` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
