# CHANGELOG — soulsoft.web.http

## v1.1.1 - 2026-03-27

### Breaking Changes

- **`IValueProvider.getAll(name: String)`** 返回类型由 `StringValues` 改为 `Collection<String>`；
  迁移方式：如需 `StringValues` 的特定行为，请使用 `StringValues.fromCollection()` 转换
- **`IQueryCollection.getAll(name: String)`** 返回类型由 `StringValues` 同步改为 `Collection<String>`
- **`RouteValueDictionary.getAll(key: String)`** 返回类型由 `StringValues` 同步改为 `Collection<String>`

---

## v1.1.0 - 2026-03-18

### Breaking Changes

- **`IQueryCollection.getAll(name: String)`** 返回类型由 `Collection<String>` 改为 `StringValues`；
  迁移方式：如需 `Collection<String>`，请调用 `.toArray()` 转换
- **`IFormCollection`** 接口继承由 `IQueryCollection` 改为 `IValueProvider`；
  迁移方式：依赖 `IFormCollection` 同时是 `IQueryCollection` 的代码需分别处理
- **`IHeaderDictionary`** 移除 `HttpHeaders` 扩展实现，`HttpHeaders` 不再自动实现 `IHeaderDictionary`；
  迁移方式：使用 `soulsoft_web_hosting.HeaderDictionary` 包装 `HttpHeaders`
- **`extend HttpHeaders <: IHeaderDictionary`** 已移除，相关方法（`add`/`remove`/`contains`/`operator[]`）不再可用

- **`HttpRequest.path`** 由只读属性（`prop`）改为可变属性（`mut prop`）；
  迁移方式：实现该抽象属性的子类须将声明同步改为 `mut prop`
- **`ApplicationBuilder.use(middleware: (HttpContext, () -> Unit) -> Unit): This`** 已移除；
  迁移方式：改用 `use(middleware: (HttpContext, RequestDelegate) -> Unit): This` 重载，
  将 `() -> Unit` 形式的 `next` 替换为 `RequestDelegate`（即 `(HttpContext) -> Unit`）

- **`EndpointBuilder.displayName`** 由只读属性（`prop`）改为可变属性（`mut prop`）；
  迁移方式：实现该抽象属性的子类须将声明同步改为 `mut prop`
- **`RouteValueDictionary`** 类型参数从 `Map<String, ?String>` 改为 `Map<String, String>`，
  所有公开方法签名同步变更（`get`/`add`/`addIfAbsent`/`replace`/`remove`/`removeIf`/
  `entryView`/`values`/`iterator`/`operator[]`/`fromArray`）；
  迁移方式：将调用处的 `?String`/`Some("...")`/`None` 替换为直接使用 `String`/`""`
- **`RouteValueDictionary.toHashMap(): HashMap<String, ?String>`** 已移除；
  迁移方式：若需 `HashMap`，请自行通过 `iterator` 遍历构建
- **`MediaType`** 和 **`MediaTypeParameterParser`** 结构体已移除（整个 `src/MediaType.cj` 文件删除）；
  迁移方式：改用新增的 `src/headers/MediaTypeHeaderValue`（提供符合 RFC 规范的媒体类型解析）
- **`CookieBuilder.init(expires:)`** 参数 `expires` 重命名为 `expiration`；
  迁移方式：将调用处 `expires:` 改为 `expiration:`
- **`CookieBuilder.createCookieHeaderValue(key:)`** 参数 `key` 重命名为 `name`；
  迁移方式：将调用处 `key:` 改为 `name:`
- **`BufferedReadStream.init(stream:offset:length:)`** 构造函数签名变更，
  新签名为 `init(stream: InputStream)` 和 `init(stream: InputStream, bufferSize: Int64)`；
  迁移方式：传入 `InputStream`，移除 offset/length 参数
- **`BufferedReadStream.seek(pos:)`** 返回类型由隐式 `Unit` 改为 `Int64`
- **`BufferedReadStream.read(buffer:)`** 返回类型由隐式 `Unit` 改为 `Int64`
- **`MultipartBoundary.getBoundaryBytes(expectLeadingCrlf:)`** 方法移除，
  改用 `expectLeadingCrlf()` 方法 + `boundaryBytes` 属性；
  迁移方式：先调用 `expectLeadingCrlf()`，再读取 `boundaryBytes` 属性

### Removed

- **`MediaType`** — 整体移除，由 `headers.MediaTypeHeaderValue` 替代

### Changed

- **`EndpointMetadataCollection.getMetadata<T>()`** 返回值从集合首项（`.first`）改为末项（`.last`），
  与 ASP.NET Core 语义对齐，后注册的元数据优先级更高
- **`PathString`** 接口列表新增 `Hashable`，新增 `hashCode(): Int64` 实现
- **`BufferedReadStream`** 内部改用环形缓冲区实现，字段从 `_start/_length/_offset` 重构为
  `_bufferData/_bufferOffset/_bufferCount`，读写性能更优
- **`MultipartBoundary`** 由内部字段封装类重构为完整功能类，新增 `beforeFirstBoundary()`
  状态管理和 `finalBoundaryLength` 属性
- **`MultipartReader`** 构造函数依赖从 `MultipartReaderStream` 改为 `BufferedReadStream`

### Added

- **`headers.MediaTypeHeaderValue`** — RFC 7231 规范的媒体类型头部值解析与构建
- **`headers.NameValueHeaderValue`** — name=value 格式头部键值对处理
- **`headers.HeaderUtilities`** — HTTP 头部通用工具函数
- **`headers.HttpRuleParser`** — HTTP 语法规则底层解析器
- **`PathString.empty`** — 空路径静态常量 `PathString("")`
- **`PathString.toUriComponent(): String`** — 将路径编码为 URI 组件
- **`PathString.fromUriComponent(uriComponent: String): PathString`** — 静态工厂方法
- **`PathString.startsWithSegments(other: PathString, ignoreCase: Bool): ?PathString`** — 忽略大小写的路径前缀匹配
- **`PathString.add(other: PathString): PathString`** — 路径拼接
- **`PathString.add(other: QueryString): String`** — 路径与查询字符串拼接
- **`PathString.operator+(other: PathString): PathString`**
- **`PathString.operator+(other: QueryString): String`**
- **`PathString.operator+(other: String): String`**

### Added

- **`BufferedReadStream.bufferedData`** — 只读属性，暴露当前缓冲区数据切片 `(Array<Byte>, Int64, Int64)`
- **`BufferedReadStream.ensureBuffered(minCount: Int64): Bool`** — 确保缓冲区中至少有 minCount 字节可读
- **`BufferedReadStream.ensureBuffered(): Bool`** — 无参重载，一次性尽量填满缓冲区
- **`BufferedReadStream.readLine(lengthLimit: Int64): String`** — 按行读取，防止超长行攻击
- **`MultipartBoundary.expectLeadingCrlf(): Unit`** — 标记首个边界前需跳过前缀 CRLF
- **`MultipartBoundary.beforeFirstBoundary(): Bool`** — 判断是否尚未读到第一个边界
- **`MultipartBoundary.boundaryBytes: Array<Byte>`** — 当前有效边界字节序列（含/不含前缀 CRLF）
- **`MultipartBoundary.finalBoundaryLength: Int64`** — 终止边界的字节长度

### Changed

- **`RouteValueDictionary.fromArray()`** 现在过滤掉键为空字符串的条目（占位槽），
  适配 DFA 匹配器中 `(String.empty, "")` 占位符的语义

### Fixed

- **`IHeaderDictionary`** 中 `ContentLength` setter 误用 `HeaderNames.Accept` 的问题，已修正为 `HeaderNames.ContentLength`

### Added

- **`IValueProvider`** — 新增值提供者接口，提供 `get(name: String): ?String` 和
  `getAll(name: String): StringValues` 方法，被 `IQueryCollection` 和 `IFormCollection` 继承

- **`ApplicationBuilder.mapWhen(predicate:configuration:)`** — 条件分支中间件扩展函数，
  当 `predicate` 对 `HttpContext` 返回 `true` 时将请求转发到独立管道分支执行
- **`MapWhenMiddleware`** — 实现 `IMiddleware` 的条件分支中间件，
  根据 `MapWhenOptions.predicate` 结果决定走分支管道还是继续主管道
- **`MapWhenOptions`** — 条件分支配置载体，持有
  `predicate: (HttpContext) -> Bool` 和 `branch: RequestDelegate`

---

## v1.0.0

初始发布。
