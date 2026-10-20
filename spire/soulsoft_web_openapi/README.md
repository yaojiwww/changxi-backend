# soulsoft.web.openapi

**用于处理 OpenAPI 规范和支持 API 文档生成的库，仅支持 OpenAPI 3.0.3 规范。**
---

## 关于

soulsoft_web_openapi 是一个仓颉语言的 OpenAPI 3.0.3 文档生成库，能够自动从 MVC 控制器和路由终结点生成完整的 API 规范文档。它深度集成 soulsoft_web_mvc 框架，支持通过注解和元数据自定义 API 文档的各个层面。

核心实现基于反射扫描控制器类型，自动推断请求参数、响应类型和 Schema 结构，生成符合 OpenAPI 3.0.3 规范的 JSON 文档。

### 特性

| 特性 | 描述 |
|------|------|
| 📝 **自动文档生成** | 从 MVC 控制器自动提取路由、参数、响应类型生成 OpenAPI 文档 |
| 🔍 **Schema 推断** | 支持基本类型、数组、Map、泛型、嵌套对象等多种类型的 Schema 生成 |
| 🏷️ **注解支持** | 通过 `@OpenApi` 注解自定义 API 名称、标签、摘要、描述、分组等元数据 |
| 📦 **参数绑定** | 完整支持 `@FromRoute`、`@FromQuery`、`@FromHeader`、`@FromBody` 参数定义 |
| 🎨 **Swagger UI** | 内置 Swagger UI 中间件，提供可视化 API 文档浏览和测试界面 |
| 🧩 **文档转换器** | 支持 `IOpenApiDocumentTransformer` 接口自定义文档转换逻辑 |

---

## 如何使用

### 基本集成

在应用程序的 `configureServices` 中添加 OpenAPI 服务，然后在 `configure` 中启用文档端点和 UI：

```cj
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_web_openapi.*
import soulsoft_extensions_injection.*

main() {
    let builder = WebHost.createBuilder()

    // 注册 OpenAPI 服务
    builder.services.addOpenApi()

    let app = builder.build()

    // 启用路由和 OpenAPI
    app.useRouting()
    app.useOpenApiUI()
    app.mapOpenApi()

    app.run()
}
```

### 配置文档信息

使用配置选项自定义文档标题和分组：

```cj
// 配置默认文档
builder.services.addOpenApi(options: {
    opts => opts.addDocumentTransformer(CustomTransformer())
})

// 配置多文档分组
builder.services.addOpenApi(
    documentName: "v1",
    configureOptions: { opts =>
        opts.addDocumentTransformer({ doc =>
            doc.info = OpenApiInfo(
                title: "My API V1",
                version: "1.0.0"
            )
        })
    }
)
```

### 使用 @OpenApi 注解

在控制器或方法上添加注解自定义 API 元数据：

```cj
import soulsoft_web_mvc.*
import soulsoft_web_openapi.annotations.*

@Route["api/users"]
@OpenApi(tags: "用户管理", summary: "用户相关接口")
public class UserController <: Controller {

    @HttpGet["{id}"]
    @OpenApi(
        name: "getUserById",
        summary: "根据ID获取用户",
        description: "返回指定ID的用户详细信息"
    )
    public func getById(@FromRoute id: Int64): UserDto {
        // 实现逻辑
    }

    @HttpPost
    @OpenApi(summary: "创建用户", ignore: false)
    public func create(@FromBody user: CreateUserRequest): UserDto {
        // 实现逻辑
    }
}
```

### 参数定义示例

OpenAPI 会自动识别各种参数绑定注解：

```cj
@Route["api/orders"]
public class OrderController <: Controller {

    // Path 参数: /api/orders/123
    @HttpGet["{orderId}"]
    public func getById(@FromRoute orderId: Int64): OrderDto {
        return OrderDto()
    }

    // Query 参数: /api/orders?page=1&size=20
    @HttpGet
    public func list(
        @FromQuery page: Int64,
        @FromQuery size: Int64
    ): Array<OrderDto> {
        return Array<OrderDto>()
    }

    // Header 参数
    @HttpGet["header-example"]
    public func headerExample(
        @FromHeader headerXApiKey: String
    ): String {
        return "OK"
    }

    // Body 参数
    @HttpPost
    public func create(@FromBody request: CreateOrderRequest): OrderDto {
        return OrderDto()
    }
}
```

---

## API 参考

### OpenApiServiceCollectionExtensions

DI 服务注册扩展。

| 方法 | 说明 |
|------|------|
| `addOpenApi(): ServiceCollection` | 使用默认配置注册 OpenAPI 服务 |
| `addOpenApi(documentName: String): ServiceCollection` | 注册指定名称的文档服务 |
| `addOpenApi(documentName: String, configureOptions: (OpenApiOptions) -> Unit): ServiceCollection` | 注册并配置文档选项 |

### OpenApiEndpointRouteBuilderExtension

路由注册扩展。

| 方法 | 说明 |
|------|------|
| `mapOpenApi(): EndpointRouteBuilder` | 使用默认路由 `/openapi/{documentName}.json` 映射文档端点 |
| `mapOpenApi(pattern: String): EndpointRouteBuilder` | 使用自定义路由模式映射文档端点 |

### OpenApiUIMiddlewareExtensions

Swagger UI 中间件扩展。

| 方法 | 说明 |
|------|------|
| `useOpenApiUI(): Unit` | 启用 Swagger UI 中间件 |

### OpenApiEndpointConventionBuilderExtensions

终结点元数据扩展。

| 方法 | 说明 |
|------|------|
| `withOpenApi(metadata: OpenApi): EndpointConventionBuilder` | 为终结点添加 OpenAPI 元数据 |

### @OpenApi

API 元数据注解，可用于类或方法。

| 属性 | 类型 | 说明 |
|------|------|------|
| `name` | `?String` | 操作 ID |
| `summary` | `?String` | API 摘要 |
| `description` | `?String` | 详细描述 |
| `tags` | `?String` | 逗号分隔的标签列表 |
| `groupName` | `?String` | 文档分组名称 |
| `ignore` | `Bool` | 是否忽略该 API（默认 `false`） |

### OpenApiOptions

文档配置选项。

| 方法 | 说明 |
|------|------|
| `addDocumentTransformer(transformer: IOpenApiDocumentTransformer)` | 添加文档转换器 |

### IOpenApiDocumentTransformer

文档转换器接口，用于自定义生成的文档内容。

| 方法 | 说明 |
|------|------|
| `transform(document: OpenApiDocument): Unit` | 转换文档对象 |

---

## 相关包

- `soulsoft_web_mvc` - MVC 框架核心，提供控制器和模型绑定支持
- `soulsoft_web_http` - HTTP 抽象层，提供请求/响应上下文
- `soulsoft_web_routing` - 路由系统，提供终结点定义
- `soulsoft_web_hosting` - 主机和应用程序构建器
- `soulsoft_extensions_options` - 选项模式配置支持
- `soulsoft_extensions_injection` - 依赖注入容器

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core API Explorer](https://github.com/dotnet/aspnetcore) 中的 OpenAPI 实现模块，原始代码版权归 [.NET Foundation](https://dotnetfoundation.org/) 所有，遵循 MIT 许可证。

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
