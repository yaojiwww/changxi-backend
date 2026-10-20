# soulsoft.extensions.configuration

**统一的配置管理库，支持 JSON、环境变量、命令行参数、内存字典等多种配置源，键名不区分大小写。**
---

## 关于

`soulsoft.extensions.configuration` 提供统一的 `IConfiguration` 接口，屏蔽不同配置来源的差异。核心实现 `ConfigurationRoot` 和 `ConfigurationManager` 基于 `IgnoreCaseHashMap` 实现键名不区分大小写的存储与检索。配置系统支持层次结构（用 `:` 分隔路径），多源叠加时后注册的源优先级更高。

源码层面，各配置源统一按 `Source / Provider / BuilderExtensions` 三类文件拆分，便于按职责维护与扩展。

### 特性

| 特性 | 描述 |
|------|------|
| 🔌 **多配置源** | 支持 JSON 字符串/文件、环境变量（前缀过滤）、命令行参数（`--key value` / `--key=value` / `/key=value`）、内存字典、链式接入已有配置 |
| 🔤 **键名不区分大小写** | 所有配置键统一按 ASCII 不区分大小写匹配，`Database:Host` 与 `database:host` 等价 |
| 🗂️ **层次配置节** | 通过 `getSection(name)` / `getChildren()` 访问嵌套结构，路径分隔符为 `:` |
| 🔄 **配置热重载** | `IConfigurationRoot.reload()` 重新加载所有提供者数据 |
| 🔀 **多源优先级覆盖** | 后注册的配置源优先级更高，支持分环境配置叠加 |
| 🎯 **泛型类型转换** | `getValue<T>(name)` 自动将字符串转换为 `Bool`、`Int64`、`Float64`、`BigInt`、`Decimal` 等基础类型 |
| 📦 **对象绑定** | `bind(name, instance)` 将配置节自动绑定到对象；普通对象默认绑定当前类直接声明的可变字段，也支持通过 `IConfigurationBinding` 自定义写回 |
| 🏗️ **两种构建模式** | `ConfigurationBuilder`（构建后不可变）和 `ConfigurationManager`（可动态增减源） |

---

## 如何使用

### 基本配置构建与访问

```cj
import soulsoft_extensions_configuration.*

// 多源叠加：后注册的源优先级更高
let config = ConfigurationManager()
    .addJsonString(###"{"Database": {"Host": "localhost", "Port": 3306}}"###)
    .addEnvVars(prefix: "MYAPP_")
    .build()

// 键名不区分大小写
if (let Some(host) <- config["Database:Host"]) {
    println("Host: ${host}")
}
if (let Some(host) <- config["database:host"]) {
    println("Host (小写): ${host}")
}

// 获取配置节
let dbSection = config.getSection("Database")
if (let Some(port) <- dbSection["Port"]) {
    println("Port: ${port}")
}

// 遍历子节
for (child in config.getChildren()) {
    println("Section: ${child.key}")
}
```

### JSON、环境变量与命令行参数

```cj
import soulsoft_extensions_configuration.*

let args = ["--environment", "Production", "--port=8080"]

let config = ConfigurationBuilder()
    .addJsonFile("appsettings.json")          // 可选文件，不存在时跳过
    .addEnvVars()                              // 加载全部环境变量
    .addCmdArgs(args)                          // 命令行参数优先级最高
    .build()

if (let Some(env) <- config["environment"]) {
    println("Environment: ${env}")
}

// 带前缀的环境变量（双下划线映射为路径分隔符）
// 环境变量 MYAPP__Database__Host => config["Database:Host"]
let prefixedConfig = ConfigurationBuilder()
    .addEnvVars(prefix: "MYAPP_")
    .build()
```

### JSON 字符串配置与对象绑定

```cj
import soulsoft_extensions_configuration.*

class AppSettings {
    public var name: String = ""
    public var port: Int64 = 0
    public var debug: Bool = false
}

let config = ConfigurationManager()
    .addJsonString(
        ###"{
            "app": {
                "name": "MyApp",
                "port": 8080,
                "debug": true
            }
        }"###
    )
    .build()

// 底层键路径通过 `:` 分割，例如 `app:name`、`app:port`

// 将配置节绑定到对象
let settings = AppSettings()
config.bind("app", settings)
println("${settings.name}:${settings.port}")  // MyApp:8080

// 泛型类型转换
if (let Some(port) <- config.getValue<Int64>("app:port")) {
    println("Port as Int64: ${port}")
}
```

### 继承字段绑定

默认反射绑定路径只会处理当前类直接声明的 `var` 字段。  
如果对象存在继承链字段需要绑定，可实现 `IConfigurationBinding`，由对象自行接收绑定结果。

```cj
import soulsoft_extensions_configuration.*

open class BaseSettings {
    public var baseName: String = ""
}

open class MidSettings <: BaseSettings {
    public var midName: String = ""
}

open class AppSettings <: MidSettings {
    public var port: Int64 = 0
}

class BindableAppSettings <: AppSettings & IConfigurationBinding {
    public func bind(name: String, value: Any): Unit {
        if (name == "baseName") {
            this.baseName = (value as String).getOrThrow()
            return
        }
        if (name == "midName") {
            this.midName = (value as String).getOrThrow()
            return
        }
        if (name == "port") {
            this.port = (value as Int64).getOrThrow()
        }
    }
}

let config = ConfigurationManager()
    .addJsonString(
        ###"{
            "app": {
                "baseName": "BaseApp",
                "midName": "MidApp",
                "port": 9100
            }
        }"###
    )
    .build()

let settings = BindableAppSettings()
config.bind("app", settings)
```

---

## API 参考

### IConfiguration

| 方法 / 操作符 | 说明 |
|---|---|
| `[name: String]: ?String` | 按键读取配置值，键不存在返回 `None` |
| `[name: String, value!: ?String]: Unit` | 写入配置值 |
| `getSection(name: String): IConfigurationSection` | 获取指定名称的配置节 |
| `getChildren(): Collection<IConfigurationSection>` | 获取所有直接子配置节 |
| `getValue<T>(name: String): ?T` | 读取并转换为指定类型，支持 `Bool`、`Int8~Int64`、`UInt8~UInt64`、`Float16~Float64`、`BigInt`、`Decimal` |
| `bind(name: String, instance: Object): Unit` | 将配置节绑定到对象；普通对象默认绑定当前类直接声明的 `var` 字段，实现 `IConfigurationBinding` 的对象可自定义写回 |

### IConfigurationBinding

| 方法 | 说明 |
|---|---|
| `bind(name: String, value: Any): Unit` | 接收已完成类型转换的绑定值，可用于处理继承字段等默认反射写回路径无法覆盖的场景 |

### IConfigurationBuilder

| 方法 | 说明 |
|---|---|
| `add(source: IConfigurationSource): IConfigurationBuilder` | 注册配置源 |
| `build(): IConfigurationRoot` | 构建并返回配置根 |
| `prop sources: List<IConfigurationSource>` | 已注册的配置源列表 |
| `prop properties: Map<String, Any>` | 构建器附加属性 |

### IConfigurationRoot

| 方法 | 说明 |
|---|---|
| `reload(): Unit` | 重新加载所有配置提供者的数据 |
| `prop providers: ReadOnlyList<IConfigurationProvider>` | 底层提供者列表 |

### IConfigurationSection

| 属性 | 类型 | 说明 |
|---|---|---|
| `key` | `String` | 当前节的键名（不含父路径） |
| `value` | `?String` | 当前节的直接值（叶节点） |
| `path` | `String` | 从根到当前节的完整路径 |

### ConfigurationBuilder 扩展方法

| 方法 | 说明 |
|---|---|
| `addJsonString(json: String): ConfigurationBuilder` | 加载 JSON 字符串 |
| `addJsonStream(stream: IOStream): ConfigurationBuilder` | 从流加载 JSON |
| `addJsonFile(path: String, optional!: Bool = true): ConfigurationBuilder` | 从文件加载 JSON，`optional: true` 时文件不存在则跳过 |
| `addEnvVars(): ConfigurationBuilder` | 加载全部环境变量 |
| `addEnvVars(prefix: String): ConfigurationBuilder` | 加载指定前缀的环境变量（双下划线 `__` 映射为 `:`） |
| `addCmdArgs(args: Array<String>, switchMappings!: ?Map<String, String> = None): ConfigurationBuilder` | 加载命令行参数，支持 `--key value`、`--key=value`、`/key=value` 格式 |
| `addMemory(): ConfigurationBuilder` | 加载空的内存配置源 |
| `addMemory(values: Collection<(String, String)>): ConfigurationBuilder` | 加载键值对集合 |
| `addConfiguration(configuration: IConfiguration, shouldDisposeConfiguration!: Bool = false): ConfigurationBuilder` | 将已有配置对象作为链式配置源加入 |

### ConfigurationManager 扩展方法

| 方法 | 说明 |
|---|---|
| `addJsonString(json: String): ConfigurationManager` | 加载 JSON 字符串 |
| `addJsonStream(stream: IOStream): ConfigurationManager` | 从流加载 JSON |
| `addJsonFile(path: String, optional!: Bool = true): ConfigurationManager` | 从文件加载 JSON，`optional: true` 时文件不存在则跳过 |
| `addEnvVars(): ConfigurationManager` | 加载全部环境变量 |
| `addEnvVars(prefix: String): ConfigurationManager` | 加载指定前缀的环境变量（双下划线 `__` 映射为 `:`） |
| `addCmdArgs(args: Array<String>, switchMappings!: ?Map<String, String> = None): ConfigurationManager` | 加载命令行参数，支持 `--key value`、`--key=value`、`/key=value` 格式 |
| `addMemory(): ConfigurationManager` | 加载空的内存配置源 |
| `addMemory(values: Collection<(String, String)>): ConfigurationManager` | 加载键值对集合 |
| `addConfiguration(configuration: IConfiguration, shouldDisposeConfiguration!: Bool = false): ConfigurationManager` | 将已有配置对象作为链式配置源加入 |

`shouldDisposeConfiguration` 目前仅保留 API 兼容性，现有运行时不会自动释放被链接的配置对象。

### ConfigurationPath

| 方法 | 说明 |
|---|---|
| `static combine(segments: Array<String>): String` | 用 `:` 拼接多段路径 |
| `static getSectionKey(path: String): String` | 提取路径末段键名 |
| `static getParentPath(path: String): ?String` | 获取父路径，根节点返回 `None` |
| `static let delimiter: String` | 路径分隔符，值为 `":"` |

---

## 相关包

- `soulsoft_extensions_options` - 配置选项模式（`IOptions<T>`）
- `soulsoft_extensions_injection` - 依赖注入，支持将配置注册为服务
- `soulsoft_extensions_logging` - 日志系统，可从配置读取日志级别

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `Microsoft.Extensions.Configuration` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
