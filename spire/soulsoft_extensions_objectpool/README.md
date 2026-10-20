# soulsoft.extensions.objectpool

**面向仓颉的对象池扩展库，提供对象复用、策略化归还与可释放对象的自动清理能力。**
---

## 关于

`soulsoft.extensions.objectpool` 是面向仓颉语言的对象池库，参考 .NET `Microsoft.Extensions.ObjectPool` 设计，提供 `ObjectPool<T>`、`ObjectPoolProvider`、`IPooledObjectPolicy<T>` 等核心抽象，用于降低高频对象分配与回收带来的开销。

库内置默认对象池实现 `DefaultObjectPool<T>`，通过快速槽位加并发队列保存可复用对象；当池化对象实现 `Resource` 时，`DefaultObjectPoolProvider` 会自动创建 `DisposableObjectPool<T>`，在对象池关闭或对象被拒绝归还时执行资源清理。

### 特性

| 特性 | 描述 |
|------|------|
| ♻️ **对象复用** | 通过 `get()` / `put()` 复用短生命周期对象，减少重复分配 |
| 🔧 **策略化创建与归还** | 通过 `IPooledObjectPolicy<T>` 自定义对象创建、重置与拒收逻辑 |
| 🧩 **默认策略支持** | `DefaultPooledObjectPolicy<T>` 支持基于工厂函数创建对象，并自动识别 `IResettable` |
| 🗑️ **可释放对象自动清理** | 对于实现 `Resource` 的对象，池关闭或归还失败时会自动调用 `close()` |
| 🧵 **线程安全** | 默认实现基于 `Atomic*` 与 `ConcurrentLinkedQueue`，支持并发 `get()` / `put()` |
| ✍️ **StringBuilder 池化** | 提供 `createStringBuilderPool()` 扩展，便于复用 `StringBuilder` |

---

## 如何使用

### 基本使用

```cj
import soulsoft_extensions_objectpool.*

class Buffer {
    public var value: Int64 = 0
}

let pool = ObjectPoolFactory.create { => Buffer() }

let item = pool.get()
item.value = 42

// 使用完成后归还
item.value = 0
pool.put(item)
```

### 使用自定义策略

可以通过 `IPooledObjectPolicy<T>` 控制对象的创建方式和归还条件：

```cj
import soulsoft_extensions_objectpool.*

class Buffer {
    public var value: Int64 = 0
}

class BufferPolicy <: IPooledObjectPolicy<Buffer> {
    public func create(): Buffer {
        Buffer()
    }

    public func release(obj: Buffer): Bool {
        obj.value = 0
        return true
    }
}

let provider = DefaultObjectPoolProvider()
provider.maximumRetained = 32

let pool = provider.create(BufferPolicy())
let item = pool.get()
pool.put(item)
```

### 使用 `IResettable`

如果对象实现了 `IResettable`，`DefaultPooledObjectPolicy<T>` 会在归还时调用 `tryReset()`：

```cj
import soulsoft_extensions_objectpool.*

class ReusableBuffer <: IResettable {
    public var value: Int64 = 0

    public func tryReset(): Bool {
        value = 0
        return true
    }
}

let pool = ObjectPoolFactory.create { => ReusableBuffer() }
let buffer = pool.get()
buffer.value = 100
pool.put(buffer)
```

### 复用 `StringBuilder`

```cj
import soulsoft_extensions_objectpool.*

let provider = DefaultObjectPoolProvider()
let stringBuilderPool = provider.createStringBuilderPool(
    initialCapacity: 128,
    maximumRetainedCapacity: 4096
)

let builder = stringBuilderPool.get()
builder.append("hello")
builder.append(" world")

let text = builder.toString()
stringBuilderPool.put(builder)
```

> 注意：当前仓颉 `StringBuilder` 没有完全等价于 aspnetcore `Clear()` 的公开 API。  
> 归还 `StringBuilder` 时，本库会调用 `reset(capacity: initialCapacity)`，这会在清空内容的同时把容量回缩到初始容量，而不是保留归还前容量。

---

## API 参考

### ObjectPool<T>

| 方法 | 说明 |
|------|------|
| `get(): T` | 从对象池获取一个对象；池中无可用对象时创建新实例 |
| `put(obj: T): Unit` | 将对象归还到对象池；是否保留由策略决定 |

### ObjectPoolFactory

| 方法 | 说明 |
|------|------|
| `create<T>(factory: () -> T): ObjectPool<T>` | 使用默认策略与对象工厂创建对象池 |
| `create<T>(policy: ?IPooledObjectPolicy<T>, factory: () -> T): ObjectPool<T>` | 使用指定策略创建对象池；`policy = None` 时回退到默认策略 |

### ObjectPoolProvider / DefaultObjectPoolProvider

| 成员 | 说明 |
|------|------|
| `create<T>(factory: () -> T): ObjectPool<T>` | 使用工厂函数创建对象池 |
| `create<T>(policy: IPooledObjectPolicy<T>): ObjectPool<T>` | 使用对象池策略创建对象池 |
| `maximumRetained: Int64` | `DefaultObjectPoolProvider` 的最大保留对象数配置 |

说明：
`DefaultObjectPoolProvider` 对普通对象创建 `DefaultObjectPool<T>`，对实现 `Resource` 的对象创建 `DisposableObjectPool<T>`。

### IPooledObjectPolicy<T> / PooledObjectPolicy<T>

| 方法 | 说明 |
|------|------|
| `create(): T` | 创建新的对象实例 |
| `release(obj: T): Bool` | 对象归还时执行重置或校验；返回 `true` 表示保留，`false` 表示丢弃 |

`PooledObjectPolicy<T>` 提供抽象基类，便于扩展自定义策略。

### DefaultPooledObjectPolicy<T>

| 成员 | 说明 |
|------|------|
| `init(factory: () -> T)` | 使用对象工厂创建默认策略 |
| `create(): T` | 调用工厂函数创建对象 |
| `release(obj: T): Bool` | 若对象实现 `IResettable`，调用 `tryReset()`；否则直接接受归还 |

### IResettable

| 方法 | 说明 |
|------|------|
| `tryReset(): Bool` | 重置对象状态并返回是否允许重新入池 |

### ObjectPoolProvider 扩展

| 方法 | 说明 |
|------|------|
| `createStringBuilderPool(): ObjectPool<StringBuilder>` | 创建默认配置的 `StringBuilder` 对象池 |
| `createStringBuilderPool(initialCapacity: Int64, maximumRetainedCapacity: Int64): ObjectPool<StringBuilder>` | 创建可配置容量的 `StringBuilder` 对象池 |

---

## 并发与关闭语义

- `DefaultObjectPool<T>` 支持多线程并发 `get()` / `put()`
- `DisposableObjectPool<T>` 在关闭后：
  - 后续 `get()` 会抛出 `IllegalStateException`
  - 后续 `put()` 不再保留对象，而是直接关闭对象（若对象实现 `Resource`）
- `close()` 为幂等操作，可重复调用

当前单元测试已覆盖：

- 普通对象池与可关闭对象池的基本复用语义
- `IResettable` 的默认策略行为
- `close()` 后的 `get()` / `put()` 行为
- 多线程 `get()` / `put()` 并发安全
- `close()` 与并发 `get()` 的交错边界

---

## 相关包

当前模块 `cjpm.toml` 未声明额外依赖包。

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [aspnetcore](https://github.com/dotnet/aspnetcore) 中的 `Microsoft.Extensions.ObjectPool` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
