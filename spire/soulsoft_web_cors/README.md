# soulsoft.web.cors

**用于处理跨域资源共享（CORS）的中间件库，支持策略配置、预检请求处理与端点级 CORS 控制。**
---

## 关于

`soulsoft.web.cors` 提供完整的 CORS 中间件解决方案。核心接口 `ICorsService` 负责请求评估与响应头写入，`CorsPolicyBuilder` 以链式调用方式构建策略，`CorsMiddleware` 作为管道中间件自动处理预检请求（OPTIONS）并为普通跨域请求附加响应头。策略可通过 `CorsOptions` 集中注册，也可在端点或路由级别通过 `EnableCors` / `DisableCors` 注解单独控制。

### 特性

| 特性 | 描述 |
|------|------|
| 🔗 **链式策略构建** | `CorsPolicyBuilder` 支持链式调用 `withOrigins`、`withHeaders`、`withMethods` 等方法构建 CORS 策略 |
| 🌐 **通配符子域名** | `setIsOriginAllowedToAllowWildcardSubdomains()` 支持 `http://*.example.com` 格式的子域名批量放行 |
| ✈️ **预检请求处理** | 自动识别 OPTIONS 预检请求，返回 204 并写入 `Access-Control-Allow-*` 响应头 |
| 📋 **多策略管理** | `CorsOptions` 支持按名称注册多个策略，中间件或端点按需引用 |
| 🔧 **端点级控制** | `requireCors()` 在路由端点上单独配置 CORS 策略，覆盖全局中间件配置 |
| 🚫 **禁用 CORS** | `DisableCors` 注解可针对特定端点禁用 CORS，预检请求返回 204 |
| 🔌 **依赖注入集成** | `addCors()` 扩展方法一键注册 `ICorsService`、`ICorsPolicyProvider` 到 DI 容器 |

---

## 如何使用

### 注册服务与中间件

```cj
import soulsoft_web_cors.*
import soulsoft_web_cors.abstractions.*

// 注册 CORS 服务并配置策略
services.addCors { options =>
    // 默认策略
    options.addDefaultPolicy { builder =>
        let _ = builder
            .withOrigins(["https://example.com", "https://app.example.com"])
            .withHeaders(["Content-Type", "Authorization"])
            .withMethods(["GET", "POST", "PUT", "DELETE"])
    }
    // 命名策略
    options.addPolicy("open") { builder =>
        let _ = builder.allowAnyOrigin().allowAnyMethod().allowAnyHeader()
    }
}

// 在管道中启用 CORS 中间件（放在路由中间件之前）
app.useCors()                  // 使用默认策略
app.useCors("open")            // 使用指定策略
app.useCors { builder =>       // 内联策略
    let _ = builder.allowAnyOrigin().allowAnyHeader()
}
```

### 构建 CORS 策略

```cj
import soulsoft_web_cors.abstractions.*

// 精确来源 + 凭证 + 预检缓存
let policy = CorsPolicyBuilder(["https://app.example.com"])
    .withHeaders(["Content-Type", "Authorization"])
    .withMethods(["GET", "POST"])
    .withExposedHeaders(["X-Request-Id"])
    .allowCredentials()
    .setPreflightMaxAge(Duration.second * 600)
    .build()

// 自定义来源校验
let customPolicy = CorsPolicyBuilder([])
    .setIsOriginAllowed { origin => origin.endsWith(".trusted.com") }
    .build()
```

### 通配符子域名

```cj
import soulsoft_web_cors.abstractions.*

// http://*.example.com 的所有子域名均被允许
let policy = CorsPolicyBuilder(["http://*.example.com"])
    .setIsOriginAllowedToAllowWildcardSubdomains()
    .build()

// policy.isOriginAllowed("http://api.example.com")   → true
// policy.isOriginAllowed("http://example.com")       → false（非子域名）
// policy.isOriginAllowed("https://api.example.com")  → false（scheme 不同）
```

### 端点级 CORS 控制

```cj
import soulsoft_web_cors.*

// 使用已注册的策略名称
app.mapGet("/api/data") { ctx => /* ... */ }
   .requireCors("open")

// 内联定义端点级策略
app.mapPost("/api/upload") { ctx => /* ... */ }
   .requireCors { builder =>
       let _ = builder
           .withOrigins(["https://upload.example.com"])
           .allowCredentials()
   }

// 禁用特定端点的 CORS
app.mapGet("/internal/health") { ctx => /* ... */ }
   .withMetadata(DisableCors())
```

---

## API 参考

### CorsPolicyBuilder

| 方法 | 说明 |
|------|------|
| `init(origins: Array<String>)` | 构造 Builder 并添加初始来源（空数组表示不预设来源） |
| `withOrigins(origins: Array<String>): CorsPolicyBuilder` | 追加允许来源，自动转小写并剥离默认端口（:80 / :443） |
| `withHeaders(headers: Array<String>): CorsPolicyBuilder` | 追加允许的请求头 |
| `withMethods(methods: Array<String>): CorsPolicyBuilder` | 追加允许的 HTTP 方法 |
| `withExposedHeaders(headers: Array<String>): CorsPolicyBuilder` | 追加暴露给客户端的响应头 |
| `allowAnyOrigin(): CorsPolicyBuilder` | 清空来源列表并设为通配符 `*` |
| `allowAnyMethod(): CorsPolicyBuilder` | 清空方法列表并设为通配符 `*` |
| `allowAnyHeader(): CorsPolicyBuilder` | 清空请求头列表并设为通配符 `*` |
| `allowCredentials(): CorsPolicyBuilder` | 允许携带凭证（Cookie / Authorization） |
| `disallowCredentials(): CorsPolicyBuilder` | 禁止携带凭证 |
| `setPreflightMaxAge(preflightMaxAge: Duration): CorsPolicyBuilder` | 设置预检结果缓存时间 |
| `setIsOriginAllowed(isOriginAllowed: (String) -> Bool): CorsPolicyBuilder` | 设置自定义来源校验函数 |
| `setIsOriginAllowedToAllowWildcardSubdomains(): CorsPolicyBuilder` | 启用通配符子域名匹配（如 `http://*.example.com`） |
| `build(): CorsPolicy` | 构建策略；`allowAnyOrigin` 与 `allowCredentials` 同时设置时抛 `UnsupportedException` |

### CorsPolicy

| 属性 | 类型 | 说明 |
|------|------|------|
| `allowAnyOrigin` | `Bool` | 是否允许任意来源（只读） |
| `allowAnyMethod` | `Bool` | 是否允许任意方法（只读） |
| `allowAnyHeader` | `Bool` | 是否允许任意请求头（只读） |
| `supportsCredentials` | `mut Bool` | 是否支持凭证 |
| `preflightMaxAge` | `mut ?Duration` | 预检缓存时间；设置负值抛 `IllegalArgumentException` |
| `isOriginAllowed` | `mut (String)->Bool` | 来源校验函数 |
| `origins` | `List<String>` | 允许的来源列表 |
| `headers` | `List<String>` | 允许的请求头列表 |
| `methods` | `List<String>` | 允许的方法列表 |
| `exposedHeaders` | `List<String>` | 暴露的响应头列表 |

### CorsOptions

| 方法/属性 | 说明 |
|-----------|------|
| `addDefaultPolicy(policy: CorsPolicy)` | 以默认名称注册策略 |
| `addDefaultPolicy(configurePolicy: (CorsPolicyBuilder) -> Unit)` | 以 Builder 回调方式注册默认策略 |
| `addPolicy(name: String, policy: CorsPolicy)` | 按名称注册策略 |
| `addPolicy(name: String, configurePolicy: (CorsPolicyBuilder) -> Unit)` | 按名称以 Builder 回调方式注册策略 |
| `getPolicy(name: String): ?CorsPolicy` | 按名称查询策略，不存在返回 `None` |
| `defaultPolicyName: mut String` | 默认策略名，初始为 `__DefaultCorsPolicy` |

### ICorsService

| 方法 | 说明 |
|------|------|
| `evaluatePolicy(context: HttpContext, policy: CorsPolicy): CorsResult` | 根据请求和策略计算 CORS 结果 |
| `applyResult(result: CorsResult, response: HttpResponse): Unit` | 将 CORS 结果写入响应头 |

### EnableCors / DisableCors

| 类型 | 说明 |
|------|------|
| `EnableCors()` | 注解：启用默认 CORS 策略 |
| `EnableCors(policyName: ?String)` | 注解：启用指定名称的 CORS 策略 |
| `DisableCors()` | 注解：禁用 CORS，预检请求返回 204 |

---

## 相关包

- `soulsoft_web_http` - HTTP 上下文、请求/响应抽象
- `soulsoft_web_routing` - 路由中间件与端点元数据
- `soulsoft_extensions_options` - 选项模式（`IOptions<T>`）
- `soulsoft_extensions_logging` - 日志抽象（`ILogger`）
- `soulsoft_extensions_injection` - 依赖注入容器

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [ASP.NET Core](https://github.com/dotnet/aspnetcore) 中的 CORS 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
