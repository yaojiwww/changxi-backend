# CHANGELOG — soulsoft.serialization

## v1.2.0 - 2026-08-31

### Breaking Changes

- 序列化核心协议从 `DataModel` 中间模型切换为 `JsonReader` / `JsonWriter` 流式协议：
  `IDeserializable<T>.deserializeObject(dm, options)` 迁移为 `IDeserializable<T>.fromJson(r, options)`，
  `ISerializable.serializeObject(options)` 迁移为 `ISerializable.toJson(w, options)`
- `JsonSerializer` 对外入口统一为 `serialize` / `deserialize`：
  `serializeObject(data[, options])` 迁移为 `serialize(data[, options])`，
  `deserializeObject<T>(json[, options])` 迁移为 `deserialize<T>(json[, options])`
- `JsonSerializer.deserializeObject<T>(dm: DataModel, ...)` 已移除；如果调用方仍持有动态 JSON 数据，请改用
  `JsonSerializer.deserialize<T>(json: JsonValue, options)` 或先转换为 JSON 文本/字节/流
- `JsonConverter<T>` 读写签名已同步切换为流式接口：
  `read(dm, options)` 迁移为 `read(r, options)`，
  `write(value, options)` 迁移为 `write(w, value, options)`
- 字段名映射注解由 `DataField` 重命名为 `JsonPropertyName`；
  旧的 `@DataField["..."]` 写法需迁移为 `@JsonPropertyName["..."]`，并导入 `soulsoft_serialization.annotations.*`
- `JsonSerializerOptions.nullable` 与 `JsonNullable` 策略已移除；当前空值语义固定为：
  非可空字段遇到缺失或 JSON `null` 时保留默认值，`Option<T>` 字段遇到 `null` 时得到 `None`
- 原先依赖 `DataModelException` 的错误语义已迁移到 `JsonSerializationException`
- 受 SqlSharp v1.2.0 影响，`sqlsharp.serialization` 不再重导出本库；使用方需要直接依赖
  `soulsoft_serialization`，并将 `import sqlsharp.serialization.*` 改为 `import soulsoft_serialization.*`；
  若仍使用 `@Serialization` 宏，还需要导入 `soulsoft_serialization.macros.*`

### Changed

- `JsonSerializer` 现在直接支持 `String`、`Array<Byte>`、`InputStream` / `OutputStream`、`JsonValue` 四类编解码入口，并补齐 `TypeInfo` 反射重载
- `JsonSerializerOptions.writeIndented` 现在统一作用于字符串、UTF-8 字节数组和流序列化入口；启用后使用 `WriteConfig.pretty` 输出格式化 JSON
- 所有内置标量、集合、`Option<T>`、`JsonValue` 均已适配新的流式 JSON 协议
- 内置数值类型的读取更贴近 JSON token 语义，减少中间转换带来的歧义
- `JsonSerializerOptions` 仅保留序列化配置职责，默认 converter 可通过独立入口查询和复用
- 可空数值/时间类型转换器已适配新的流式 JSON 协议
- `@Serialization` 生成的类型方法已切换为 `toJson` / `fromJson`
- 结构体序列化支持已同步迁移到新的流式 JSON 协议
- 多态反序列化改为直接基于 JSON 对象内容判别，不再要求调用方构造中间模型
- `@JsonPropertyName`、`@JsonPolymorphic`、`@JsonDerivedType` 的宏参数解析收紧为命名参数或字符串字面量，避免运行时歧义
- SqlSharp 查询物化在 v1.2.0 后不再以 JSON 序列化作为核心路径；`@Serialization` 在 SqlSharp 场景中主要用于 JSON 能力和 `_field` 字段简写生成属性

### Added

- 新增默认 converter 独立访问能力，便于查询和复用内置转换器
- 新增 `JsonSerializationException`，统一表示 JSON 序列化与反序列化错误
- 新增 `JsonReader` / `JsonWriter` 相关扩展入口，覆盖字符串、字节数组、流和格式化输出场景
- 新增 `JsonExtensionData`，支持把未声明 JSON 字段收集到扩展字段并在序列化时平铺写回
- 新增 `JsonPolymorphic` / `JsonDerivedType`，支持基于类型判别字段的继承层次序列化与反序列化

### Documentation

- README 更新为流式 JSON API，补充 `writeIndented`、扩展字段、多态、结构体和 `JsonValue` 示例
- CHANGELOG 补充从 v1.0/v1.1 `DataModel` API 到 v1.2.0 流式 API 的迁移改动面
- 补充 SqlSharp v1.2.0 解除 `soulsoft_serialization` 重导出后的导入与依赖迁移说明

### Upgrade Notes

- 新版本减少了 `DataModel` 中间转换，字符串、字节数组、流和 `JsonValue` 场景可以统一走 `JsonSerializer`
- `JsonReader` / `JsonWriter` 成为自定义 converter 的主要扩展点，手写 converter 需要优先按新签名迁移
- `@Serialization` 生成的类型现在直接暴露 `toJson` / `fromJson`，与手写实现保持一致
- 从 SqlSharp v1.2.0 迁移时，重点检查依赖声明、导入路径和是否仍需要 `@Serialization` 宏能力

### Migration Checklist

- 将 `JsonSerializer.serializeObject(...)` 替换为 `JsonSerializer.serialize(...)`
- 将 `JsonSerializer.deserializeObject<T>(...)` 替换为 `JsonSerializer.deserialize<T>(...)`
- 将手写 `ISerializable.serializeObject(options): DataModel` 实现改为 `toJson(w, options): Unit`
- 将手写 `IDeserializable<T>.deserializeObject(dm, options): T` 实现改为 `fromJson(r, options): T`
- 将手写 `JsonConverter<T>.read(dm, options)` / `write(value, options)` 改为 `read(r, options)` / `write(w, value, options)`
- 将 `@DataField["..."]` 替换为 `@JsonPropertyName["..."]`
- 删除 `JsonNullable` / `options.nullable` 相关配置，按新的固定 null 语义处理默认值
- 从 SqlSharp 迁移时，直接声明 `soulsoft_serialization` 依赖，并显式导入 `soulsoft_serialization.*`；
  使用宏时额外导入 `soulsoft_serialization.macros.*`

---
