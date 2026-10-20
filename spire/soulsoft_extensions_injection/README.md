# soulsoft.extensions.injection

**依赖注入容器，提供服务注册、服务解析、作用域管理、带键服务与构造函数注入。**
---

## 关于

`soulsoft.extensions.injection` 提供一个轻量 DI 容器。核心类型包括 `ServiceCollection`（注册服务）、`IServiceProvider`（解析服务）和 `IServiceScope`（管理作用域）。库支持 `Singleton`、`Scoped`、`Transient` 三种生命周期，支持带键服务注册与解析，支持通过 `@FromKeyedServices` 和 `@ServiceKey` 进行构造函数参数注入，也支持 `ActivatorUtilities` 创建未注册类型实例。

`ServiceCollection.build()` 通过 `Mutex` 保护构建过程，`ServiceProvider` 使用 `ConcurrentHashMap` 缓存解析入口，并用原子状态管理关闭流程。

### 特性

| 特性 | 描述 |
|------|------|
| 🔄 **三种生命周期** | 支持 `Singleton`、`Scoped`、`Transient` 三种注册与解析语义 |
| 🔑 **带键服务** | 同一服务类型可通过不同 `serviceKey` 注册多个实现，并按键解析 |
| 📦 **多实现解析** | `getAll<T>()` / `getAll<T>(serviceKey)` 返回同类型全部实现，顺序与注册顺序一致 |
| 🏗️ **工厂注册** | 支持 `(IServiceProvider) -> T` 工厂，工厂内部可继续解析依赖 |
| 🧩 **构造函数注入** | 自动按构造函数参数解析服务，支持 `ActivatorUtilities` 为未注册类型补齐依赖 |
| 🏷️ **参数注解注入** | `@FromKeyedServices` 支持显式 key 或继承 key，`@ServiceKey` 可把注册键注入为 `String` |
| ♻️ **资源释放** | `IServiceScope` 继承 `Resource`，作用域结束时自动释放该作用域内捕获的资源 |
| ✅ **构建期校验** | `validateOnBuild` 可在 `build()` 时验证服务图；多个失败会聚合为 `AggregateException` |
| 🔒 **作用域校验** | `validateScopes` 可阻止从根容器错误解析 `Scoped` 服务 |

---

## 如何使用

### 基本注册与解析

```cj
import soulsoft_extensions_injection.*

interface IRepository {}
class Repository <: IRepository {}
class AppService {
    public AppService(public let repo: IRepository) {}
}

let services = ServiceCollection()
services.addSingleton<IRepository, Repository>()
services.addTransient<AppService, AppService>()

let root = services.build()

let repo = root.getOrThrow<IRepository>()
let allRepos = root.getAll<IRepository>()
let app = root.getOrThrow<AppService>()
```

### 作用域与校验

```cj
import soulsoft_extensions_injection.*

interface IDbConnection <: Resource {}
class MySqlConnection <: IDbConnection {
    public init() {}
    public func close(): Unit {}
}

let services = ServiceCollection()
services.addScoped<IDbConnection, MySqlConnection>()

let root = services.build({ options =>
    options.validateScopes = true
    options.validateOnBuild = true
})

try (scope = root.createScope()) {
    let connection = scope.services.getOrThrow<IDbConnection>()
}
```

### 带键服务与 `ActivatorUtilities`

```cj
import soulsoft_extensions_injection.*

interface IDbConnection {}
class MySqlConnection <: IDbConnection {}
class MsSqlConnection <: IDbConnection {}

class Repository {
    public Repository(
        @FromKeyedServices["mysql"] public let connection: IDbConnection,
        @ServiceKey public let key: String
    ) {}
}

class ReportService {
    public ReportService(public let repo: Repository, public let name: String) {}
}

let services = ServiceCollection()
services.addKeyedSingleton<IDbConnection, MySqlConnection>("mysql")
services.addKeyedSingleton<IDbConnection, MsSqlConnection>("mssql")
services.addKeyedSingleton<Repository, Repository>("mysql")

let root = services.build()
let repo = root.getOrThrow<Repository>("mysql")
let report = ActivatorUtilities.createInstance<ReportService>(root, ["monthly"])
```

---

## API 参考

### IServiceProvider

| 方法 | 说明 |
|------|------|
| `get(serviceType: TypeInfo): ?Any` | 按运行时类型解析服务，未注册返回 `None` |
| `get(serviceKey: String, serviceType: TypeInfo): ?Any` | 按 key 和运行时类型解析服务 |
| `get<T>(): ?T` | 按泛型类型解析服务，未注册返回 `None` |
| `get<T>(serviceKey: String): ?T` | 按 key 解析带键服务 |
| `getOrThrow(serviceType: TypeInfo): Any` | 按运行时类型解析，失败抛 `UnsupportedException` |
| `getOrThrow<T>(): T` | 按泛型类型解析，失败抛 `UnsupportedException` |
| `getOrThrow<T>(serviceKey: String): T` | 按 key 解析，失败抛 `UnsupportedException` |
| `getAll<T>(): Collection<T>` | 返回该类型全部实现，无注册时返回空集合 |
| `getAll<T>(serviceKey: String): Collection<T>` | 返回指定 key 下该类型全部实现 |
| `createScope(): IServiceScope` | 创建新作用域 |

### IServiceScope

| 成员 | 说明 |
|------|------|
| `prop services: IServiceProvider` | 当前作用域对应的服务提供者 |

`IServiceScope` 继承 `Resource`，可直接用于 `try-with-resource`。

### ServiceCollection 与扩展

| 方法 | 说明 |
|------|------|
| `addSingleton<TService>(instance: TService)` | 注册单例实例 |
| `addSingleton<TService, TImplementation>()` | 注册类型映射单例 |
| `addSingleton<TService>(factory: (IServiceProvider) -> TService)` | 注册单例工厂 |
| `addScoped<TService, TImplementation>()` | 注册作用域服务 |
| `addScoped<TService>(factory: (IServiceProvider) -> TService)` | 注册作用域工厂 |
| `addTransient<TService, TImplementation>()` | 注册瞬时服务 |
| `addTransient<TService>(factory: (IServiceProvider) -> TService)` | 注册瞬时工厂 |
| `addKeyedSingleton / addKeyedScoped / addKeyedTransient` | 注册带键服务，对应三种生命周期均提供实例、类型映射、工厂与 `TypeInfo` 重载 |
| `tryAdd*` | 仅当相同 `serviceType + serviceKey` 未注册时添加 |
| `tryAddEnumerable(descriptor: ServiceDescriptor)` | 仅当相同 `serviceType + implementationType + serviceKey` 未注册时添加 |
| `build(): IServiceProvider` | 使用默认选项构建容器 |
| `build(configureOptions: (ServiceProviderOptions) -> Unit): IServiceProvider` | 构建时配置校验选项 |

### ServiceProviderOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `validateScopes` | `Bool` | `false` | 开启后阻止从根容器直接解析 `Scoped` 服务 |
| `validateOnBuild` | `Bool` | `false` | 开启后在构建阶段验证服务图；多个失败聚合为 `AggregateException` |

### ActivatorUtilities

| 方法 | 说明 |
|------|------|
| `createInstance<T>(provider: IServiceProvider, parameters: Array<Any>): T` | 创建未注册类型实例，用户参数优先匹配，剩余参数从容器解析 |
| `createInstance(provider: IServiceProvider, serviceType: TypeInfo, parameters: Array<Any>): Object` | 动态版本，不能创建抽象类型 |

### 其他公开类型

| 类型 | 说明 |
|------|------|
| `ServiceDescriptor` | 单条服务注册描述，公开暴露 `serviceType`、`serviceKey`、`implementationType`、`lifetime` 等属性 |
| `ServiceLifetime` | 生命周期枚举：`Singleton`、`Scoped`、`Transient` |
| `IServiceProviderIsService` | `isService(serviceType: TypeInfo): Bool`，检测某类型是否可解析 |
| `IServiceProviderIsKeyedService` | `isKeyedService(serviceKey: String, serviceType: TypeInfo): Bool`，检测某个 key 下的类型是否可解析 |
| `FromKeyedServices` | 参数注解；`@FromKeyedServices["mysql"]` 显式指定 key，`@FromKeyedServices` 继承父服务 key |
| `ServiceKey` | 参数注解；将当前服务注册 key 注入到 `String` 参数 |
| `AggregateException` | `validateOnBuild` 多个服务校验失败时抛出的聚合异常 |

---

## 相关包

当前模块 `cjpm.toml` 未声明额外依赖包。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的依赖注入模块，原始代码版权归 .NET Foundation and Contributors 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
