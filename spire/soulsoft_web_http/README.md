# soulsoft.web.http

**Web HTTP 协议处理的核心抽象库，提供 HTTP 上下文、中间件管道、请求/响应、Cookie、会话及 Multipart 解析等基础组件。**
---

## 关于

`soulsoft.web.http` 是 Web HTTP 处理的基础抽象库，参照 ASP.NET Core 的设计模式，定义了 HTTP 请求/响应上下文（`HttpContext`）、中间件管道（`IMiddleware` + `ApplicationBuilder`）、URI 组件（`PathString`、`QueryString`、`HostString`）、Cookie 管理、会话（`Session`）以及 Multipart 解析（`MultipartReader`）等核心类型。作为底层基础库，它为上层具体的 Web 框架实现提供统一的抽象接口，而不直接用于应用程序。

### 特性

| 特性 | 描述 |
|------|------|
| 🌐 **HTTP 上下文** | `HttpContext` 统一封装请求、响应、用户、会话和特性集合，通过 `IFeatureCollection` 可扩展运行时特性 |
| 🔗 **中间件管道** | `ApplicationBuilder` 支持多种形式注册中间件（Lambda / `IMiddleware` / 泛型类型），`build()` 生成 `RequestDelegate` 调用链 |
| 📍 **URI 组件** | `PathString`、`QueryString`、`HostString` 支持 URI 编解码、段匹配、主机端口解析 |
| 🍪 **Cookie 管理** | `CookieBuilder` / `CookieOptions` 构建 Cookie，`IResponseCookies` / `IRequestCookieCollection` 读写请求/响应 Cookie |
| 📋 **HTTP 头字典** | `IHeaderDictionary` 提供 70+ 标准 HTTP 头强类型属性及通用键值操作，`HeaderNames` 提供头名称常量 |
| 📦 **Multipart 解析** | `MultipartReader` 流式读取 Multipart 数据，支持限制头部大小和节体长度，`BufferedReadStream` 提供缓冲读取支持 |
| 🏷️ **媒体类型解析** | `MediaTypeHeaderValue` 解析 Content-Type，支持子类型匹配、`isSubsetOf`、quality 参数 |
| 🔢 **HTTP 常量** | `StatusCodes` 涵盖 1xx–5xx 全部标准状态码，`HttpMethods` 提供方法常量与大小写不敏感比较工具 |
| 🔐 **授权元数据** | `IAuthorizeData`、`IAllowAnonymous`、`ICorsMetadata` 为授权与 CORS 提供元数据标记接口 |
| ✅ **验证问题详情** | `ValidationProblemDetails` 实现 RFC 7807 格式，支持序列化/反序列化 |

---

## 如何使用

### 中间件管道

```cj
import soulsoft_web_http.*
import soulsoft_extensions_injection.*

// 构建中间件管道
let builder = ApplicationBuilder(services)

// Lambda 形式注册（简化版）
builder.use { ctx, next =>
    // 前置处理
    next()
    // 后置处理
}

// IMiddleware 实例注册
builder.use(MyLoggingMiddleware())

// 泛型类型注册（从 DI 容器解析依赖）
builder.use<MyAuthMiddleware>([])

// 生成请求处理委托
let pipeline: RequestDelegate = builder.build()
```

### URI 组件操作

```cj
import soulsoft_web_http.*

// PathString：路径匹配与编解码
let path = PathString("/api/users")
let decoded = PathString.fromUriComponent("/hello%20world")
let encoded = path.toUriComponent()

if (let Some(remaining) <- path.startsWithSegments(PathString("/api"))) {
    // remaining 为 /users
}

// QueryString：查询字符串构建
let qs = QueryString.create("page", "1")
let qs2 = QueryString.create([("page", "1"), ("size", "20")])
let url = path + qs2  // "/api/users?page=1&size=20"

// HostString：主机解析
let host = HostString("example.com:8080")
let hostname = host.host        // "example.com"
let port = host.port            // Some(8080)

// URL 编解码
let encoded2 = HttpUtility.urlEncode("hello world & foo=bar")
let decoded2 = HttpUtility.urlDecode("hello%20world%20%26%20foo%3Dbar")
```

### Cookie 管理

```cj
import soulsoft_web_http.*

// 构建 Cookie 选项
let opts = CookieOptions(
    domain: Some("example.com"),
    path: Some("/"),
    secure: true,
    httpOnly: true,
    sameSite: CookieSameSiteMode.Lax
)

// 生成 Set-Cookie 头值
let header = opts.createCookieHeaderValue("sessionId", Some("abc123"))

// 写入响应 Cookie
context.response.cookies.append("token", "my-token", opts)
context.response.cookies.delete("old-token")

// 读取请求 Cookie
if (let Some(val) <- context.request.cookies.get("sessionId")) {
    // 使用 val
}
```

### Multipart 解析

```cj
import soulsoft_web_http.*

// 从请求体解析 Multipart
let boundary = "----WebKitFormBoundary"
let reader = MultipartReader(boundary, context.request.body)
reader.headersLengthLimit = 16 * 1024       // 16KB 头部限制
reader.bodyLengthLimit = Some(10 * 1024 * 1024)  // 10MB 节体限制

while (let Some(section) <- reader.readNextSection()) {
    let contentType = section.contentType
    let contentDisp = section.contentDisposition

    // 流式读取节体
    let buf = Array<Byte>(4096, repeat: 0)
    let n = section.body.read(buf)
}
```

### 媒体类型解析

```cj
import soulsoft_web_http.*

// 解析 Content-Type
match (MediaTypeHeaderValue.parse("application/json; charset=utf-8")) {
    case Some(media) =>
        let type_ = media.type_     // "application"
        let sub = media.subType     // "json"
        let cs = media.charset      // "utf-8"
        if (media.matchesMediaType("application/json")) {
            // 处理 JSON
        }
    case None => {}
}

// 构建带参数的媒体类型
let mt = MediaTypeHeaderValue("multipart/form-data")
mt.boundary = "----WebKitFormBoundary"
mt.quality = Some(0.9)
```

---

## API 参考

### HttpContext

| 属性 | 类型 | 说明 |
|------|------|------|
| `request` | `HttpRequest` | 当前 HTTP 请求 |
| `response` | `HttpResponse` | 当前 HTTP 响应 |
| `user` | `ClaimsPrincipal` | 当前认证用户（可变） |
| `services` | `IServiceProvider` | 请求级 DI 容器 |
| `features` | `IFeatureCollection` | 运行时特性集合 |
| `session` | `Session` | 会话对象（从 `ISessionFeature` 获取） |
| `items` | `Map<String, Any>` | 请求范围内的共享数据 |

### HttpRequest

| 属性/方法 | 类型 | 说明 |
|-----------|------|------|
| `method` | `String` | HTTP 方法（GET/POST 等） |
| `scheme` | `String` | 请求协议（http/https） |
| `host` | `HostString` | 主机名和端口 |
| `path` | `PathString` | 请求路径 |
| `queryString` | `QueryString` | 原始查询字符串 |
| `query` | `IQueryCollection` | 解析后的查询参数 |
| `headers` | `IHeaderDictionary` | 请求头 |
| `cookies` | `IRequestCookieCollection` | 请求 Cookie |
| `form` | `IFormCollection` | 表单数据（含上传文件） |
| `body` | `InputStream` | 请求体流 |
| `contentType` | `?String` | 内容类型 |
| `contentLength` | `?Int64` | 内容长度 |
| `routeValues` | `RouteValueDictionary` | 路由参数 |
| `readForm(): IFormCollection` | — | 读取并解析表单数据 |
| `getDisplayUrl(): String` | — | 获取完整显示 URL |
| `enableBuffering(): Unit` | — | 启用请求体缓冲（支持多次读取） |

### HttpResponse

| 属性/方法 | 类型 | 说明 |
|-----------|------|------|
| `statusCode` | `UInt16` | HTTP 状态码（可变） |
| `contentType` | `?String` | 响应内容类型（可变） |
| `contentLength` | `?Int64` | 响应内容长度（可变） |
| `headers` | `IHeaderDictionary` | 响应头 |
| `cookies` | `IResponseCookies` | 响应 Cookie 操作 |
| `write(text: String): Unit` | — | 写入文本响应体 |
| `write(bytes: Array<Byte>): Unit` | — | 写入字节响应体 |
| `write(stream: InputStream): Unit` | — | 写入流响应体 |
| `redirect(location: String): Unit` | — | 302 重定向 |
| `writeAsJson<T>(data: T): Unit` | — | 序列化为 JSON 并写入响应 |

### ApplicationBuilder

| 方法 | 说明 |
|------|------|
| `use(middleware: (RequestDelegate) -> RequestDelegate): This` | 注册标准中间件工厂 |
| `use(middleware: (HttpContext, () -> Unit) -> Unit): This` | 注册简化 Lambda 中间件 |
| `use(middleware: (HttpContext, RequestDelegate) -> Unit): This` | 注册带 next 的 Lambda 中间件 |
| `use(middleware: IMiddleware): This` | 注册 `IMiddleware` 实例 |
| `use<TMiddleware>(args: Array<Any>): This` | 从 DI 解析并注册泛型中间件 |
| `new(): ApplicationBuilder` | 创建分支管道构建器 |
| `build(): RequestDelegate` | 构建最终请求处理委托 |

### IHeaderDictionary

| 方法 | 说明 |
|------|------|
| `operator func [](name: String): StringValues` | 获取头值列表 |
| `operator func [](name: String, value!: StringValues): Unit` | 设置头值 |
| `add(name: String, values: StringValues): Unit` | 添加头 |
| `remove(name: String): Unit` | 删除头 |
| `contains(name: String): Bool` | 判断头是否存在 |
| `getCommaSeparatedValues(name: String): StringValues` | 获取逗号分隔的头值 |
| `contentLength` / `contentType` / `accept` / ... | 70+ 标准 HTTP 头强类型属性（可变） |

### PathString

| 方法 | 说明 |
|------|------|
| `init(value: String)` | 构造路径字符串 |
| `toUriComponent(): String` | 编码为 URI 组件 |
| `static fromUriComponent(uriComponent: String): PathString` | 从 URI 组件解码 |
| `startsWithSegments(that: PathString): ?PathString` | 路径段前缀匹配，返回剩余路径或 `None` |
| `operator func +(other: PathString): PathString` | 拼接路径 |
| `operator func +(other: QueryString): String` | 路径加查询字符串 |

### QueryString

| 方法 | 说明 |
|------|------|
| `static create(name: String, value: String): QueryString` | 创建单参数查询字符串 |
| `static create(parameters: Collection<(String, String)>): QueryString` | 从参数集合创建 |
| `toUriComponent(): String` | 编码为 URI 组件 |
| `add(other: QueryString): QueryString` | 合并两个查询字符串 |
| `add(name: String, value: String): QueryString` | 追加单个参数 |

### HostString

| 方法/属性 | 说明 |
|-----------|------|
| `init(value: String)` | 从 `host` 或 `host:port` 格式构造 |
| `init(host: String, port: Int64)` | 从主机名和端口构造 |
| `host: String` | 主机名 |
| `port: ?Int64` | 端口，无端口时为 `None` |
| `toUriComponent(): String` | 编码为 URI 组件 |
| `static matchesAny(value: String, patterns: Collection<String>): Bool` | 通配符匹配主机名列表 |

### MultipartReader

| 成员 | 说明 |
|------|------|
| `init(boundary: String, stream: InputStream)` | 构造 Multipart 读取器 |
| `readNextSection(): ?MultipartSection` | 读取下一个节，无更多节返回 `None` |
| `headersLengthLimit: Int64` | 节头部总长度限制，默认 16KB |
| `headersCountLimit: Int64` | 节头部条目数限制，默认 16 |
| `bodyLengthLimit: ?Int64` | 节体长度限制，`None` 表示不限制 |

### CookieOptions

| 属性/方法 | 类型 | 说明 |
|-----------|------|------|
| `domain` | `?String` | Cookie 域 |
| `path` | `?String` | Cookie 路径 |
| `expires` | `?DateTime` | 绝对过期时间 |
| `secure` | `Bool` | 是否仅 HTTPS 传输 |
| `httpOnly` | `Bool` | 是否禁止 JS 访问 |
| `sameSite` | `CookieSameSiteMode` | SameSite 策略（Unspecified / None / Lax / Strict） |
| `maxAge` | `?Duration` | Max-Age 有效期 |
| `createCookieHeaderValue(name: String, value: ?String): String` | — | 生成 Set-Cookie 头值 |

### StatusCodes

常用状态码常量（类型均为 `UInt16`）：

| 常量 | 值 | 常量 | 值 |
|------|----|------|----|
| `Ok` | 200 | `BadRequest` | 400 |
| `Created` | 201 | `Unauthorized` | 401 |
| `NoContent` | 204 | `Forbidden` | 403 |
| `MovedPermanently` | 301 | `NotFound` | 404 |
| `Found` | 302 | `UnprocessableEntity` | 422 |
| `NotModified` | 304 | `TooManyRequests` | 429 |
| `PermanentRedirect` | 308 | `InternalServerError` | 500 |

### HttpMethods

| 方法 | 说明 |
|------|------|
| `HttpMethods.Get` / `Post` / `Put` / `Delete` / ... | HTTP 方法字符串常量 |
| `isGet(method: String): Bool` | 判断是否为 GET（大小写不敏感） |
| `equals(methodA: String, methodB: String): Bool` | 大小写不敏感比较两个方法名 |
| `getCanonicalizedValue(method: String): String` | 获取规范化方法名 |

---

## 相关包

- `soulsoft_serialization` — JSON 序列化/反序列化，用于 `writeAsJson` 和 `ValidationProblemDetails`
- `soulsoft_identity_claims` — 用户身份声明（`ClaimsPrincipal`），用于 `HttpContext.user`
- `soulsoft_extensions_injection` — 依赖注入容器（`IServiceProvider`），用于中间件和服务解析

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 `Microsoft.AspNetCore.Http` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
