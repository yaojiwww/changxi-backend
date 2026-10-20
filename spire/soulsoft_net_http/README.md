# soulsoft.net.http

**仓颉语言 HTTP 客户端库，提供完整的 HTTP 请求/响应处理能力，覆盖多种内容类型与灵活的处理器管道。**
---

## 关于

`soulsoft.net.http` 是一个面向仓颉语言的 HTTP 客户端库，核心类 `HttpClient` 封装了完整的请求发送与响应读取流程，支持 GET、POST、PUT、DELETE 等标准方法，以及字符串、JSON、表单、Multipart 等多种请求体格式。库通过 `DelegatingHandler` 抽象实现可组合的处理器管道，支持在请求/响应路径上插入自定义中间件（如日志、重试、鉴权）。

### 特性

| 特性 | 描述 |
|------|------|
| 🌐 **多 HTTP 方法** | 内置 `get`、`post`、`put`、`delete` 快捷方法，并支持通过 `send(HttpRequestMessage)` 发送任意方法 |
| 📦 **丰富内容类型** | 提供 `StringContent`、`JsonContent`、`ByteArrayContent`、`FormUrlContent`、`MultipartFormDataContent` |
| 🔗 **处理器管道** | `DelegatingHandler` 支持链式组合，可在请求前后注入自定义逻辑 |
| 🏠 **基础地址** | `baseAddress` 属性支持相对路径解析，统一管理服务根地址 |
| 🔒 **TLS 支持** | `HttpClientHandler` 内置 TLS 配置，支持系统根证书与自定义证书策略 |
| 📖 **多格式响应读取** | `HttpContent` 支持 `readAsString`、`readAsByteArray`、`readAsStream`、`readFromJson<T>` |
| 📋 **头部管理** | `HttpHeadersBase` 提供统一的请求/响应/内容头部增删查接口 |
| 🔢 **状态码枚举** | `HttpStatusCode` 枚举覆盖 RFC 2616 全部状态码，支持与 `Int64` 互转 |

---

## 如何使用

### 基本 GET/POST 请求

```cj
import soulsoft_net_http.*

// 创建客户端（用完后需关闭）
let client = HttpClient()

// GET 并读取响应体
let text = client.getString("https://api.example.com/ping")

// GET 并获取响应对象（使用 try-with-resource 自动关闭）
try (response = client.get("https://api.example.com/data")) {
    if (response.isSuccessStatusCode) {
        let body = response.content.readAsString()
        println(body)
    }
}

// GET 二进制内容
let bytes = client.getByteArray("https://api.example.com/file")

// POST JSON 字符串
try (response = client.post(
    "https://api.example.com/submit",
    JsonContent.create("{\"key\":\"value\"}")
)) {
    response.ensureSuccessStatusCode()
}

client.close()
```

### 请求体类型

```cj
import soulsoft_net_http.*

let client = HttpClient()

// 表单提交（application/x-www-form-urlencoded）
let form = FormUrlContent([("username", "alice"), ("password", "secret")])
try (r = client.post("https://api.example.com/login", form)) {
    println(r.statusCode)
}

// 文本内容（自定义 Content-Type）
let xml = StringContent("<root/>", "text/xml")
try (r = client.post("https://api.example.com/xml", xml)) {
    r.ensureSuccessStatusCode()
}

// 原始字节
let raw = ByteArrayContent([0x01u8, 0x02u8, 0x03u8])
raw.headers.add("Content-Type", "application/octet-stream")
try (r = client.post("https://api.example.com/binary", raw)) {
    r.ensureSuccessStatusCode()
}

client.close()
```

### 文件上传

```cj
import soulsoft_net_http.*

let client = HttpClient()

// 构建 multipart/form-data
let fileData = ByteArrayContent("file contents here".toArray())
fileData.headers.add("Content-Type", "text/plain")

let form = MultipartFormDataContent()
form.add(fileData, "file", "report.txt")    // 字段名 + 文件名

try (response = client.post("https://api.example.com/upload", form)) {
    response.ensureSuccessStatusCode()
    println(response.content.readAsString())
}

client.close()
```

### 请求头与基础地址

```cj
import soulsoft_net_http.*
import stdx.encoding.url.*

// 设置基础地址（首次请求前设置）
let client = HttpClient()
client.baseAddress = URL.parse("https://api.example.com")

// 设置默认请求头（随每个请求发送）
client.defaultRequestHeaders.add("Authorization", "Bearer token123")
client.defaultRequestHeaders.add("Accept", "application/json")

// 使用相对路径（基于 baseAddress 解析）
try (response = client.get("/users/1")) {
    let ct = response.headers.getFirst("Content-Type") ?? ""
    println("Content-Type: ${ct}")
}

client.close()
```

### 自定义处理器管道

```cj
import soulsoft_net_http.*

// 继承 DelegatingHandler 实现中间件
class LoggingHandler <: DelegatingHandler {
    public init(inner: HttpMessageHandler) {
        super(inner)
    }

    protected override func send(request: HttpRequestMessage): HttpResponseMessage {
        println("→ ${request.method} ${request.requestUri}")
        let response = super.send(request)
        println("← ${response.statusCode}")
        return response
    }
}

// 组装管道：LoggingHandler → HttpClientHandler
let inner = HttpClientHandler()
let logging = LoggingHandler(inner)
let client = HttpClient(logging)

let body = client.getString("https://api.example.com/ping")
client.close()
```

---

## API 参考

### HttpClient

| 方法/属性 | 说明 |
|-----------|------|
| `init()` | 使用默认 `HttpClientHandler` 创建客户端 |
| `init(handler: HttpMessageHandler)` | 使用自定义处理器创建客户端 |
| `static create(configure: (ClientBuilder) -> Unit): HttpClient` | 通过构建器配置底层连接后创建客户端 |
| `mut prop baseAddress: ?URL` | 基础地址，用于解析相对路径请求 URI |
| `prop defaultRequestHeaders: HttpRequestHeaders` | 默认请求头，随每个请求自动附加（已存在同名头则跳过） |
| `get(requestUri: String): HttpResponseMessage` | 发送 GET 请求 |
| `getString(requestUri: String): String` | 发送 GET 请求并返回响应体字符串，非 2xx 抛出异常 |
| `getByteArray(requestUri: String): Array<Byte>` | 发送 GET 请求并返回字节数组，非 2xx 抛出异常 |
| `getStream(requestUri: String): InputStream` | 发送 GET 请求并返回响应体流，非 2xx 抛出异常 |
| `post(requestUri: String, content: ?HttpContent): HttpResponseMessage` | 发送 POST 请求 |
| `put(requestUri: String, content: ?HttpContent): HttpResponseMessage` | 发送 PUT 请求 |
| `delete(requestUri: String, content: ?HttpContent): HttpResponseMessage` | 发送 DELETE 请求 |
| `send(request: HttpRequestMessage): HttpResponseMessage` | 发送自定义请求 |

### HttpRequestMessage

| 属性 | 类型 | 说明 |
|------|------|------|
| `prop method: HttpMethod` | `HttpMethod` | 请求方法 |
| `mut prop requestUri: URL` | `URL` | 请求地址 |
| `prop headers: HttpRequestHeaders` | `HttpRequestHeaders` | 请求头集合 |
| `var content: ?HttpContent` | `?HttpContent` | 请求体，可为 `None` |
| `prop properties: HashMap<String, Any>` | `HashMap<String, Any>` | 自定义附加属性 |

### HttpResponseMessage

| 方法/属性 | 说明 |
|-----------|------|
| `prop statusCode: Int64` | HTTP 状态码（如 200、404） |
| `prop isSuccessStatusCode: Bool` | 状态码在 200~299 范围内返回 `true` |
| `func ensureSuccessStatusCode(): Unit` | 非 2xx 时抛出 `HttpRequestException` |
| `prop headers: HttpResponseHeaders` | 响应头集合 |
| `mut prop content: HttpContent` | 响应体内容 |
| `prop request: HttpRequestMessage` | 对应的请求对象 |

### HttpContent（抽象类）

| 方法 | 说明 |
|------|------|
| `func readAsString(): String` | 读取全部内容为字符串 |
| `func readAsByteArray(): Array<Byte>` | 读取全部内容为字节数组 |
| `func readAsStream(): InputStream` | 获取内容输入流 |
| `func readFromJson<T>(): T` | 反序列化 JSON 响应体（`T` 需实现 `ISerialization<T>`） |
| `func loadIntoBuffer(): Unit` | 将内容预加载到内存缓冲区 |
| `prop headers: HttpContentHeaders` | 内容相关头部（如 `Content-Type`） |

### 内容类型子类

| 类 | 构造签名 | Content-Type |
|----|---------|--------------|
| `ByteArrayContent` | `init(bytes: Array<Byte>)` | 无（需手动设置） |
| `StringContent` | `init(content: String)` / `init(content: String, mediaType: String)` | `text/plain; charset=utf-8` |
| `JsonContent` | `static create(json: String): JsonContent` / `static create<T>(data: T): JsonContent` | `application/json; charset=utf-8` |
| `FormUrlContent` | `init(values: Collection<(String, String)>)` | `application/x-www-form-urlencoded` |
| `MultipartFormDataContent` | `init()` / `init(boundary: String)` | `multipart/form-data; boundary=...` |

### MultipartFormDataContent

| 方法 | 说明 |
|------|------|
| `add(content: HttpContent): Unit` | 添加无名称的内容部分 |
| `add(content: HttpContent, name: String): Unit` | 添加具名字段 |
| `add(content: HttpContent, name: String, fileName: String): Unit` | 添加具名字段并指定文件名 |

### HttpHeadersBase

| 方法 | 说明 |
|------|------|
| `add(name: String, value: String): Unit` | 追加头部值（多值头） |
| `set(name: String, value: String): Unit` | 设置头部值（覆盖已有值） |
| `get(name: String): ?Collection<String>` | 获取全部值，不存在返回 `None` |
| `getFirst(name: String): ?String` | 获取第一个值，不存在返回 `None` |
| `contains(name: String): Bool` | 是否包含指定头部 |
| `remove(name: String): Unit` | 删除指定头部 |
| `tryAddWithoutValidation(name: String, value: String): Bool` | 绕过类型校验直接写入 |

### HttpMethod

预定义常量：`Get`、`Post`、`Put`、`Delete`、`Patch`、`Head`、`Options`、`Trace`、`Connect`。支持 `==` 比较与 `toString()`。

### DelegatingHandler

继承此类实现自定义中间件，通过 `super.send(request)` 委托到内部处理器。

---

## 相关包

- `soulsoft_serialization` — JSON 序列化/反序列化支持，`JsonContent.create<T>` 和 `HttpContent.readFromJson<T>` 依赖此包

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime) 中的 `System.Net.Http` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
