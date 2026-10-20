# soulsoft.web.healthchecks

**为仓颉 Web 应用提供健康检查端点，支持中间件与端点路由两种注册方式。**
---

## 关于

`soulsoft.web.healthchecks` 是面向仓颉 Web 应用的健康检查集成层，将 `soulsoft_extensions_healthchecks` 中注册的健康检查项暴露为 HTTP 端点。支持通过 `useHealthChecks` 以中间件方式挂载，也支持通过 `mapHealthChecks` 以端点路由方式注册。可按名称或 tag 对健康检查项进行过滤，支持自定义 HTTP 状态码映射和响应格式。

### 特性

| 特性 | 描述 |
|------|------|
| 🔌 **中间件挂载** | `useHealthChecks(path)` 将健康检查注册为路径匹配中间件，精确匹配（允许尾部斜杠） |
| 🗺️ **端点路由集成** | `mapHealthChecks(pattern)` 通过 `EndpointRouteBuilder` 注册为路由端点，返回 `EndpointConventionBuilder` |
| 🔎 **灵活过滤** | `predicate` 支持按名称、tag 或任意条件筛选参与聚合的健康检查项 |
| 🗂️ **状态码映射** | `resultStatusCodes` 可配置各 `HealthStatus` 对应的 HTTP 状态码，默认 Unhealthy → 503 |
| ✍️ **自定义响应** | `responseWriter` 支持完全自定义响应体格式（JSON、详情报告等） |
| 🚫 **防缓存控制** | 默认注入 `Cache-Control: no-store`、`Pragma: no-cache` 等响应头，可通过 `allowCachingResponses` 关闭 |
| ⚙️ **Lambda 配置** | 三种重载均支持 Lambda 配置回调，无需手动构建 `HealthCheckOptions` 实例 |

---

## 如何使用

### 注册服务并挂载端点

在启动代码中调用 `addHealthChecks()` 注册检查项，再调用 `useHealthChecks` 或 `mapHealthChecks` 暴露端点：

```cj
import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_healthchecks.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_healthchecks.*

main(): Int64 {
    let builder = WebHost.createBuilder([])
    builder.services.addRouting()

    // 注册健康检查项（名称 + tags + 检查函数）
    builder.services.addHealthChecks()
        .addCheck("database", ["db"]) {
            HealthCheckResult.healthy(description: Some("connected"))
        }
        .addCheck("cache", ["critical"]) {
            HealthCheckResult.unhealthy(description: Some("connection refused"))
        }

    let app = builder.build()

    // 方式一：中间件挂载，精确路径匹配
    app.useHealthChecks("/healthz")

    // 方式二：端点路由注册（需先调用 useRouting）
    app.useRouting()
    app.mapHealthChecks("/health")

    app.run("http://0.0.0.0:5000")
    return 0
}
```

### 按名称或 Tag 过滤

通过 `predicate` 控制哪些检查项参与本次聚合：

```cj
import soulsoft_web_healthchecks.*

// 仅检查名称为 "database" 的项
app.useHealthChecks("/health/db") { opts =>
    opts.predicate = { reg => reg.name == "database" }
}

// 按 tag 过滤：仅检查含 "critical" tag 的项
app.useHealthChecks("/health/critical") { opts =>
    opts.predicate = { reg =>
        var matched = false
        for (t in reg.tags) {
            if (t == "critical") { matched = true }
        }
        matched
    }
}
```

### 自定义响应与缓存控制

```cj
import soulsoft_web_healthchecks.*

app.useHealthChecks("/health/detail") { opts =>
    // 自定义响应体（如 JSON 格式）
    opts.responseWriter = { context, report =>
        context.response.contentType = "application/json"
        context.response.write("{\"status\":\"${report.status}\"}")
    }
    // 允许客户端缓存响应（不注入防缓存头）
    opts.allowCachingResponses = true
}
```

---

## API 参考

### HealthCheckOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `resultStatusCodes` | `HashMap<HealthStatus, UInt16>` | Healthy→200, Degraded→200, Unhealthy→503 | 各健康状态对应的 HTTP 响应状态码 |
| `allowCachingResponses` | `Bool` | `false` | 为 `false` 时自动注入防缓存响应头 |
| `predicate` | `(HealthCheckRegistration) -> Bool` | 接受全部 | 过滤参与本次聚合的健康检查注册项 |
| `responseWriter` | `(HttpContext, HealthReport) -> Unit` | 写入 `HealthStatus.toString()` | 自定义响应体写入逻辑 |

### HealthCheckApplicationBuilderExtensions

通过 `extend ApplicationBuilder` 为 `ApplicationBuilder` 添加以下方法：

| 方法 | 说明 |
|------|------|
| `useHealthChecks(path: String): Unit` | 使用默认选项在指定路径挂载健康检查中间件 |
| `useHealthChecks(path: String, configureOptions: (HealthCheckOptions) -> Unit): Unit` | 通过 Lambda 配置选项后挂载 |
| `useHealthChecks(path: String, options: HealthCheckOptions): Unit` | 使用指定选项挂载 |

### HealthCheckEndpointRouteBuilderExtensions

通过 `extend EndpointRouteBuilder` 为 `EndpointRouteBuilder` 添加以下方法：

| 方法 | 说明 |
|------|------|
| `mapHealthChecks(pattern: String): EndpointConventionBuilder` | 使用默认选项注册健康检查路由端点 |
| `mapHealthChecks(pattern: String, configureOptions: (HealthCheckOptions) -> Unit): EndpointConventionBuilder` | 通过 Lambda 配置选项后注册 |
| `mapHealthChecks(pattern: String, options: HealthCheckOptions): EndpointConventionBuilder` | 使用指定选项注册 |

---

## 相关包

- `soulsoft_extensions_healthchecks` - 健康检查核心抽象（`IHealthCheck`、`HealthCheckResult`、`IHealthCheckService`、`addHealthChecks()`）
- `soulsoft_web_http` - HTTP 上下文、请求/响应处理
- `soulsoft_web_routing` - 端点路由（`EndpointRouteBuilder`、`EndpointConventionBuilder`）
- `soulsoft_extensions_options` - 选项模式支持（`IOptions<T>`）
- `soulsoft_extensions_injection` - 依赖注入容器

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 `Microsoft.AspNetCore.Diagnostics.HealthChecks` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
