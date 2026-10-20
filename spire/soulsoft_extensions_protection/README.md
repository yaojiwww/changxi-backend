# soulsoft.extensions.protection

**企业级数据保护与密钥管理扩展库，提供加密、解密和密钥生命周期管理功能。**
---

## 关于

`soulsoft.extensions.protection` 是一个企业级数据保护库，提供完整的加密/解密和密钥管理功能。通过 `IDataProtectionProvider` 和 `IDataProtector` 接口实现数据保护，支持密钥自动生成、过期管理、文件系统持久化和密钥托管。与依赖注入框架深度集成，提供链式配置 API。

### 特性

| 特性 | 描述 |
|------|------|
| 🔐 **数据加密/解密** | 通过 `IDataProtector` 提供 `protect`/`unprotect` 方法，支持字节数组加密 |
| 🔑 **密钥管理** | 自动生成密钥、设置生命周期、撤销管理，通过 `IKeyManager` 实现 |
| 💾 **文件系统持久化** | 通过 `FileSystemKeyRepository` 将密钥持久化到磁盘，支持并发安全 |
| 🔗 **依赖注入集成** | 扩展 `ServiceCollection`，提供 `addDataProtection()` 方法注册服务 |
| ⚙️ **链式配置** | `DataProtectionBuilder` 支持链式调用，配置应用名、密钥生命周期、加密算法等 |
| 🎯 **目的隔离** | 不同 purpose 的 protector 无法互相解密，确保数据隔离 |
| 🔒 **密钥托管** | 通过 `IKeyEscrowSink` 在密钥持久化前接收明文副本，支持合规审计 |
| 🧵 **线程安全** | 基于 `ConcurrentHashMap`、`Mutex` 和原子操作实现，支持高并发场景 |

---

## 如何使用

### 基本操作

```cj
import soulsoft_extensions_injection.*
import soulsoft_extensions_protection.*

// 注册数据保护服务
let services = ServiceCollection()
services.addDataProtection()
let sp = services.build()

// 创建 protector 并加密数据
let provider = sp.getOrThrow<IDataProtectionProvider>()
let protector = provider.createProtector("my-purpose")

// 加密
let plaintext: Array<Byte> = [72, 101, 108, 108, 111]  // "Hello"
let ciphertext = protector.protect(plaintext)

// 解密
let recovered = protector.unprotect(ciphertext)
// recovered == plaintext
```

### 配置选项

```cj
import soulsoft_extensions_injection.*
import soulsoft_extensions_protection.*
import std.fs.*
import std.time.*

let services = ServiceCollection()

// 链式配置
services.addDataProtection()
    .setApplicationName("MyApp")
    .setDefaultKeyLifetime(Duration.day * 90)
    .persistKeysToFileSystem(Path("/var/keys"))
    .disableAutomaticKeyGeneration()

let sp = services.build()
```

### 自定义密钥管理

```cj
import soulsoft_extensions_injection.*
import soulsoft_extensions_protection.*

let services = ServiceCollection()
services.addDataProtection()

// 配置密钥管理选项
services.configure<KeyManagementOptions>({ opts =>
    opts.autoGenerateKeys = false
    opts.newKeyLifetime = Duration.day * 180
})

// 添加密钥托管接收器
let builder = services.addDataProtection()
builder.addKeyEscrowSink(MyEscrowSink())

let sp = services.build()
```

---

## API 参考

### DataProtectionServiceCollectionExtensions

| 方法 | 说明 |
|------|------|
| `addDataProtection(): DataProtectionBuilder` | 注册数据保护服务，返回配置构建器 |
| `addDataProtection(configureOptions: (DataProtectionOptions) -> Unit): DataProtectionBuilder` | 注册服务并配置选项 |

### DataProtectionBuilder

| 方法 | 说明 |
|------|------|
| `setApplicationName(applicationName: String): DataProtectionBuilder` | 设置应用程序鉴别器，用于隔离不同应用的密钥 |
| `disableAutomaticKeyGeneration(): DataProtectionBuilder` | 禁用密钥自动生成 |
| `setDefaultKeyLifetime(lifetime: Duration): DataProtectionBuilder` | 设置新密钥的默认生命周期，负值抛出 `IllegalArgumentException` |
| `addKeyManagementOptions(configureOptions: (KeyManagementOptions) -> Unit): DataProtectionBuilder` | 添加密钥管理配置回调 |
| `addKeyEscrowSink(sink: IKeyEscrowSink): DataProtectionBuilder` | 注册密钥托管接收器，可多次调用追加多个接收器 |
| `persistKeysToFileSystem(path: Path): DataProtectionBuilder` | 配置密钥持久化到文件系统 |
| `useCryptographicAlgorithms(configuration: AuthenticatedEncryptorConfiguration): DataProtectionBuilder` | 配置加密算法 |

### IDataProtectionProvider

| 方法 | 说明 |
|------|------|
| `createProtector(purpose: String): IDataProtector` | 创建指定用途的数据保护器 |

### IDataProtector

| 方法 | 说明 |
|------|------|
| `protect(plaintext: Array<Byte>): Array<Byte>` | 加密明文，返回密文 |
| `unprotect(ciphertext: Array<Byte>): Array<Byte>` | 解密密文，返回明文，失败抛出异常 |
| `createProtector(purpose: String): IDataProtector` | 创建子保护器，形成链式 purpose |

### IKeyManager

| 方法 | 说明 |
|------|------|
| `createNewKey(activationDate: DateTime, expirationDate: DateTime): IKey` | 创建新密钥，指定激活和过期时间 |
| `getAllKeys(): ReadOnlyList<IKey>` | 获取所有密钥 |

### KeyManagementOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `autoGenerateKeys` | `Bool` | 是否自动生成密钥 |
| `newKeyLifetime` | `Duration` | 新密钥的生命周期 |
| `keyRepository` | `?IKeyRepository` | 密钥存储库实现 |
| `keyEscrowSinks` | `ArrayList<IKeyEscrowSink>` | 密钥托管接收器列表 |
| `authenticatedEncryptorConfiguration` | `?AuthenticatedEncryptorConfiguration` | 加密算法配置 |

### DataProtectionOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `applicationDiscriminator` | `String` | 应用程序鉴别器，用于隔离不同应用的密钥 |

---

## 相关包

- `soulsoft_extensions_options` - 选项模式支持
- `soulsoft_extensions_injection` - 依赖注入框架

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [.NET Data Protection](https://github.com/dotnet/aspnetcore) 中的 Data Protection 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
