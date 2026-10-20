# soulsoft.web.authorization

**基于策略和角色的 Web 授权库，提供需求（Requirement）驱动的灵活授权机制与中间件集成。**
---

## 关于

`soulsoft.web.authorization` 是 ASP.NET Core 授权模型的仓颉移植版，以"需求（Requirement）+ 处理器（Handler）+ 策略（Policy）"三层架构为核心。库内置角色检查、声明检查、匿名拒绝、用户名匹配、断言式内联授权等常用需求类型，并通过 `IAuthorizationService` 提供统一的授权入口。`AuthorizationMiddleware` 与 `DefaultPolicyEvaluator` 负责 HTTP 请求级的策略执行，与 `soulsoft.web.authentication` 认证层无缝衔接。

### 特性

| 特性 | 描述 |
|------|------|
| 📋 **策略驱动** | `AuthorizationPolicy` 聚合多个需求，`AuthorizationPolicyBuilder` 提供链式 API 构建策略 |
| 🎭 **多种内置需求** | 内置 `RolesAuthorizationRequirement`、`ClaimsAuthorizationRequirement`、`DenyAnonymousAuthorizationRequirement`、`NameAuthorizationRequirement`、`AssertionRequirement`、`OperationAuthorizationRequirement` |
| 🔑 **策略注册与查找** | `AuthorizationOptions.addPolicy` 按名称注册，`getPolicy` 大小写不敏感检索 |
| 🏗️ **链式 Builder** | `AuthorizationBuilder` 支持 `addPolicy / setDefaultPolicy / setFallbackPolicy / setInvokeHandlersAfterFailure` 链式调用 |
| 🔄 **策略合并** | `AuthorizationPolicy.combine` 将多个策略合并为一个，聚合全部需求与认证方案 |
| 🛡️ **中间件集成** | `AuthorizationMiddleware` + `DefaultPolicyEvaluator` 处理 HTTP 请求级授权，支持 Challenge / Forbid / Success 三种结果 |
| 💉 **依赖注入集成** | `ServiceCollection.addAuthorization` / `addAuthorizationBuilder` 一键注册全套授权服务 |
| ✍️ **断言式授权** | `AssertionRequirement` 接受 `(AuthorizationHandlerContext) -> Bool` lambda，无需定义额外需求类 |

---

## 如何使用

### 注册授权服务

```cj
import soulsoft_extensions_injection.*
import soulsoft_web_authorization.*

let services = ServiceCollection()

// 注册授权服务并定义策略
services.addAuthorization { options =>
    // 角色策略
    options.addPolicy("AdminOnly") { builder =>
        let _ = builder.requireRole(["admin"])
    }
    // 声明策略：检查 claim type + value
    options.addPolicy("EmailVerified") { builder =>
        let _ = builder.requireClaim("email_verified", ["true"])
    }
    // 断言式内联策略
    options.addPolicy("EditorOrAdmin") { builder =>
        let _ = builder.requireAssertion { ctx =>
            ctx.user.isInRole("admin") || ctx.user.isInRole("editor")
        }
    }
}
```

通过 `addAuthorizationBuilder` 使用链式 Builder：

```cj
import soulsoft_extensions_injection.*
import soulsoft_web_authorization.*

let services = ServiceCollection()

let _ = services.addAuthorizationBuilder()
    .addPolicy("Moderator") { builder =>
        let _ = builder.requireRole(["admin", "moderator"])
    }
    .setDefaultPolicy(AuthorizationPolicyBuilder().requireAuthenticatedUser().build())
    .setFallbackPolicy { builder =>
        let _ = builder.requireAuthenticatedUser()
    }
    .setInvokeHandlersAfterFailure(false)
```

### 构建与使用需求

```cj
import soulsoft_identity_claims.*
import soulsoft_web_authorization.*

// 构造已认证用户
let identity = ClaimsIdentity(Some("Bearer"))
identity.addClaim(ClaimTypes.Role, "admin")
let user = ClaimsPrincipal([identity])

// 使用角色需求
let req = RolesAuthorizationRequirement(["admin", "superuser"])
let reqs: Array<IAuthorizationRequirement> = [req]
let ctx = AuthorizationHandlerContext(reqs, user, None)
req.handle(ctx)

if (ctx.hasSucceeded) {
    println("授权通过")
} else {
    println("授权拒绝，待处理需求：${ctx.pendingRequirements.size} 个")
}
```

### 内置需求类型速览

```cj
import soulsoft_web_authorization.*

// 角色需求：属于任意一个角色即通过
let rolesReq = RolesAuthorizationRequirement(["admin", "superuser"])

// 声明需求（仅检查 type 存在）
let claimReq = ClaimsAuthorizationRequirement("email", [])

// 声明需求（检查 type + value 在允许列表中）
let claimValReq = ClaimsAuthorizationRequirement("department", ["engineering", "product"])

// 用户名需求（大小写不敏感）
let nameReq = NameAuthorizationRequirement("alice")

// 拒绝匿名：要求至少一个 identity 已认证
let denyAnon = DenyAnonymousAuthorizationRequirement()

// 操作需求：由业务侧 AuthorizationResourceHandler 实现具体逻辑
let readOp  = OperationAuthorizationRequirement("Read")
let writeOp = OperationAuthorizationRequirement("Write")

// 断言式需求：lambda 返回 true 则授权通过
let assertReq = AssertionRequirement { ctx =>
    ctx.user.hasClaim(ClaimTypes.Role, "editor")
}
```

### 策略合并

```cj
import soulsoft_web_authorization.*

let p1 = AuthorizationPolicyBuilder().requireAuthenticatedUser().build()
let p2 = AuthorizationPolicyBuilder().requireRole(["admin"]).build()

// 合并两个策略，所有需求取并集
let combined = AuthorizationPolicy.combine([p1, p2])
```

---

## API 参考

### IAuthorizationService

| 方法 | 说明 |
|------|------|
| `authorize(user: ClaimsPrincipal, resource: ?Object, policyName: String): AuthorizationResult` | 按策略名称授权，策略不存在时抛异常 |
| `authorize(user: ClaimsPrincipal, resource: ?Object, requirements: Collection<IAuthorizationRequirement>): AuthorizationResult` | 按需求集合授权 |

### AuthorizationResult

| 成员 | 说明 |
|------|------|
| `static func success(): AuthorizationResult` | 返回成功结果（共享静态实例） |
| `static func failed(): AuthorizationResult` | 返回失败结果（携带 explicitFail） |
| `static func failed(failure: AuthorizationFailure): AuthorizationResult` | 返回携带指定失败信息的结果 |
| `prop succeeded: Bool` | 是否授权成功 |
| `prop failure: ?AuthorizationFailure` | 失败详情，成功时为 `None` |

### PolicyAuthorizationResult

| 成员 | 说明 |
|------|------|
| `static func success(): PolicyAuthorizationResult` | 授权成功 |
| `static func forbid(): PolicyAuthorizationResult` | 已认证但权限不足（403） |
| `static func forbid(authorizationFailure: ?AuthorizationFailure): PolicyAuthorizationResult` | 携带失败信息的禁止结果；`None` 时等同于无参 `forbid()` |
| `static func challenge(): PolicyAuthorizationResult` | 未认证，需要登录（401） |
| `prop succeeded: Bool` | 是否成功 |
| `prop forbidden: Bool` | 是否 Forbid |
| `prop challenged: Bool` | 是否 Challenge |

### AuthorizationHandlerContext

| 成员 | 说明 |
|------|------|
| `init(requirements: Collection<IAuthorizationRequirement>, user: ClaimsPrincipal, resource: ?Object)` | 构造授权上下文 |
| `func succeed(requirement: IAuthorizationRequirement): Unit` | 标记某需求已满足，从 `pendingRequirements` 中移除 |
| `func fail(): Unit` | 主动标记授权失败 |
| `func fail(reason: AuthorizationFailureReason): Unit` | 携带失败原因标记失败 |
| `prop hasSucceeded: Bool` | 所有需求均已 succeed 且未调用 fail 时为 `true` |
| `prop hasFailed: Bool` | 是否调用过 `fail()` |
| `prop pendingRequirements: Collection<IAuthorizationRequirement>` | 尚未满足的需求集合 |
| `prop failedReasons: Collection<AuthorizationFailureReason>` | 失败原因列表 |
| `prop user: ClaimsPrincipal` | 当前用户主体 |
| `prop resource: ?Object` | 被授权访问的资源，可为 `None` |

### AuthorizationPolicyBuilder

| 方法 | 说明 |
|------|------|
| `func requireRole(roles: Array<String>): AuthorizationPolicyBuilder` | 添加角色需求 |
| `func requireClaim(claimName: String, allowedValues: Array<String>): AuthorizationPolicyBuilder` | 添加声明需求（type + value 匹配） |
| `func requireClaim(claimName: String): AuthorizationPolicyBuilder` | 添加声明需求（仅检查 type 存在） |
| `func requireUserName(userName: String): AuthorizationPolicyBuilder` | 添加用户名需求 |
| `func requireAssertion(handler: (AuthorizationHandlerContext) -> Bool): AuthorizationPolicyBuilder` | 添加断言式内联需求 |
| `func requireAuthenticatedUser(): AuthorizationPolicyBuilder` | 添加拒绝匿名需求 |
| `func addRequirements(requirements: Array<IAuthorizationRequirement>): AuthorizationPolicyBuilder` | 批量添加自定义需求 |
| `func addAuthenticationSchemes(schemes: Array<String>): AuthorizationPolicyBuilder` | 添加认证方案 |
| `func combine(policy: AuthorizationPolicy): AuthorizationPolicyBuilder` | 合并已有策略 |
| `func build(): AuthorizationPolicy` | 构建最终策略 |

### AuthorizationOptions

| 属性 / 方法 | 说明 |
|-------------|------|
| `var invokeHandlersAfterFailure: Bool` | 某 Handler 调用 fail 后是否继续执行其余 Handler，默认 `true` |
| `var fallbackPolicy: ?AuthorizationPolicy` | 无策略时的兜底策略，默认 `None` |
| `var suppressUseHttpContextAsAuthorizationResource: Bool` | 是否禁止将 `HttpContext` 作为授权资源，默认 `false` |
| `mut prop defaultPolicy: AuthorizationPolicy` | 默认策略，初始为 `requireAuthenticatedUser()` |
| `func addPolicy(name: String, policy: AuthorizationPolicy): Unit` | 按名称注册已构建策略（大小写不敏感存储） |
| `func addPolicy(name: String, configurePolicy: (AuthorizationPolicyBuilder) -> Unit): Unit` | 按名称注册配置委托 |
| `func getPolicy(name: String): ?AuthorizationPolicy` | 按名称检索策略（大小写不敏感），不存在返回 `None` |

### AuthorizationBuilder

| 方法 | 说明 |
|------|------|
| `func addPolicy(name: String, policy: AuthorizationPolicy): AuthorizationBuilder` | 注册策略 |
| `func addPolicy(name: String, configurePolicy: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder` | 注册策略（Builder 形式） |
| `func setDefaultPolicy(policy: AuthorizationPolicy): AuthorizationBuilder` | 设置默认策略 |
| `func setDefaultPolicy(configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder` | 设置默认策略（Builder 形式） |
| `func setFallbackPolicy(policy: ?AuthorizationPolicy): AuthorizationBuilder` | 设置兜底策略 |
| `func setFallbackPolicy(configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder` | 设置兜底策略（Builder 形式） |
| `func addDefaultPolicy(name: String, ...): AuthorizationBuilder` | 注册策略并同时设为默认策略 |
| `func addFallbackPolicy(name: String, ...): AuthorizationBuilder` | 注册策略并同时设为兜底策略 |
| `func setInvokeHandlersAfterFailure(invoke: Bool): AuthorizationBuilder` | 配置失败后是否继续执行后续 Handler |

### ServiceCollection 扩展

| 方法 | 说明 |
|------|------|
| `func addAuthorization(): ServiceCollection` | 注册完整授权服务（含策略评估器和中间件结果处理器） |
| `func addAuthorization(configure: (AuthorizationOptions) -> Unit): ServiceCollection` | 注册并配置授权服务 |
| `func addAuthorizationBuilder(): AuthorizationBuilder` | 注册授权服务并返回链式 Builder |
| `func addAuthorizationCore(configure: (AuthorizationOptions) -> Unit): ServiceCollection` | 仅注册核心授权服务（不含策略评估器） |
| `func addAuthorizationPolicyEvaluator(): ServiceCollection` | 单独注册策略评估器（`IPolicyEvaluator`）及相关服务 |

---

## 相关包

- `soulsoft_identity_claims` — 声明式身份模型，提供 `Claim`、`ClaimsIdentity`、`ClaimsPrincipal`
- `soulsoft_web_authentication` — 认证层，提供 `AuthenticateResult`、`IAuthenticationService`
- `soulsoft_web_http` — HTTP 抽象，提供 `HttpContext`、`Endpoint`
- `soulsoft_web_routing` — 路由层，提供端点元数据与路由约定
- `soulsoft_extensions_options` — Options 模式，`IOptions<T>` 配置管理
- `soulsoft_extensions_injection` — 依赖注入容器，`ServiceCollection`、`IServiceProvider`
- `soulsoft_extensions_logging` — 日志抽象，`ILoggerFactory`、`ILogger`

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/aspnetcore](https://github.com/dotnet/aspnetcore/tree/main/src/Security/Authorization) 中的 `Microsoft.AspNetCore.Authorization` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
