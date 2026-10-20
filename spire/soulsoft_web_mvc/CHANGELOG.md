# CHANGELOG — soulsoft.web.mvc

## v1.1.0 - 2026-03-26

### Breaking Changes

- **`TypeInfoExtensions` 接口** 已删除（原位于 `soulsoft_web_mvc.infrastructure`）
  迁移方式：该功能已内联到 `ComplexTypeModelBinder` 内部使用，不再作为公共 API 暴露
- **`IJsonOptions`** 接口已删除（原位于 `soulsoft_web_mvc.abstractions`）
  迁移方式：直接使用 `MvcOptions.jsonSerializerOptions` 属性访问序列化配置
- **`IFromatterOptions`** 接口已删除（原位于 `soulsoft_web_mvc.formatters`）
  迁移方式：直接使用 `MvcOptions` 访问 `inputFormatters`、`outputFormatters` 等属性
- **`soulsoft_web_mvc.bindings` 包已删除**（含 `IModelBinder`、`ModelBindingContext`、
  `ModelBindingException`、`UnsupportedContentTypeException`）
  迁移方式：改用 `soulsoft_web_mvc.modelBindings` 包，使用 `IActionModelBinder` 接口
- **`IModelBinder.bind(context: ModelBindingContext): Array<Any>`** 接口已删除
  迁移方式：实现 `IModelBinder<T>` 并通过 `MvcOptions.modelBinders` 注册

### Removed

- **`TypeInfoExtensions`** — 已内联到使用处，不再需要公共扩展接口
- **`TypeInfo.getInstanceProperties()` 扩展方法** — 随接口一起移除
- **`IJsonOptions`** — 与 `MvcOptions` 重复，统一通过 `MvcOptions` 配置 JSON 序列化
- **`IFromatterOptions`** — 与 `MvcOptions` 重复，统一通过 `MvcOptions` 管理格式化器
- **`soulsoft_web_mvc.bindings.*`** — 整包删除，职责拆分至 `modelBindings` 和 `utilities`
- **`DefaultModelBinder`** — 替换为 `DefaultActionModelBinder` + `ModelBinderFactory` 组合

### Added

- **`FromHeader.name` 属性** — 支持显式指定 HTTP Header 名称，例如 `@FromHeader(name: "X-Custom-Header")`
- **`FromHeader` 新增带参构造函数** — `init(name!: ?String)` 允许构造时传入 header 名称
- **`HeaderCollection` 内部类** — 实现 `IQueryCollection` 接口，用于从 HTTP Headers 中绑定单个指定名称的 header 值
- **`MvcServiceCollectionExtensions.addControllers(packageName: String)`** — 新增重载，
  支持按包名直接注册应用程序部件
- **`soulsoft_web_mvc.modelBindings` 包** — 新包，包含各类型绑定器：
  `PrimitiveModelBinder`、`StringModelBinder`、`DateTimeModelBinder`、
  `ArrayModelBinder`、`NullableModelBinder`、`ComplexObjectModelBinder`、`FormFileModelBinder`
- **`IModelBinderFactory`** — 绑定器工厂接口，`ModelBinderFactory` 通过 `ModelBinderCollection`
  自动选择合适的绑定器
- **`MvcOptions.modelBinders`** — 新增 `ModelBinderCollection` 属性，允许用户注册自定义绑定器
- **`MvcOptionsSetup`** — 通过 `IConfigureOptions<MvcOptions>` 注册默认格式化器，
  替换原 `addMvcCore` 中的内联配置模式
- **`soulsoft_web_mvc.utilities.Nullable`** — 从 `infrastructure` 迁移至独立 `utilities` 包

### Changed

- **`DefaultActionModelBinder`** — 完成 FromHeader 注解的完整实现，支持通过注解将 HTTP Header 绑定到 action 参数
- 核心类型（`ActionResult`、`Controller`、`MvcOptions` 等）迁移至 `soulsoft_web_mvc.core` 子包
- 基础设施类型迁移至 `soulsoft_web_mvc.infrastructure` 子包
- `OutputFormatter`、`OutputFormatterSelector` 从 `IOutputFormatter.cj` 拆分为独立文件
- `ControllerRequestDelegateFactory`、`DefaultOutputFormatterSelector`、
  `JsonInputFormatter`、`JsonOutputFormatter` 构造函数改为注入 `IOptions<MvcOptions>`
- **`MediaType.quality`** 默认值从 `0.0` 修正为 `1.0`（符合 RFC 7231 §5.3.1）
- `JsonInputFormatter.canRead` 改为按 RFC 4627/7159/8259 枚举支持的媒体类型列表匹配

---

## v1.0.0

初始发布。
