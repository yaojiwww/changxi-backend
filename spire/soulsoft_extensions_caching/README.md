# soulsoft.extensions.caching

**分布式缓存库，提供统一的 `IDistributedCache` 接口与基于内存的默认实现。**
---

## 关于

soulsoft.extensions.caching 提供统一的分布式缓存接口 `IDistributedCache` 和基于内存的默认实现 `MemoryDistributedCache`。支持滑动过期、绝对过期和相对过期三种策略，可与依赖注入容器无缝集成。`MemoryDistributedCache` 基于 `ConcurrentHashMap` 和原子操作实现，线程安全。

### 特性

| 特性 | 描述 |
|------|------|
| 🔌 **统一缓存接口** | `IDistributedCache` 定义标准的 get/set/refresh/remove 操作，支持字节数组和字符串两种数据形式 |
| 🧠 **内存缓存实现** | `MemoryDistributedCache` 开箱即用，无需外部依赖 |
| ⏱️ **三种过期策略** | 支持滑动过期（`slidingExpiration`）、绝对时刻过期（`absoluteExpiration`）、相对过期（`absoluteExpirationRelativeToNow`），可组合使用 |
| 🔄 **后台过期扫描** | 通过 `DistributedCacheOptions.expirationScanFrequency` 配置扫描频率，异步清理过期项 |
| 💉 **依赖注入集成** | `ServiceCollection.addDistributedMemoryCache()` 一行注册，支持链式调用和自定义配置 |
| 🔒 **线程安全** | 基于 `ConcurrentHashMap` 和 `AtomicBool`/`AtomicReference` 实现并发安全 |

## 如何使用

### 基本操作

```cj
import soulsoft_extensions_caching.*
import soulsoft_extensions_options.*

let cache = MemoryDistributedCache(Options.create(DistributedCacheOptions()))

// 存取字符串
cache.setString("key", "value")
if (let Some(v) <- cache.getString("key")) {
    println(v)
}

// 存取字节数组
cache.set("data", "hello".toArray())
if (let Some(bytes) <- cache.get("data")) {
    println(String.fromUtf8(bytes))
}

// 刷新（重置滑动过期计时器；已过期则自动移除）
cache.refresh("key")

// 移除
cache.remove("key")
```

### 使用过期时间

```cj
import soulsoft_extensions_caching.*
import soulsoft_extensions_options.*
import std.time.*

let cache = MemoryDistributedCache(Options.create(DistributedCacheOptions()))

// 滑动过期：每次访问重置计时器
cache.setString("session", "data", DistributedCacheEntryOptions(
    slidingExpiration: Some(Duration.minute * 5)
))

// 绝对过期：指定确切时刻
cache.setString("token", "abc", DistributedCacheEntryOptions(
    absoluteExpiration: Some(DateTime.nowUTC() + Duration.hour)
))

// 相对过期：相对于创建时间的时长
cache.setString("daily", "data", DistributedCacheEntryOptions(
    absoluteExpirationRelativeToNow: Some(Duration.day)
))
```

### 与依赖注入集成

```cj
import soulsoft_extensions_caching.*
import soulsoft_extensions_injection.*
import std.time.*

let services = ServiceCollection()

// 注册（可选：自定义扫描频率）
services.addDistributedMemoryCache { options =>
    options.expirationScanFrequency = Duration.minute * 30
}

let serviceProvider = services.build()
if (let Some(cache) <- serviceProvider.get<IDistributedCache>()) {
    cache.setString("key", "value")
}
```

## API 参考

### IDistributedCache

| 方法 | 说明 |
|------|------|
| `get(key: String): ?Array<Byte>` | 获取缓存值，不存在或已过期返回 `None` |
| `set(key: String, value: Array<Byte>): Unit` | 存储字节数组，无过期时间 |
| `set(key: String, value: Array<Byte>, options: DistributedCacheEntryOptions): Unit` | 存储字节数组，指定过期策略 |
| `refresh(key: String): Unit` | 重置滑动过期计时器；若已过期则移除条目 |
| `remove(key: String): Unit` | 移除缓存项 |
| `getString(key: String): ?String` | 获取字符串缓存值，不存在或已过期返回 `None` |
| `setString(key: String, value: String): Unit` | 存储字符串，无过期时间 |
| `setString(key: String, value: String, options: DistributedCacheEntryOptions): Unit` | 存储字符串，指定过期策略 |

### DistributedCacheOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `expirationScanFrequency` | `Duration` | `Duration.minute` | 后台异步扫描过期项的频率 |

### DistributedCacheEntryOptions

三种过期策略可单独使用或组合，任一条件满足即视为过期。

| 属性 | 类型 | 说明 |
|------|------|------|
| `slidingExpiration` | `?Duration` | 滑动过期，每次访问（get/refresh）重置计时器 |
| `absoluteExpiration` | `?DateTime` | 绝对时刻过期，到达指定 UTC 时间后过期 |
| `absoluteExpirationRelativeToNow` | `?Duration` | 相对过期，相对于条目创建时间的时长 |

## 相关包

- `soulsoft_extensions_injection` - 依赖注入
- `soulsoft_extensions_options` - 配置选项

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [.NET Runtime](https://github.com/dotnet/runtime) 中的缓存模块，原始代码版权归 .NET Foundation and contributors 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
