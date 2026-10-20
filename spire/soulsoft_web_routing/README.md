# soulsoft.web.routing

**基于 DFA 的高性能 Web 路由库，提供 URL 模式解析、端点匹配与路由分组能力。**
---

## 关于

soulsoft.web.routing 是仓颉 Web 框架的路由核心库，通过 DFA（确定有限自动机）匹配器实现高效的 URL 模式匹配，将 HTTP 请求分发到对应的处理委托。核心入口类 `EndpointRouteBuilder` 提供 `mapGet` / `mapPost` 等 HTTP 方法级路由注册，`RouteGroupBuilder` 支持带前缀的路由分组与嵌套，`RoutePatternFactory` 负责路由模式的解析与构建，内置 `int` / `bool` / `float` / 正则等参数约束。

### 特性

| 特性 | 描述 |
|------|------|
| 🚀 **DFA 路由匹配** | 基于确定有限自动机（`DfaMatcher`）实现 O(n) 路径匹配，支持静态路径、参数段、捕获全部段 |
| 🗂️ **路由分组** | `mapGroup(prefix)` 创建 `RouteGroupBuilder`，支持无限级嵌套，前缀由 `GroupEndpointDataSource` 递归合并 |
| 🔒 **参数约束** | 内置 `IntRouteConstraint`、`BoolRouteConstraint`、`FloatRouteConstraint`、`RegexRouteConstraint`；可实现 `IRouteConstraint` 自定义约束 |
| 🏷️ **分组约定** | `RouteGroupBuilder.add(convention)` 为组内全部端点批量注入元数据，约定按外→内→条目顺序执行 |
| 🔗 **模式解析** | `RoutePatternFactory.parse` 支持字面量、`{param}`、`{param?}`、`{*catchAll}`、`{**catchAll}` 及内联默认值与约束语法 |
| 🔀 **模式合并** | `RoutePatternFactory.combine` 合并两段路由模式，自动检测重复参数和冲突 defaults |
| 🌐 **HTTP 方法策略** | `HttpMethodMatcherPolicy` 实现请求方法级多路复用，同路径不同方法可注册到独立端点 |
| 🔌 **中间件集成** | `useRouting()` + `useEndpoints()` 两段式中间件管线；`ServiceCollection.addRouting()` 完成 DI 注册 |

---

## 如何使用

### 基本路由注册

注册路由服务并映射 HTTP 方法端点：

```cj
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_extensions_injection.*

main(): Int64 {
    let builder = WebHost.createBuilder([])
    // 注册路由所需的 DI 服务
    builder.services.addRouting()

    let app = builder.build()
    app.useRouting()

    // 注册各 HTTP 方法端点
    app.mapGet("/hello") { ctx =>
        ctx.response.write("Hello, World!")
    }

    app.mapPost("/users") { ctx =>
        ctx.response.statusCode = 201
        ctx.response.write("created")
    }

    // 带路由参数：{id} 为标准参数，{id:int} 带 int 约束
    app.mapGet("/users/{id:int}") { ctx =>
        let id = ctx.getRouteValue("id") ?? "unknown"
        ctx.response.write("User: ${id}")
    }

    // 正则约束：{slug:regex(^[a-z0-9-]+$)} 只匹配小写字母、数字和连字符
    app.mapGet("/articles/{slug:regex(^[a-z0-9-]+$)}") { ctx =>
        let slug = ctx.getRouteValue("slug") ?? ""
        ctx.response.write("Article: ${slug}")
    }

    // 可选参数与 catch-all
    app.mapGet("/docs/{*path}") { ctx =>
        let path = ctx.getRouteValue("path") ?? ""
        ctx.response.write("Doc: ${path}")
    }

    app.run("http://0.0.0.0:5000")
    return 0
}
```

### 路由分组

使用 `mapGroup` 创建共享前缀的路由组，支持嵌套和分组约定：

```cj
import soulsoft_web_routing.*
import soulsoft_web_http.*

func setupRoutes(app: EndpointRouteBuilder): Unit {
    // 基础分组：组内路由自动获得 /api 前缀
    let api = app.mapGroup("/api")
    api.mapGet("/items") { ctx => ctx.response.write("list") }
    api.mapPost("/items") { ctx => ctx.response.write("create") }
    api.mapGet("/items/{id}") { ctx => ctx.response.write("detail") }

    // 嵌套分组：/api/v1/users/{id}
    let v1 = app.mapGroup("/api/v1")
    let users = v1.mapGroup("/users")
    users.mapGet("/{id}") { ctx => ctx.response.write("user") }

    // 链式嵌套写法
    app.mapGroup("/a").mapGroup("/b").mapGet("/c") { ctx =>
        ctx.response.write("path: /a/b/c")
    }

    // 分组约定：为组内所有端点批量注入元数据
    let admin = app.mapGroup("/admin")
    admin.add { b =>
        b.metadata.add("requires-auth")
    }
    admin.mapGet("/dashboard") { ctx => ctx.response.write("dashboard") }
    admin.mapPost("/users") { ctx => ctx.response.write("create user") }
}
```

### 路由模式操作

直接使用 `RoutePatternFactory` 解析和构建路由模式：

```cj
import soulsoft_web_routing.patterns.*
import soulsoft_web_http.*

// 解析模式字符串
let pattern = RoutePatternFactory.parse("api/{controller}/{id:int}")
// pattern.parameters[0].name == "controller"
// pattern.parameters[1].parameterPolicies.size == 1

// 带内联默认值
let p2 = RoutePatternFactory.parse("{controller=Home}/{action=Index}")
// p2.defaults.get("controller") == Some(Some("Home"))

// 可选参数
let p3 = RoutePatternFactory.parse("{id?}")
// p3.parameters[0].isOptional == true

// 捕获全部段
let p4 = RoutePatternFactory.parse("{*rest}")
// p4.parameters[0].isCatchAll == true

// 合并两段模式（用于分组前缀合并）
let left = RoutePatternFactory.parse("api/v1")
let right = RoutePatternFactory.parse("{id}")
let combined = RoutePatternFactory.combine(left, right)
// combined.rawText == "api/v1/{id}"

// 使用 RoutePatternMatcher 直接匹配路径
let values = RouteValueDictionary()
let matcher = RoutePatternMatcher(pattern, None)
if (matcher.tryMatch(PathString("/api/users/42"), values)) {
    let id = values.get("id") // Some("42")
}
```

---

## API 参考

### RoutingServiceCollectionExtension

| 方法 | 说明 |
|------|------|
| `addRouting(): Unit` | 注册路由所需的全部 DI 服务（`MatcherFactory`、`EndpointSelector` 等） |
| `addRouting(configureOptions: (RouteOptions) -> Unit): Unit` | 注册路由服务并自定义 `RouteOptions` |

### EndpointRoutingApplicationBuilderExtensions

| 方法 | 说明 |
|------|------|
| `useRouting(): Unit` | 向中间件管线添加 `EndpointRoutingMiddleware`，执行路由匹配 |
| `useEndpoints(configure: (EndpointRouteBuilder) -> Unit): Unit` | 向中间件管线添加 `EndpointMiddleware` 并执行端点配置回调 |

### EndpointRouteBuilder

| 方法 | 说明 |
|------|------|
| `mapGet(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册 GET 端点 |
| `mapPost(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册 POST 端点 |
| `mapPut(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册 PUT 端点 |
| `mapPatch(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册 PATCH 端点 |
| `mapDelete(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册 DELETE 端点 |
| `map(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder` | 注册不限方法的端点 |
| `mapGroup(prefix: String): RouteGroupBuilder` | 创建路由分组，组内端点自动附加前缀 |
| `mapGroup(prefix: RoutePattern): RouteGroupBuilder` | 创建路由分组（`RoutePattern` 重载） |
| `dataSources: List<EndpointDataSource>` | 已注册的端点数据源列表 |

### RouteGroupBuilder

继承 `EndpointRouteBuilder` 的全部路由注册方法，另增：

| 方法 / 属性 | 说明 |
|------|------|
| `add(convention: (EndpointBuilder) -> Unit): Unit` | 为本组所有端点添加约定，约定在端点构建时应用 |
| `partialPrefix: RoutePattern` | 本组路由前缀（部分前缀，嵌套时由 `GroupEndpointDataSource` 递归合并） |
| `groupConventions: ArrayList<(EndpointBuilder) -> Unit>` | 已注册的分组约定列表 |

### RoutePatternFactory

| 方法 | 说明 |
|------|------|
| `parse(rawText: String): RoutePattern` | 解析路由模式字符串 |
| `parse(rawText: String, requiredValues: RouteValueDictionary): RoutePattern` | 解析并附加 required values |
| `parse(rawText: String, defaults: ?RouteValueDictionary, parameterPolicies: ?RouteValueDictionary): RoutePattern` | 解析并附加显式 defaults 和参数策略 |
| `combine(left: ?RoutePattern, right: RoutePattern): RoutePattern` | 合并两段路由模式，`left` 为 `None` 时直接返回 `right` |
| `literalPart(content: String): RoutePatternLiteralPart` | 创建字面量部分，内容不得含 `?` |
| `separatorPart(content: String): RoutePatternSeparatorPart` | 创建分隔符部分 |
| `parameterPart(parameterName: String): RoutePatternParameterPart` | 创建标准参数部分 |
| `parameterPart(parameterName: String, default: ?String, parameterKind: RoutePatternParameterKind, parameterPolicies: Array<RoutePatternParameterPolicyReference>): RoutePatternParameterPart` | 创建带完整选项的参数部分 |
| `constraint(content: String): RoutePatternParameterPolicyReference` | 从字符串创建约束引用 |
| `constraint(constraint: IRouteConstraint): RoutePatternParameterPolicyReference` | 从约束实例创建引用 |
| `segment(parts: Array<RoutePatternPart>): RoutePatternPathSegment` | 从 Part 数组创建路径段 |

### RoutePattern

| 属性 | 类型 | 说明 |
|------|------|------|
| `rawText` | `String` | 原始路由字符串 |
| `parameters` | `ReadOnlyList<RoutePatternParameterPart>` | 参数部分列表 |
| `pathSegments` | `ReadOnlyList<RoutePatternPathSegment>` | 路径段列表 |
| `defaults` | `ReadOnlyMap<String, ?String>` | 默认值映射（含内联默认值） |
| `parameterPolicies` | `ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>` | 参数约束引用映射 |
| `requiredValues` | `ReadOnlyMap<String, ?String>` | Required values 映射 |
| `inboundPrecedence` | `Decimal` | 入站优先级，数值越小优先级越高 |
| `outboundPrecedence` | `Decimal` | 出站优先级，数值越大优先级越高 |
| `getParameter(name: String): ?RoutePatternParameterPart` | 按名称查找参数，不存在返回 `None` |
| `static requiredValueAny: String` | 标记"任意非空值均可匹配"的哨兵字符串 |
| `static isRequiredValueAny(value: ?String): Bool` | 判断是否为 `requiredValueAny` 哨兵 |

### IRouteConstraint

| 方法 | 说明 |
|------|------|
| `isMatch(context: ?HttpContext, routeKey: String, values: RouteValueDictionary): Bool` | 判断路由值是否满足约束 |

内置实现：`IntRouteConstraint`、`BoolRouteConstraint`、`FloatRouteConstraint`、`RegexRouteConstraint`。

### EndpointHttpContextExtensions

扩展 `HttpContext` 的端点访问方法：

| 方法 | 说明 |
|------|------|
| `getEndpoint(): ?Endpoint` | 获取当前请求匹配的端点，未匹配返回 `None` |
| `setEndpoint(endpoint: Endpoint): Unit` | 设置当前请求的端点 |

### RouteOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `endpointDataSources` | `HashSet<EndpointDataSource>` | 已注册的端点数据源集合，由 `useEndpoints` 写入 |

---

## 相关包

- `soulsoft_web_http` - HTTP 上下文、请求/响应抽象及中间件管线基础设施
- `soulsoft_extensions_options` - `IOptions<T>` 选项模式，用于 `RouteOptions` 的 DI 注入
- `soulsoft_extensions_injection` - 依赖注入容器，提供服务注册与解析能力

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 Routing 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
