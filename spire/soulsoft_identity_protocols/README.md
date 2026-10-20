# soulsoft.identity.protocols

**用于处理身份验证协议的抽象库，提供配置管理和文档检索的核心组件。**
---

## 关于

soulsoft.identity.protocols 是一个用于处理身份验证协议的抽象库，它提供了获取、解析和管理身份验证配置信息所需的核心组件和接口。该库定义了协议处理的基础类型，包括配置管理器（`IConfigurationManager`）、文档检索器（`IDocumentRetriever`）、配置检索器（`IConfigurationRetriever`）等抽象类和接口。作为基础库，它为具体的协议实现（如 OpenID Connect、OAuth 2.0）提供核心支撑，而不是直接用于应用程序中的协议处理。

### 特性

| 特性 | 描述 |
|------|------|
| 🔄 **自动刷新配置** | `ConfigurationManager` 支持定时自动刷新和手动触发刷新，默认 5 分钟刷新间隔、12 小时自动刷新间隔 |
| 🔒 **线程安全** | `ConfigurationManager` 基于 `Mutex`、`AtomicOptionReference`、`AtomicBool` 实现，支持并发访问 |
| 📄 **多种文档源** | 提供 `FileDocumentRetriever` 和 `HttpDocumentRetriever`，支持从本地文件或 HTTP(S) 端点获取配置文档 |
| 🛡️ **HTTPS 强制** | `HttpDocumentRetriever` 默认要求 HTTPS，可配置关闭（用于测试） |
| 🎯 **静态配置** | `StaticConfigurationManager` 提供不可变配置管理，适用于固定配置场景 |
| 🔌 **可扩展设计** | 通过 `IConfigurationRetriever<T>` 接口支持自定义配置解析逻辑 |

`ConfigurationManager` 基于 `Mutex` 和原子操作实现，线程安全。

## 如何使用

### 基本配置管理

```cj
import soulsoft_identity_protocols.*

// 创建文档检索器
let documentRetriever = FileDocumentRetriever()

// 创建配置检索器（需自定义实现 IConfigurationRetriever<T>）
let configRetriever = MyConfigRetriever()

// 创建配置管理器
let manager = ConfigurationManager<MyConfig>(
    "path/to/config.json",
    documentRetriever,
    configRetriever,
    refreshInterval: Duration.minute * 5,
    automaticRefreshInterval: Duration.hour * 12
)

// 获取配置（首次调用会加载，后续返回缓存）
let config = manager.getConfiguration()

// 手动触发刷新
manager.requestRefresh()
```

### 使用 HTTP 文档检索器

```cj
import soulsoft_identity_protocols.*
import soulsoft_net_http.*

// 默认要求 HTTPS
let httpRetriever = HttpDocumentRetriever()

// 或自定义 HttpClient 和 HTTPS 要求
let customClient = HttpClient()
let httpRetriever2 = HttpDocumentRetriever(customClient, requireHttps: false)

// 使用 HTTP 检索器创建配置管理器
let manager = ConfigurationManager<MyConfig>(
    "https://example.com/config.json",
    httpRetriever,
    configRetriever
)

let config = manager.getConfiguration()
```

### 静态配置管理

```cj
import soulsoft_identity_protocols.*

// 创建静态配置管理器（配置不可变）
let config = MyConfig("fixed-value")
let staticManager = StaticConfigurationManager<MyConfig>(config)

// 获取配置（始终返回同一实例）
let result = staticManager.getConfiguration()

// requestRefresh 是空操作
staticManager.requestRefresh()
```

## API 参考

### IConfigurationManager<T>

| 方法 | 说明 |
|------|------|
| `getConfiguration(): T` | 获取当前配置，首次调用会加载，后续返回缓存（可能触发后台刷新） |
| `requestRefresh(): Unit` | 手动触发配置刷新，受 `refreshInterval` 节流限制 |

### ConfigurationManager<T>

| 方法/属性 | 说明 |
|------|------|
| `init(address: String, documentRetriever: IDocumentRetriever, configurationRetriever: IConfigurationRetriever<T>, refreshInterval!: Duration = DefaultRefreshInterval, automaticRefreshInterval!: Duration = DefaultAutomaticRefreshInterval)` | 构造函数，`address` 不能为空 |
| `getConfiguration(): T` | 获取配置，首次加载阻塞，后续返回缓存并可能触发后台刷新 |
| `requestRefresh(): Unit` | 手动触发刷新，首次调用立即生效，后续受 `refreshInterval` 节流 |
| `DefaultRefreshInterval` | 静态常量，默认刷新间隔 5 分钟 |
| `DefaultAutomaticRefreshInterval` | 静态常量，默认自动刷新间隔 12 小时 |

### StaticConfigurationManager<T>

| 方法 | 说明 |
|------|------|
| `init(configuration: T)` | 构造函数，传入固定配置 |
| `getConfiguration(): T` | 返回构造时传入的配置 |
| `requestRefresh(): Unit` | 空操作，不改变配置 |

### IDocumentRetriever

| 方法 | 说明 |
|------|------|
| `getDocument(address: String): String` | 从指定地址获取文档内容 |

### FileDocumentRetriever

| 方法 | 说明 |
|------|------|
| `getDocument(address: String): String` | 从本地文件读取内容，文件不存在或读取失败抛出异常 |

### HttpDocumentRetriever

| 方法/属性 | 说明 |
|------|------|
| `init(requireHttps!: Bool = true)` | 构造函数，使用默认 HttpClient |
| `init(httpClient: HttpClient, requireHttps!: Bool = true)` | 构造函数，使用自定义 HttpClient |
| `getDocument(address: String): String` | 从 HTTP(S) 端点获取文档，非 HTTPS 地址在 `requireHttps=true` 时抛出异常 |
| `requireHttps: Bool` | 只读属性，是否要求 HTTPS |

### IConfigurationRetriever<T>

| 方法 | 说明 |
|------|------|
| `getConfiguration(address: String, documentRetriever: IDocumentRetriever): T` | 使用文档检索器获取并解析配置 |

## 相关包

- `soulsoft_net_http` - HTTP 客户端库，用于 `HttpDocumentRetriever` 实现

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [Microsoft.IdentityModel](https://github.com/AzureAD/azure-activedirectory-identitymodel-extensions-for-dotnet) 中的配置管理模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
