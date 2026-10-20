# soulsoft.web.mvc

**基于 MVC 模式的仓颉 Web 应用程序开发框架，提供控制器、模型绑定、响应结果处理等核心能力。**
---

## 关于

`soulsoft.web.mvc` 是面向仓颉语言的 MVC Web 框架库，以 `Controller` 抽象类为核心，通过注解驱动路由映射和参数绑定，提供完整的请求处理管线。框架自动解析来自 Query String、路由参数、请求头、表单、请求体等多种数据源，支持基础类型、可空类型、数组、复杂对象等丰富绑定场景，同时内置 JSON/文本输入输出格式化器和多种 `IActionResult` 响应类型。

### 特性

| 特性 | 描述 |
|------|------|
| 🎮 **控制器基类** | `Controller` 提供 `ok`、`json`、`content`、`redirect`、`file`、`notFound` 等响应辅助方法 |
| 🗺️ **注解路由** | `@Route`、`@HttpGet`/`@HttpPost`/`@HttpPut`/`@HttpDelete` 等注解声明控制器路由和 HTTP 方法 |
| 🔗 **多源模型绑定** | `@FromQuery`、`@FromBody`、`@FromRoute`、`@FromHeader`、`@FromForm`、`@FromServices` 精确指定绑定源 |
| 🧩 **复合对象绑定** | `ComplexObjectModelBinder` 通过反射逐属性绑定，支持类继承层次 |
| 📦 **数组绑定** | `ArrayModelBinder<T>` 支持多值参数绑定为 `Array<T>` |
| 📅 **DateTime 绑定** | `DateTimeModelBinder` 解析日期时间字符串为 `DateTime` |
| 📤 **多种返回类型** | `ContentResult`、`JsonResult`、`ObjectResult`、`StatusCodeResult`、`RedirectResult`、`FileContentResult`、`FileStreamResult` |
| ⚙️ **可扩展格式化器** | `MvcOptions` 支持自定义 `IInputFormatter`/`IOutputFormatter` 和 `JsonSerializerOptions` |
| 🔌 **应用程序部件** | `ApplicationPartManager` 支持多包控制器发现，通过 `addApplicationPart` 按包名注册 |

---

## 如何使用

### 注册服务与启动

```cj
import soulsoft_web_mvc.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*

main(): Int64 {
    let builder = WebHost.createBuilder([])

    // 注册 MVC 服务，并按包名发现控制器
    builder.services.addControllers("my_app.controllers")

    // 可选：自定义 MvcOptions
    builder.services.configure<MvcOptions> {
        opts => opts.jsonSerializerOptions.nullable = JsonNullable.Disabled
    }

    let host = builder.build()
    host.useRouting()
    host.mapControllers()        // 映射所有属性路由控制器
    host.run("http://0.0.0.0:8080")
    return 0
}
```

传统路由模式（非属性路由）使用 `mapControllerRoute`：

```cj
host.mapControllerRoute(name: "default", pattern: "{controller}/{action}/{id?}")
```

### 定义控制器与动作

```cj
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

@Serialization
public class UserDto {
    private var _name: String = ""
    private var _age: Int64 = 0
}

@Route["api/users"]
public class UserController <: Controller {

    // GET /api/users/query?name=Alice&age=30
    @HttpGet["query"]
    public func getUser(@FromQuery user: UserDto): IActionResult {
        return ok<UserDto>(user)
    }

    // POST /api/users/body  (Body: {"name":"Bob","age":25})
    @HttpPost["body"]
    public func createUser(user: UserDto): IActionResult {
        return ok<UserDto>(user)
    }

    // GET /api/users/{id}
    @HttpGet["{id}"]
    public func getById(@FromRoute id: Int64): IActionResult {
        if (id <= 0) {
            return notFound()
        }
        return content("user-${id}", "text/plain")
    }
}
```

### 模型绑定注解

```cj
@Route["api/demo"]
public class DemoController <: Controller {

    // 从 Query String 绑定基础类型
    @HttpGet["search"]
    public func search(@FromQuery keyword: String, @FromQuery page: Int64): IActionResult {
        return content("keyword=${keyword}&page=${page}", "text/plain")
    }

    // 从请求头绑定
    @HttpGet["header"]
    public func getHeader(@FromHeader("X-Token") token: String): IActionResult {
        return content(token, "text/plain")
    }

    // 返回文件
    @HttpGet["download"]
    public func download(): IActionResult {
        let bytes: Array<Byte> = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        return file(bytes, "application/octet-stream", "hello.bin")
    }

    // 返回 JSON（直接序列化）
    @HttpGet["json"]
    public func getJson(): IActionResult {
        let dto = UserDto()
        dto.name = "Alice"
        dto.age = 30
        return json<UserDto>(dto)
    }
}
```

---

## API 参考

### Controller

| 方法 | 说明 |
|------|------|
| `ok(): StatusCodeResult` | 返回 200 OK |
| `ok<T>(value: T): ObjectResult<T>` | 返回 200 并序列化对象为 JSON |
| `json<T>(data: T): JsonResult<T>` | 返回 200，直接写 JSON 响应体 |
| `content(content: String): ContentResult` | 返回 200，`text/plain` |
| `content(content: String, contentType: String): ContentResult` | 返回 200，指定内容类型 |
| `noContent(): StatusCodeResult` | 返回 204 No Content |
| `notFound(): StatusCodeResult` | 返回 404 Not Found |
| `badRequest(): StatusCodeResult` | 返回 400 Bad Request |
| `unauthorized(): StatusCodeResult` | 返回 401 Unauthorized |
| `status(status: UInt16): StatusCodeResult` | 返回自定义状态码 |
| `redirect(url: String): RedirectResult` | 返回 302 并设置 Location 头 |
| `file(fileContents: Array<Byte>, contentType: String): FileContentResult` | 返回字节数组文件响应 |
| `file(fileContents: Array<Byte>, contentType: String, fileDownloadName: ?String): FileContentResult` | 返回带下载名的文件响应 |
| `file(fileStream: InputStream, contentType: String): FileStreamResult` | 返回流式文件响应 |
| `file(fileStream: InputStream, contentType: String, fileDownloadName: ?String): FileStreamResult` | 返回带下载名的流式文件响应 |

### 路由与 HTTP 方法注解

| 注解 | 目标 | 说明 |
|------|------|------|
| `@Route[template]` | 类型 | 设置控制器路由前缀 |
| `@HttpGet[template]` | 成员函数 | 映射 GET 请求 |
| `@HttpPost[template]` | 成员函数 | 映射 POST 请求 |
| `@HttpPut[template]` | 成员函数 | 映射 PUT 请求 |
| `@HttpDelete[template]` | 成员函数 | 映射 DELETE 请求 |
| `@HttpPatch[template]` | 成员函数 | 映射 PATCH 请求 |
| `@HttpHead[template]` | 成员函数 | 映射 HEAD 请求 |
| `@HttpOptions[template]` | 成员函数 | 映射 OPTIONS 请求 |

### 模型绑定注解

| 注解 | 目标 | 说明 |
|------|------|------|
| `@FromQuery` | 参数/成员变量 | 从 URL Query String 绑定 |
| `@FromBody` | 参数/成员变量 | 从请求体绑定（JSON） |
| `@FromRoute` | 参数/成员变量 | 从路由参数绑定 |
| `@FromHeader` | 参数/成员变量 | 从请求头绑定 |
| `@FromForm` | 参数/成员变量 | 从表单数据绑定 |
| `@FromServices` | 参数/成员变量 | 从依赖注入容器绑定 |

### MvcOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `inputFormatters` | `List<IInputFormatter>` | 输入格式化器列表 |
| `outputFormatters` | `List<IOutputFormatter>` | 输出格式化器列表 |
| `jsonSerializerOptions` | `JsonSerializerOptions` | JSON 序列化选项 |
| `modelBinders` | `ModelBinderCollection` | 自定义模型绑定器集合 |
| `returnHttpNotAcceptable` | `Bool` | Accept 头不匹配时返回 406 |
| `respectBrowserAcceptHeader` | `Bool` | 是否遵循浏览器 Accept 头 |

### MvcBuilder

| 方法 | 说明 |
|------|------|
| `addApplicationPart(qualifiedName: String): MvcBuilder` | 按包全限定名注册控制器发现包 |
| `addApplicationPart(packageInfo: PackageInfo): MvcBuilder` | 按 PackageInfo 注册 |
| `addMvcOptions(configureOptions: (MvcOptions) -> Unit): MvcBuilder` | 配置 MvcOptions |

### MvcServiceCollectionExtensions

| 方法 | 说明 |
|------|------|
| `addControllers(): MvcBuilder` | 注册 MVC 核心服务 |
| `addControllers(packageName: String): MvcBuilder` | 注册服务并添加指定包的控制器 |
| `addControllers(configureOptions: (MvcOptions) -> Unit): MvcBuilder` | 注册服务并配置选项 |

### ControllerEndpointRouteBuilderExtensions

| 方法 | 说明 |
|------|------|
| `mapControllers(): ControllerActionEndpointConventionBuilder` | 映射所有属性路由控制器 |
| `mapControllerRoute(name!: String, pattern!: String): ControllerActionEndpointConventionBuilder` | 添加传统路由规则 |

---

## 相关包

- `soulsoft_web_http` - HTTP 协议层，提供 `HttpContext`、`HttpRequest`、`HttpResponse`
- `soulsoft_web_routing` - 路由引擎，提供 `EndpointRouteBuilder`、路由匹配
- `soulsoft_serialization` - JSON 序列化/反序列化，提供 `@Serialization` 宏和 `JsonSerializer`
- `soulsoft_extensions_options` - 选项模式，提供 `IOptions<T>`、`IConfigureOptions<T>`
- `soulsoft_extensions_injection` - 依赖注入容器，提供 `ServiceCollection`、`IServiceProvider`

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 MVC 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
