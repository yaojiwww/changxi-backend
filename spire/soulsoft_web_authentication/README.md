# soulsoft.web.authentication

**Web 应用程序身份验证抽象库，提供身份验证机制的核心组件和接口。**
---

## 关于

soulsoft.web.authentication 是一个用于处理 Web 应用程序身份验证的抽象库。它定义了身份验证的基础类型，包括认证方案选项、认证处理器、认证结果等抽象类和接口。作为基础库，它为具体的认证实现（如 Cookie 认证、JWT 认证等）提供核心支撑。

### 特性

| 特性 | 描述 |
|------|------|
| 🔐 **认证服务** | 提供 `IAuthenticationService` 接口，支持认证、登录、登出、挑战和禁止等操作 |
| 📝 **认证处理器** | 抽象基类 `AuthenticationHandler<TOptions>`，便于实现自定义认证方式 |
| 🏷️ **认证方案** | 支持多方案管理，通过 `AuthenticationSchemeProvider` 统一管理 |
| 🎟️ **认证票据** | `AuthenticationTicket` 封装用户主体和认证属性，支持序列化/反序列化 |
| ⚙️ **中间件集成** | 提供 `AuthenticationMiddleware` 与 HTTP 管道集成，自动处理认证流程 |
| 🔧 **DI 扩展** | 通过 `ServiceCollection.addAuthentication()` 便捷注册认证服务 |
| 🔄 **转发机制** | 支持认证、挑战等操作转发到其他方案，实现方案组合 |
| 🚀 **HttpContext 扩展** | 为 `HttpContext` 添加 `authenticate()`、`signIn()`、`signOut()` 等便捷方法 |

`AuthenticationSchemeProvider` 基于 `Mutex` 和原子操作实现，线程安全。

---

## 如何使用

### 基本配置

在应用启动时配置认证服务：

```cj
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*

// 注册认证服务
services.addAuthentication()
    .addScheme<MyAuthOptions, MyAuthHandler>("MyScheme", displayName: "我的认证") {
        options =>
            // 配置选项
            options.forwardAuthenticate = "OtherScheme"
    }

// 配置默认方案
services.configure<AuthenticationOptions> {
    options =>
        options.defaultAuthenticateScheme = "MyScheme"
        options.defaultSignInScheme = "MyScheme"
        options.defaultSignOutScheme = "MyScheme"
}
```

### 使用中间件

在 HTTP 管道中启用认证：

```cj
import soulsoft_web_http.*

// 启用认证中间件
app.useAuthentication()
```

### 执行认证操作

在处理器中执行认证相关操作：

```cj
import soulsoft_web_http.*
import soulsoft_identity_claims.*

// 认证当前请求
let result = context.authenticate()
if (result.succeeded) {
    if (let Some(principal) <- result.principal) {
        println("认证成功: ${principal.identity?.name}")
    }
}

// 登录用户
let principal = ClaimsPrincipal(ClaimsIdentity([Claim("name", "user1")], "MyScheme"))
context.signIn("MyScheme", principal)

// 登出用户
context.signOut("MyScheme")

// 挑战未认证用户
context.challenge()

// 禁止访问
context.forbid()
```

### 实现自定义认证处理器

继承 `AuthenticationHandler` 实现自定义认证逻辑：

```cj
import soulsoft_web_authentication.*
import soulsoft_web_http.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

public class MyAuthOptions <: AuthenticationSchemeOptions {
    public var customOption: String = ""
}

public class MyAuthHandler <: AuthenticationHandler<MyAuthOptions> &
    IAuthenticationSignInHandler & IAuthenticationSignOutHandler {

    public init(options: IOptionsMonitor<MyAuthOptions>, logFactory: ILoggerFactory) {
        super(options, logFactory)
    }

    protected func handleAuthenticate(): AuthenticateResult {
        // 实现认证逻辑
        let principal = ClaimsPrincipal(ClaimsIdentity([Claim("name", "user")]))
        let ticket = AuthenticationTicket(principal, scheme.name)
        return AuthenticateResult.success(ticket)
    }

    public func signIn(principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit {
        // 实现登录逻辑
    }

    public func signOut(properties: ?AuthenticationProperties): Unit {
        // 实现登出逻辑
    }
}
```

---

## API 参考

### IAuthenticationService

| 方法 | 说明 |
|------|------|
| `authenticate(context: HttpContext, scheme: ?String): AuthenticateResult` | 执行认证，返回认证结果 |
| `challenge(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit` | 挑战未认证用户 |
| `forbid(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit` | 禁止访问 |
| `signIn(context: HttpContext, scheme: ?String, principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit` | 登录用户 |
| `signOut(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit` | 登出用户 |

### AuthenticationHandler<TOptions>

| 方法/属性 | 说明 |
|-----------|------|
| `initialize(scheme: AuthenticationScheme, context: HttpContext): Unit` | 初始化处理器 |
| `authenticate(): AuthenticateResult` | 执行认证（支持转发） |
| `challenge(properties: ?AuthenticationProperties): Unit` | 处理挑战 |
| `forbid(properties: ?AuthenticationProperties): Unit` | 处理禁止 |
| `scheme: AuthenticationScheme` | 当前认证方案 |
| `context: HttpContext` | 当前 HTTP 上下文 |
| `options: TOptions` | 方案选项 |
| `logger: ILogger` | 日志记录器 |

### AuthenticateResult

| 方法/属性 | 说明 |
|-----------|------|
| `succeeded: Bool` | 认证是否成功 |
| `principal: ?ClaimsPrincipal` | 获取用户主体 |
| `ticket: ?AuthenticationTicket` | 获取认证票据 |
| `failure: ?Exception` | 获取失败异常 |
| `static fail(failure: Exception): AuthenticateResult` | 创建失败结果 |
| `static success(ticket: AuthenticationTicket): AuthenticateResult` | 创建成功结果 |
| `static noResult(): AuthenticateResult` | 创建无结果结果 |

### AuthenticationBuilder

| 方法 | 说明 |
|------|------|
| `addScheme<TOptions, THandler>(authenticationScheme: String): AuthenticationBuilder` | 注册认证方案 |
| `addScheme<TOptions, THandler>(scheme: String, configureOptions: (TOptions) -> Unit): AuthenticationBuilder` | 注册并配置方案 |
| `addScheme<TOptions, THandler>(scheme: String, displayName: ?String, configureOptions: (TOptions) -> Unit): AuthenticationBuilder` | 注册并配置方案（带显示名） |

### AuthenticationOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `defaultScheme` | `?String` | 默认方案 |
| `defaultAuthenticateScheme` | `?String` | 默认认证方案 |
| `defaultChallengeScheme` | `?String` | 默认挑战方案 |
| `defaultForbidScheme` | `?String` | 默认禁止方案 |
| `defaultSignInScheme` | `?String` | 默认登录方案 |
| `defaultSignOutScheme` | `?String` | 默认登出方案 |
| `requireAuthenticatedSignIn` | `Bool` | 是否要求已认证用户才能登录 |

### AuthenticationSchemeOptions

| 属性 | 类型 | 说明 |
|------|------|------|
| `forwardAuthenticate` | `?String` | 转发认证到指定方案 |
| `forwardChallenge` | `?String` | 转发挑战到指定方案 |
| `forwardForbid` | `?String` | 转发禁止到指定方案 |
| `forwardSignIn` | `?String` | 转发登录到指定方案 |
| `forwardSignOut` | `?String` | 转发登出到指定方案 |
| `forwardDefault` | `?String` | 默认转发目标 |
| `forwardDefaultSelector` | `?(HttpContext) -> ?String` | 动态选择转发目标 |

### HttpContext 扩展方法

| 方法 | 说明 |
|------|------|
| `authenticate(): AuthenticateResult` | 使用默认方案认证 |
| `authenticate(scheme: ?String): AuthenticateResult` | 使用指定方案认证 |
| `challenge() / challenge(scheme: ?String)` | 挑战用户 |
| `forbid() / forbid(scheme: ?String)` | 禁止访问 |
| `signIn(principal: ClaimsPrincipal)` | 使用默认方案登录 |
| `signIn(scheme: ?String, principal: ClaimsPrincipal, properties: ?AuthenticationProperties)` | 使用指定方案登录 |
| `signOut() / signOut(scheme: ?String)` | 登出用户 |
| `getToken(tokenName: String): ?String` | 获取令牌值 |

---

## 相关包

- `soulsoft_web_http` - HTTP 服务抽象和 HttpContext
- `soulsoft_identity_claims` - 用户身份和声明管理
- `soulsoft_extensions_logging` - 日志扩展
- `soulsoft_extensions_options` - 选项配置管理
- `soulsoft_extensions_injection` - 依赖注入服务

---

## 反馈与贡献

本项目由[杭州颉创科技有限公司](https://gitcode.com/soulsoft)开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [.NET Core Authentication](https://github.com/dotnet/aspnetcore) 中的 Authentication 模块，原始代码版权归 [.NET Foundation](https://dotnetfoundation.org) 所有，遵循 MIT 许可证。
