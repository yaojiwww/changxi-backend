# soulsoft.extensions.options.configuration

**将 `IConfiguration` 里的配置节绑定到强类型 Options，对日常 `appsettings.json` 场景做直接支持。**

---

## 关于

`soulsoft.extensions.options.configuration` 是 `soulsoft_extensions_options` 和 `soulsoft_extensions_configuration` 之间的桥接模块。  
它的核心用途不是“拼测试数据”，而是把已经加载好的 JSON、环境变量等配置源，绑定到强类型选项对象上。

这个模块当前主要有两类真实用法：

- `services.configure<TOptions>(configuration.getSection("section"))`
- `services.addOptions<TOptions>().bindConfiguration("section:path")`

前者适合你已经拿到某个 `IConfigurationSection` 的场景；后者更接近 C# `OptionsBuilder.BindConfiguration(...)` 的习惯。

---

## 特性

| 特性 | 描述 |
|------|------|
| JSON 配置绑定 | 适合 `appsettings.json` / `appsettings.{Environment}.json` 这类实际项目用法 |
| 基本类型自动转换 | 支持 `String`、`Bool`、整数、浮点数等常见类型 |
| Option 字段绑定 | 支持 `?String`、`?Bool`、`?Int64` 等可空字段 |
| 嵌套对象绑定 | 支持 `database:host` 这类层级配置递归绑定 |
| 数组绑定 | 支持 `ports:0`、`ports:1` 这类数组配置 |
| 命名选项 | 支持按名称注册多个同类型配置 |
| OptionsBuilder 集成 | 支持 `bind(...)` 和 `bindConfiguration(...)` |
| DI 集成 | 自动注册 options 基础设施，无需手动补齐 |

---

## 如何使用

### 最常见用法：从 appsettings.json 绑定

`appsettings.json`

```json
{
  "app": {
    "name": "demo",
    "port": 8080,
    "enabled": true
  }
}
```

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

class AppOptions {
    public var name: String = ""
    public var port: Int64 = 0
    public var enabled: Bool = false
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

let services = ServiceCollection()
services.configure<AppOptions>(configuration.getSection("app"))

let provider = services.build()
let options = provider.getOrThrow<IOptions<AppOptions>>().value
```

这也是这个模块最推荐的使用方式：

- 配置来源交给 `ConfigurationManager`
- 选项绑定交给 `services.configure<TOptions>(section)`

### 嵌套对象与数组

`appsettings.json`

```json
{
  "app": {
    "version": "2.0",
    "database": {
      "host": "prod-server",
      "port": 5432
    },
    "tags": ["web", "api"],
    "ports": [8080, 9090]
  }
}
```

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

class DbConfig {
    public var host: String = ""
    public var port: Int64 = 0
}

class AppConfig {
    public var version: String = ""
    public var database: DbConfig = DbConfig()
    public var tags: Array<String> = []
    public var ports: Array<Int64> = []
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

let services = ServiceCollection()
services.configure<AppConfig>(configuration.getSection("app"))
```

### Nullable 字段

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

class DbConfig {
    public var host: String = ""
    public var port: Int64 = 0
}

class AppOptions {
    public var name: String = ""
    public var optionalName: ?String = None
    public var optionalEnabled: ?Bool = None
    public var optionalPort: ?Int64 = None
    public var optionalDatabase: ?DbConfig = None
}
```

`appsettings.json`

```json
{
  "app": {
    "name": "myApp",
    "optionalName": "myApp-prod",
    "optionalEnabled": true,
    "optionalPort": 8080,
    "optionalDatabase": {
      "host": "db-server",
      "port": 5432
    }
  }
}
```

说明：

- 配置缺失时，`?T` 字段保持 `None`
- nullable 嵌套对象存在子节点时，会构造对象并写回 `Some(...)`

### 继承字段场景：实现 IConfigurationBinding

如果你的 options 类型存在继承链字段，需要显式实现 `IConfigurationBinding`。  
否则默认反射绑定只会处理当前类直接声明的 `var` 字段。

```cj
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_configuration.*
import soulsoft_extensions_options_configuration.*

open class BaseOptions {
    public var baseName: String = ""
}

open class MidOptions <: BaseOptions {
    public var midName: String = ""
}

class AppOptions <: MidOptions & IConfigurationBinding {
    public var port: Int64 = 0

    public func bind(name: String, value: Any): Unit {
        if (name == "baseName") {
            baseName = (value as String).getOrThrow()
            return
        }
        if (name == "midName") {
            midName = (value as String).getOrThrow()
            return
        }
        if (name == "port") {
            port = (value as Int64).getOrThrow()
        }
    }
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

let services = ServiceCollection()
services.configure<AppOptions>(configuration.getSection("app"))
```

`appsettings.json`

```json
{
  "app": {
    "baseName": "BaseApp",
    "midName": "MidApp",
    "port": 9100
  }
}
```

说明：

- `IConfigurationBinding` 定义在 `soulsoft_extensions_configuration` 模块中
- 所以上面的示例需要 `import soulsoft_extensions_configuration.*`
- 只有继承字段或特殊写回逻辑场景才需要实现它
- 普通扁平 options、普通嵌套对象、数组、nullable 字段，不需要额外实现这个接口

### OptionsBuilder.bindConfiguration

如果你希望像 C# 那样，从 DI 中直接拿 `IConfiguration` 再绑定 section，可以用 `bindConfiguration(...)`。

`appsettings.json`

```json
{
  "features": {
    "tenantA": {
      "enabled": true,
      "name": "alpha"
    }
  }
}
```

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

class FeatureOptions {
    public var enabled: Bool = false
    public var name: String = ""
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

let services = ServiceCollection()
services.addSingleton<IConfiguration>(configuration)
services.addOptions<FeatureOptions>()
    .bindConfiguration("features:tenantA")

let provider = services.build()
let options = provider.getOrThrow<IOptions<FeatureOptions>>().value
```

这个写法适合：

- 你已经把 `IConfiguration` 注册进 DI
- 你希望 options 的绑定路径写在 `OptionsBuilder` 链上

### OptionsBuilder.bind

如果你已经手里拿到了 section，也可以直接：

```cj
let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

services.addOptions<AppOptions>()
    .bind(configuration.getSection("app"))
```

### 自定义枚举字段

当前支持无参自定义枚举构造器的字符串绑定：

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

enum DeployMode {
    | Development
    | Production
    | Custom(Int64)
}

class AppOptions {
    public var mode: DeployMode = Development
    public var optionalMode: ?DeployMode = None
}
```

`appsettings.json`

```json
{
  "app": {
    "mode": "Production",
    "optionalMode": "DeployMode.Development"
  }
}
```

说明：

- 当前仅支持无参枚举构造器
- 配置值支持 `Constructor` 和 `Enum.Constructor` 两种写法
- 带参构造器当前不会通过字符串自动绑定

### 命名选项

`appsettings.json`

```json
{
  "tenants": {
    "tenantA": {
      "value": "A"
    },
    "tenantB": {
      "value": "B"
    }
  }
}
```

```cj
import soulsoft_extensions_configuration.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

class TenantOptions {
    public var value: String = ""
}

let configuration = ConfigurationManager()
    .addJsonFile("./appsettings.json", optional: false)
    .build()

let services = ServiceCollection()
services.configure<TenantOptions>("tenantA", configuration.getSection("tenants:tenantA"))
services.configure<TenantOptions>("tenantB", configuration.getSection("tenants:tenantB"))

let provider = services.build()
let monitor = provider.getOrThrow<IOptionsMonitor<TenantOptions>>()
```

---

## API 参考

### OptionsConfigurationServiceCollectionExtensions

| 方法 | 说明 |
|------|------|
| `configure<TOptions>(configuration: IConfiguration): Unit` | 将指定配置节绑定到默认名称的 `TOptions` |
| `configure<TOptions>(name: String, configuration: IConfiguration): Unit` | 将指定配置节绑定到命名 options |

### OptionsBuilderConfigurationExtensions

| 方法 | 说明 |
|------|------|
| `bind(configuration: IConfiguration): OptionsBuilder<TOptions>` | 将当前 builder 绑定到指定配置节 |
| `bindConfiguration(configSectionPath: String): OptionsBuilder<TOptions>` | 从 DI 里的 `IConfiguration` 解析指定路径并绑定 |

---

## 当前支持范围

- 普通标量字段：`String`、`Bool`、各类整型/浮点型
- 无参自定义 enum 字段
- nullable 标量字段：`?String`、`?Bool`、`?Int64`、`?Float64` 等
- nullable 无参自定义 enum 字段
- 普通嵌套 `class` 字段
- nullable 嵌套 `class` 字段
- `Array<String>` 及各整型/浮点型数组

当前尚未覆盖：

- `Array<嵌套对象>`
- `?Array<T>`
- `Map` / `HashMap`
- 带参自定义枚举构造器
- 自定义转换器

---

## 相关包

- `soulsoft_extensions_options` - 选项模式基础设施
- `soulsoft_extensions_injection` - 依赖注入容器
- `soulsoft_extensions_configuration` - 配置系统与 `IConfiguration`

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
