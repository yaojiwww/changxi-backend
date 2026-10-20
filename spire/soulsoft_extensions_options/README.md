# soulsoft.extensions.options

**强类型配置对象管理库，支持命名选项、后置配置、内联验证与依赖注入集成。**
---

## 关于

soulsoft.extensions.options 实现了 Options 模式——将应用程序配置绑定到强类型对象，并通过依赖注入容器进行管理。核心接口 `IOptions<T>` 提供单例配置访问，`IOptionsMonitor<T>` 支持多组命名配置的按需创建与缓存。`OptionsBuilder<T>` 提供链式 API，可在一次调用链中完成配置注册、后置覆盖、验证规则与启动校验。

`OptionsCache<T>` 基于 `ConcurrentHashMap` 实现，`UnnamedOptionsManager<T>` 基于原子引用与延迟 `Mutex` 实现，两者均线程安全。

### 特性

| 特性 | 描述 |
|------|------|
| 🔑 **强类型配置** | `IOptions<T>` 将任意类型包装为配置对象，通过 DI 容器统一管理 |
| 🏷️ **命名选项** | `IOptionsMonitor<T>.get(name)` 支持多租户或多实例独立配置 |
| ⛓️ **链式 Builder** | `OptionsBuilder<T>` 支持 `configure → configureAfter → validate → validateOnStart` 链式调用 |
| 🔄 **后置配置** | `configureAfter` / `configureAfterAll` 在所有 `configure` 执行完毕后统一覆盖 |
| ✅ **内联验证** | `validate(fn)` / `validate(message, fn)` 在选项首次创建时自动触发，失败抛 `OptionsValidationException` |
| 🚀 **启动校验** | `validateOnStart()` 注册 `IStartupValidator`，应用启动时集中验证；多个失败聚合为 `AggregateException` |
| 🌐 **全局配置** | `configureAll` / `configureAfterAll` 作用于某类型的全部命名实例 |
| 🔒 **线程安全** | `OptionsCache<T>` 与 `UnnamedOptionsManager<T>` 基于原子操作与 `ConcurrentHashMap` 实现 |

---

## 如何使用

### 基本配置

```cj
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

// 定义配置类（需有无参构造函数）
class DatabaseOptions {
    public var host = "localhost"
    public var port = 5432
}

// 注册并配置选项
let services = ServiceCollection()
services.configure<DatabaseOptions>({
    options =>
    options.host = "prod-db.example.com"
    options.port = 3306
})

let provider = services.build()

// 获取配置值
let opts = provider.getOrThrow<IOptions<DatabaseOptions>>()
println(opts.value.host)  // prod-db.example.com
```

### 命名选项

命名选项允许同一类型拥有多份独立配置，通过 `IOptionsMonitor<T>` 按名称获取。

```cj
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

class TenantOptions {
    public var version = 0
}

let services = ServiceCollection()
services.configure<TenantOptions>({
    options => options.version = 1          // 默认
})
services.configure<TenantOptions>("tenant1", {
    options => options.version = 2
})
services.configure<TenantOptions>("tenant2", {
    options => options.version = 3
})

let provider = services.build()
let monitor = provider.getOrThrow<IOptionsMonitor<TenantOptions>>()

println(monitor.currentValue.version)    // 1（默认）
println(monitor.get("tenant1").version)  // 2
println(monitor.get("tenant2").version)  // 3
```

### OptionsBuilder 链式配置与验证

`OptionsBuilder<T>` 支持 configure → configureAfter → validate 一次性链式配置。

```cj
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

class ServiceOptions {
    public var version = 0
    public var name = ""
}

let services = ServiceCollection()
services.addOptions<ServiceOptions>()
    .configure {
        options => options.version = 1
    }
    .configure {
        options => options.name = "my-service"
    }
    .configureAfter {
        options => options.version = 2   // 后置覆盖，最终值为 2
    }
    .validate("版本必须大于1") {
        options => options.version > 1
    }

let provider = services.build()
let opts = provider.getOrThrow<IOptions<ServiceOptions>>()
println(opts.value.version) // 2
println(opts.value.name)    // my-service
```

### 启动时集中校验

`validateOnStart()` 将当前选项加入启动校验列表，调用 `IStartupValidator.validate()` 时集中检查所有选项。

```cj
import soulsoft_extensions_options.*
import soulsoft_extensions_options.exceptions.*
import soulsoft_extensions_injection.*

class AppOptions {
    public var version = 0
}

let services = ServiceCollection()
// 可为多个选项类型分别注册 validateOnStart
services.addOptions<AppOptions>()
    .configure { options => options.version = 5 }
    .validate { options => options.version > 0 }
    .validateOnStart()

let provider = services.build()
let validator = provider.getOrThrow<IStartupValidator>()
// 单个验证失败 → OptionsValidationException
// 多个验证失败 → AggregateException
validator.validate()
```

---

## API 参考

### IOptions\<TOptions\>

| 成员 | 说明 |
|------|------|
| `prop value: TOptions` | 获取配置对象，首次访问时懒加载并缓存 |

### IOptionsMonitor\<TOptions\>

| 成员 | 说明 |
|------|------|
| `prop currentValue: TOptions` | 获取默认命名（`""`）的配置对象，等价于 `get("")` |
| `func get(name: String): TOptions` | 按名称获取配置对象，结果由 `IOptionsMonitorCache<T>` 缓存 |

### IOptionsMonitorCache\<TOptions\>

| 方法 | 说明 |
|------|------|
| `func getOrAdd(name: String, createOptions: () -> TOptions): TOptions` | 获取缓存值，不存在则调用工厂函数创建并缓存 |

### IOptionsFactory\<TOptions\>

| 方法 | 说明 |
|------|------|
| `func create(name: String): TOptions` | 依次执行 configure → configureAfter → 验证，创建配置对象 |

### OptionsBuilder\<TOptions\>

所有方法均返回 `this`，支持链式调用。

| 方法 | 说明 |
|------|------|
| `func configure(configureOptions: (TOptions) -> Unit)` | 注册配置委托 |
| `func configure(configureOptions: (TOptions, IServiceProvider) -> Unit)` | 注册可访问 DI 容器的配置委托 |
| `func configureAfter(configureOptions: (TOptions) -> Unit)` | 注册后置配置委托，在所有 configure 之后执行 |
| `func configureAfter(configureOptions: (TOptions, IServiceProvider) -> Unit)` | 注册可访问 DI 容器的后置配置委托 |
| `func validate(validation: (TOptions) -> Bool)` | 注册验证委托，失败时使用默认消息 |
| `func validate(failureMessage: String, validation: (TOptions) -> Bool)` | 注册验证委托，失败时使用自定义消息 |
| `func validate(validation: (TOptions, IServiceProvider) -> Bool)` | 注册可访问 DI 容器的验证委托 |
| `func validate(failureMessage: String, validation: (TOptions, IServiceProvider) -> Bool)` | 注册带自定义消息且可访问 DI 容器的验证委托 |
| `func validateOnStart()` | 将当前选项加入启动校验列表，自动注册 `IStartupValidator` |

### Options

| 成员 | 说明 |
|------|------|
| `static let defaultName: String` | 默认选项名称（空字符串） |
| `static func create<TOptions>(options: TOptions): IOptions<TOptions>` | 将已有对象包装为 `IOptions<T>` |

### ValidateOptionsResult

| 成员 | 说明 |
|------|------|
| `static let success` | 验证通过的预定义结果 |
| `static let skip` | 跳过验证的预定义结果 |
| `static func fail(failureMessage: String)` | 创建单条失败结果 |
| `static func fail(failures: Collection<String>)` | 创建多条失败结果 |
| `prop succeeded: Bool` | 是否验证通过 |
| `prop skipped: Bool` | 是否被跳过 |
| `prop failed: Bool` | 是否验证失败 |
| `prop failureMessage: ?String` | 单条失败消息 |
| `prop failures: ?Collection<String>` | 所有失败消息集合 |

### OptionsValidationException

| 成员 | 说明 |
|------|------|
| `prop optionsName: String` | 触发验证失败的选项名称 |
| `prop optionsType: TypeInfo` | 选项类型信息 |
| `prop failureMessages: Array<String>` | 所有验证失败消息 |

### IStartupValidator

| 方法 | 说明 |
|------|------|
| `func validate(): Unit` | 执行所有已注册的启动验证；单个失败抛 `OptionsValidationException`，多个失败抛 `AggregateException` |

### AggregateException（`soulsoft_extensions_options.exceptions`）

| 成员 | 说明 |
|------|------|
| `prop exceptions: Collection<Exception>` | 所有聚合的子异常 |

### ServiceCollection 扩展

| 方法 | 说明 |
|------|------|
| `func addOptions<TOptions>(): OptionsBuilder<TOptions>` | 注册默认命名选项的基础服务，返回 Builder |
| `func addOptions<TOptions>(name: String): OptionsBuilder<TOptions>` | 注册指定名称选项的基础服务，返回 Builder |
| `func configure<TOptions>(configureOptions: (TOptions) -> Unit)` | 注册默认命名配置委托 |
| `func configure<TOptions>(name: String, configureOptions: (TOptions) -> Unit)` | 注册指定命名配置委托 |
| `func configureAfter<TOptions>(configureOptions: (TOptions) -> Unit)` | 注册默认命名后置配置委托 |
| `func configureAfter<TOptions>(name: String, configureOptions: (TOptions) -> Unit)` | 注册指定命名后置配置委托 |
| `func configureAll<TOptions>(configureOptions: (TOptions) -> Unit)` | 注册作用于该类型所有命名实例的配置委托 |
| `func configureAfterAll<TOptions>(configureOptions: (TOptions) -> Unit)` | 注册作用于该类型所有命名实例的后置配置委托 |
| `func addOptionsWithValidateOnStart<TOptions>(): OptionsBuilder<TOptions>` | 注册选项并自动开启启动校验 |

---

## 相关包

- `soulsoft_extensions_injection` - 依赖注入容器，提供 `ServiceCollection`、`IServiceProvider` 等核心抽象

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Options` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
