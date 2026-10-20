# soulsoft.serialization

**面向仓颉语言的高性能流式 JSON 序列化库，基于 `JsonReader` / `JsonWriter`，通过 `@Serialization` 宏自动生成 `toJson` / `fromJson` 代码。**

---

## 关于

`soulsoft.serialization` 是一个面向仓颉语言的 JSON 序列化静态库。它直接构建在 `stdx.encoding.json.stream` 的流式读写器之上，绕过旧的 `DataModel` 中间层，减少中间对象分配与二次转换成本，适合对性能、可控性和可扩展性有要求的业务场景。

库的核心能力包括：

- 通过 `@Serialization` 宏在编译期自动生成 `ISerializable` / `IDeserializable<T>` 实现
- 通过 `JsonSerializer` 提供统一的字符串、UTF-8 字节数组、流、`JsonValue` 读写入口
- 通过 `JsonSerializerOptions` 控制缩进输出、可空策略、数值字符串解析、日期格式、null 忽略等运行时行为
- 通过 `JsonConverter<T>` 注入自定义类型读写逻辑

> **注意**：由于仓颉当前无法直接继承标准库接口，本库的序列化接口与标准库接口仍是分离的；如果你基于本库接口做了扩展，后续与标准库能力对齐时可能需要适配。

### 特性

| 特性 | 描述 |
|------|------|
| 🏎️ **高性能流式模型** | 直接基于 `JsonReader` / `JsonWriter` 读写 JSON，避免 `DataModel` 中间层带来的额外分配和转换 |
| 🏗️ **宏驱动代码生成** | `@Serialization` 自动生成构造器、属性、`toJson` / `fromJson` 实现，也允许手写同名属性或无参构造器接管默认生成行为 |
| 🔤 **字段名映射** | `@JsonPropertyName["json_key"]` 可将仓颉字段映射到自定义 JSON 键名 |
| 🧩 **未知字段保留** | `@JsonExtensionData` 可收集未声明 JSON 字段，并在再次序列化时原样平铺写回 |
| 🧭 **多态序列化** | `@JsonPolymorphic[...]` 与 `@JsonDerivedType[...]` 支持继承层次的类型判别字段写入与识别 |
| 🧬 **继承与结构体支持** | 支持 class 继承序列化，也支持 struct 的自动序列化与反序列化 |
| ⚙️ **丰富选项控制** | 支持 `writeIndented`、`JsonNumberHandling`、`JsonIgnoreCondition`、`dateFormatString` 等行为定制 |
| 🔌 **自定义转换器** | 可按类型注册 `JsonConverter<T>`，覆盖默认读写策略 |
| 📦 **集合与泛型支持** | 内置支持 `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K,V>` 以及嵌套集合 |
| 🔢 **常见标量全覆盖** | 内置支持整数、浮点、`Bool`、`String`、`BigInt`、`Decimal`、`DateTime`、`Option<T>`、`JsonValue` |
| 🪞 **反射反序列化** | 支持基于 `TypeInfo` 的动态反序列化入口，便于运行时按类型装配 |

---

## 如何使用

### 基本序列化与反序列化

使用 `@Serialization` 标注类或结构体，字段通常遵循 `_fieldName: Type = defaultValue` 形式，宏会自动生成属性、构造逻辑以及 `toJson` / `fromJson`。

```cj
import soulsoft_serialization.*
import soulsoft_serialization.macros.*

@Serialization
public class Student {
    private var _id: Int64 = 0
    private var _name: String = ""
    private var _optAge: ?Int64 = None
}

let student = Student(id: 1, name: "cangjie", optAge: None)

// 序列化为 JSON 字符串
let json = JsonSerializer.serialize(student)
// {"id":1,"name":"cangjie","optAge":null}

// 从 JSON 字符串反序列化
let restored = JsonSerializer.deserialize<Student>(#"{"id":100,"name":"world","optAge":20}"#)
println(restored.id)      // 100
println(restored.name)    // world

// 序列化为 UTF-8 字节数组
let bytes = JsonSerializer.serializeToUtf8Bytes(student)

// 序列化为 JsonValue
let jsonValue = JsonSerializer.serializeToJsonValue(student)
```

### 自定义属性与构造器

`@Serialization` 会为 `_fieldName` 后备字段生成同名属性，例如 `_items` 对应 `items`。如果类型中已经声明了同名属性，宏会保留用户属性，不再重复生成。这个能力适合用来控制对外 setter、暴露只读属性，或者让对外属性类型不同于 JSON 后备字段类型。

```cj
import std.collection.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*

@Serialization
public class Article {
    private var _title: String = ""
    private var _tags: ArrayList<String> = ArrayList<String>()

    public mut prop title: String {
        get() {
            _title
        }
        set(value) {
            if (value == "") {
                _title = "untitled"
            } else {
                _title = value
            }
        }
    }

    public prop tags: ReadOnlyList<String> {
        get() {
            _tags
        }
    }
}

let article = Article(title: "", tags: ArrayList<String>(["cangjie", "json"]))
let restored = JsonSerializer.deserialize<Article>(#"{"title":"intro","tags":["macro","json"]}"#)
```

上例中，构造器仍由宏按后备字段生成；`title` 的 setter 可以约束外部赋值；JSON 字段 `tags` 读写时使用后备字段 `_tags: ArrayList<String>`，对业务代码暴露的 `tags` 属性则是 `ReadOnlyList<String>`，避免调用方直接通过属性修改内部列表。当前生成的序列化与反序列化代码直接访问后备字段，因此构造和反序列化不会经过手写属性的 setter。

构造器也可以接管。只要类型已经声明无参 `init` 或无参主构造器，宏就不会再生成默认的公开命名参数构造器。这个无参构造器可以是 `private`，用于禁止业务代码直接 `Article()` 或使用宏生成的全字段构造器，同时仍允许宏生成的 `fromJson` 在类型内部创建实例。

```cj
@Serialization
public class AccessToken {
    private var _value: String = ""

    private init() {}

    public init(value: String) {
        _value = value
    }
}

let token = AccessToken("public-api")
let restored = JsonSerializer.deserialize<AccessToken>(#"{"value":"from-json"}"#)
```

### 流式读写

当你已经持有输入流或输出流时，可以直接走流式入口，避免额外的字符串中转。

```cj
import std.io.*
import soulsoft_serialization.*

let options = JsonSerializerOptions()
let buffer = ByteBuffer()
options.writeIndented = true

JsonSerializer.serialize(buffer, student, options)
let restored = JsonSerializer.deserialize<Student>(buffer, options)
```

### 字段名映射

```cj
import soulsoft_serialization.annotations.*

@Serialization
public class UserInfo {
    private var _id: Int64 = 0
    @JsonPropertyName["user_name"]
    private var _userName: String = ""
    @JsonPropertyName["create_time"]
    private var _createTime: String = ""
}

// 输出 {"id":1,"user_name":"alice","create_time":"2024-01-01"}
// 反序列化时 "user_name" 会自动映射到 userName 属性
```

### 未知字段保留

当你希望把未声明的 JSON 字段保留下来，而不是直接忽略时，可以使用 `@JsonExtensionData`。

```cj
import std.collection.*
import stdx.encoding.json.*
import soulsoft_serialization.annotations.*

@Serialization
public class AiContent {
    private var _id: Int64 = 0
    private var _name: String = ""

    @JsonExtensionData
    private var _extra: HashMap<String, JsonValue> = HashMap<String, JsonValue>()
}

let content = JsonSerializer.deserialize<AiContent>(
    #"{"id":1,"name":"bot","traceId":"t-1","retry":2}"#
)

println(content.extra["traceId"].asString()) // t-1
println(content.extra["retry"].asInt())      // 2
println(JsonSerializer.serialize(content))
// {"id":1,"name":"bot","traceId":"t-1","retry":2}
```

当前约束：

- 扩展字段当前稳定写法必须是成员字段，不建议标在属性上
- 字段名需要以下划线开头，例如 `_extra`
- 必须是 `var`，不能是 `let`
- 必须带显式类型标注
- 字段类型允许为任意已初始化的映射类型，只要它能按 `(String, JsonValue)` 键值对被遍历，并支持写入 `add(String, JsonValue)`
- 不支持与 `@JsonPropertyName` 叠用
- `struct` 不支持 `@JsonExtensionData`
- 整条继承链上只允许一个扩展字段

说明：

- 未知字段只会进入扩展字段，不会覆盖已声明字段
- 宏不会校验扩展字段的具体容器类型；如果容器不满足遍历或 `add` 契约，错误会在展开后的编译阶段暴露
- 扩展字段中的 key 如果和已声明 JSON 字段重名，序列化时会抛出 `JsonSerializationException`

### 继承

```cj
@Serialization
public open class BaseEntity {
    private var _id: Int64 = 0
}

@Serialization[superType: BaseEntity]
public class Article {
    private var _title: String = ""
    public init() {}
}

let article = Article()
article.id = 10
article.title = "hello"

let json = JsonSerializer.serialize(article)
// {"id":10,"title":"hello"}
```

### 多态序列化

```cj
import soulsoft_serialization.annotations.*
import soulsoft_serialization.macros.*

@Serialization
@JsonPolymorphic[typeDiscriminatorPropertyName: "$type"]
@JsonDerivedType[derivedType: TextContent, typeDiscriminator: "text"]
@JsonDerivedType[derivedType: DataContent, typeDiscriminator: "data"]
public open class AiContent {
    private var _id: Int64 = 0
}

@Serialization[superType: AiContent]
public class TextContent {
    private var _text: String = ""
    public init() {}
}

@Serialization[superType: AiContent]
public class DataContent {
    private var _payload: Int64 = 0
    public init() {}
}

let content: AiContent = TextContent(text: "hello")
let json = JsonSerializer.serialize(content)
// {"$type":"text","id":0,"text":"hello"}

let restored = JsonSerializer.deserialize<AiContent>(json)
// restored 的运行时类型为 TextContent
```

当前多态约束：

- `@JsonPolymorphic[...]` 与 `@JsonDerivedType[...]` 只支持命名参数
- 缺失类型判别字段时，按基类自身反序列化
- 遇到未知判别值时抛出 `JsonSerializationException`
- 当前实现下，要触发派生类型分发，discriminator 应出现在对象首字段位置

### struct 支持

```cj
@Serialization
public struct UserSnapshot {
    private var _id: Int64 = 0
    private var _name: String = ""
}

let json = JsonSerializer.serialize(UserSnapshot(id: 1, name: "snapshot"))
let restored = JsonSerializer.deserialize<UserSnapshot>(json)
```

### 配置选项

```cj
import std.time.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*

@Serialization
class Order {
    private var _count: Int64 = 0
    private var _price: Float64 = 0.0
    private var _createTime: DateTime = DateTime.now()
    private var _remark: ?String = None
}

let options = JsonSerializerOptions()

// 启用格式化输出
options.writeIndented = true
let pretty = JsonSerializer.serialize(Order(), options)

// 允许从字符串读取数值
options.numberHandling = JsonNumberHandling.AllowReadingFromString
let order = JsonSerializer.deserialize<Order>(
    #"{"count":"5","price":"3.14","createTime":"2025-01-01","remark":null}"#,
    options
)

// 自定义日期格式
options.dateFormatString = "yyyy-MM-dd"
let json = JsonSerializer.serialize(order, options)

// 非可空字段遇到 null 时回退默认值；缺失字段当前默认也会保留默认值
let fallback = JsonSerializer.deserialize<Order>(#"{"price":9.9}"#, options)

// 序列化时忽略 null
options.defaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
let compact = JsonSerializer.serialize(fallback, options)
```

### 自定义转换器

继承 `JsonConverter<T>`，实现基于 `JsonReader` / `JsonWriter` 的 `read` / `write`，然后注册到 `JsonSerializerOptions.converters`。

```cj
import soulsoft_serialization.*

class UpperCaseStringConverter <: JsonConverter<String> {
    public func read(r: JsonReader, options: JsonSerializerOptions): String {
        return r.readValue<String>().toAsciiUpper()
    }

    public func write(w: JsonWriter, value: String, options: JsonSerializerOptions): Unit {
        w.writeValue(value.toAsciiUpper())
    }
}

let options = JsonSerializerOptions()
options.converters.add(UpperCaseStringConverter())
```

### 集合与泛型

内置对 `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K, V>` 的支持，元素类型通常需要实现 `ISerialization<T>`。

```cj
import std.collection.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*

@Serialization
class Catalog {
    private var _tags: Array<String> = []
    private var _scores: ArrayList<Int64> = ArrayList<Int64>()
    private var _meta: HashMap<String, String> = HashMap<String, String>()
}

@Serialization
class Matrix {
    private var _grid: Array<Array<Int64>> = []
    private var _index: HashMap<String, Array<String>> = HashMap<String, Array<String>>()
}
```

---

## API 参考

### JsonSerializer

常用序列化入口：

- `static func serialize<T>(data: T): String`
- `static func serialize<T>(data: T, options: JsonSerializerOptions): String`
- `static func serializeToUtf8Bytes<T>(data: T): Array<Byte>`
- `static func serializeToUtf8Bytes<T>(data: T, options: JsonSerializerOptions): Array<Byte>`
- `static func serialize<T>(stream: OutputStream, data: T): Unit`
- `static func serialize<T>(stream: OutputStream, data: T, options: JsonSerializerOptions): Unit`
- `static func serializeToJsonValue<T>(data: T): JsonValue`
- `static func serializeToJsonValue<T>(data: T, options: JsonSerializerOptions): JsonValue`

常用反序列化入口：

- `static func deserialize<T>(json: String): T`
- `static func deserialize<T>(json: String, options: JsonSerializerOptions): T`
- `static func deserialize<T>(json: Array<Byte>): T`
- `static func deserialize<T>(json: Array<Byte>, options: JsonSerializerOptions): T`
- `static func deserialize<T>(stream: InputStream, options: JsonSerializerOptions): T`
- `static func deserialize<T>(json: JsonValue): T`
- `static func deserialize<T>(json: JsonValue, options: JsonSerializerOptions): T`

反射入口：

- `static func deserialize(typeInfo: TypeInfo, json: String, options: JsonSerializerOptions): Any`
- `static func deserialize(typeInfo: TypeInfo, json: Array<Byte>, options: JsonSerializerOptions): Any`
- `static func deserialize(typeInfo: TypeInfo, stream: InputStream, options: JsonSerializerOptions): Any`
- `static func deserialize(typeInfo: TypeInfo, json: JsonValue, options: JsonSerializerOptions): Any`

### JsonSerializerOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `writeIndented` | `Bool` | `false` | 启用后使用 `WriteConfig.pretty` 输出格式化 JSON；当前表现为换行加 4 空格缩进，并统一作用于字符串、UTF-8 字节数组和流序列化入口 |
| `numberHandling` | `JsonNumberHandling` | `JsonNumberHandling.Strict` | 支持 `AllowReadingFromString`、`WriteAsString` 及其组合 |
| `defaultIgnoreCondition` | `JsonIgnoreCondition` | `JsonIgnoreCondition.Never` | `WhenWritingNull` 时序列化跳过 `None` 字段 |
| `dateFormatString` | `?String` | `None` | 自定义 `DateTime` 输出与解析格式 |

相关成员：

- `let converters: ArrayList<IJsonConverter>`：自定义转换器列表，后注册优先级更高
- `func getConverter<T>(): ?JsonConverter<T>`：按类型解析 converter，未命中时回退到内置默认实现
- 非可空字段遇到显式 `null` 时会保留字段默认值
- 缺失字段当前同样保留默认值

### JsonConverter\<T\>

| 方法 | 说明 |
|------|------|
| `func read(r: JsonReader, options: JsonSerializerOptions): T` | 从流式 JSON 读取并转换为目标类型 |
| `func write(w: JsonWriter, value: T, options: JsonSerializerOptions): Unit` | 将目标类型写入 JSON 流 |

### ISerializable / IDeserializable\<T\> / ISerialization\<T\>

| 接口 | 方法 | 说明 |
|------|------|------|
| `ISerializable` | `func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit` | 将当前对象写入 JSON |
| `IDeserializable<T>` | `static func fromJson(r: JsonReader, options: JsonSerializerOptions): T` | 从 JSON 读取目标类型 |
| `ISerialization<T>` | `ISerializable & IDeserializable<T>` | 同时具备读写能力的组合接口 |

### JsonPropertyName

```cj
import soulsoft_serialization.annotations.*

@JsonPropertyName["json_key_name"]
private var _fieldName: Type = defaultValue
```

用于指定字段对应的 JSON 键名。当前只接受字符串字面量参数。

### JsonExtensionData

```cj
import std.collection.*
import stdx.encoding.json.*
import soulsoft_serialization.annotations.*

@JsonExtensionData
private var _extra: HashMap<String, JsonValue> = HashMap<String, JsonValue>()
```

用于承载未声明的 JSON 字段。

当前约束：

- 建议仅标在成员字段上
- 字段必须符合 `@Serialization` 的可处理规则：下划线开头、`var`、显式类型标注
- 字段类型允许为任意已初始化的映射类型，只要它能按 `(String, JsonValue)` 键值对被遍历，并支持写入 `add(String, JsonValue)`
- 不支持与 `@JsonPropertyName` 叠用
- `struct` 不支持
- 继承链上只允许出现一个扩展字段
- 宏不会校验扩展字段的具体容器类型；如果容器不满足遍历或 `add` 契约，错误会在展开后的编译阶段暴露

### JsonPolymorphic

```cj
import soulsoft_serialization.annotations.*

@JsonPolymorphic[typeDiscriminatorPropertyName: "$type"]
```

用于指定多态序列化时写入和读取的类型判别字段名。

### JsonDerivedType

```cj
import soulsoft_serialization.macros.*

@JsonDerivedType[derivedType: TextContent, typeDiscriminator: "text"]
```

用于在基类上注册派生类型与判别值的映射关系。这是一个编译期宏，不再生成运行时注解。

当前约束：

- 仅支持命名参数 `derivedType` 与 `typeDiscriminator`
- `derivedType` 必须直接写类型引用，例如 `TextContent`
- `typeDiscriminator` 必须是字符串字面量

---

## 相关包

- `soulsoft_serialization.macros`：`@Serialization` 编译期宏

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交问题和贡献代码。
