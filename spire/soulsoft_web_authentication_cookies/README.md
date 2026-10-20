# soulsoft.web.authentication.cookies

**基于 Cookie 的身份验证处理器，为仓颉 Web 应用提供安全、灵活的 Cookie 身份验证机制。**

![Output](https://img.shields.io/badge/output-static-blue?style=flat-square)
[![GitCode](https://img.shields.io/badge/GitCode-soulsoft%2Fspire-blue?style=flat-square&logo=git)](https://gitcode.com/soulsoft/spire)

---

## 关于

`soulsoft_web_authentication_cookies` 是一个用于仓颉 Web 应用的 Cookie 身份验证库。它实现了标准的身份验证处理器，支持票据（Ticket）的加密存储、滑动过期、事件回调等高级特性。该库与 `soulsoft_web_authentication` 集成，提供完整的登录、登出和身份验证流程。

### 特性

| 特性 | 描述 |
|------|------|
| 🔐 **安全票据存储** | 使用数据保护（Data Protection）对身份票据进行加密，支持 Base64 URL 编码 |
| 🍪 **分块 Cookie 管理** | `ChunkingCookieManager` 自动处理超大 Cookie 的分块存储，规避浏览器限制 |
| ⏱️ **滑动过期** | 支持滑动过期策略，每次访问自动续期，可配置过期时间跨度 |
| 🗄️ **会话存储** | 通过 `ITicketStore` 接口支持服务端会话存储，减少 Cookie 大小 |
| 🔔 **丰富的事件机制** | 提供登录、登出、验证、重定向等事件的回调钩子 |
| 🔧 **灵活配置** | 支持 Cookie 名称、路径、域名、安全属性等完整配置选项 |
| 🎯 **多方案支持** | 支持自定义身份验证方案名称，可多实例共存 |
| ⚡ **Ajax 感知** | 自动识别 Ajax 请求，返回适当的 HTTP 状态码而非重定向 |

---

## 如何使用

### 基本配置

在应用启动时注册 Cookie 身份验证服务：

```cj
import soulsoft_web_authentication_cookies.*
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*

// 注册 Cookie 身份验证
services.addAuthentication()
    .addCookie()

// 或者自定义配置
services.addAuthentication()
    .addCookie("MyCookieScheme") {
        options =>
        options.cookie.name = ".myapp.auth"
        options.expireTimeSpan = Duration.day * 7
        options.slidingExpiration = true
        options.loginPath = PathString("/login")
        options.logoutPath = PathString("/logout")
        options.accessDeniedPath = PathString("/access-denied")
    }
```

### 登录与登出

在控制器或中间件中执行登录和登出操作：

```cj
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*

// 创建用户身份
let identity = ClaimsIdentity("Cookies")
identity.addClaim(ClaimTypes.name, "用户名")
identity.addClaim(ClaimTypes.role, "管理员")
let principal = ClaimsPrincipal(identity)

// 登录
let properties = AuthenticationProperties()
properties.isPersistent = true  // 持久化 Cookie
properties.expiresUtc = DateTime.now() + Duration.day * 30
await context.signInAsync(principal, properties)

// 登出
await context.signOutAsync()
```

### 配置事件回调

通过事件机制自定义身份验证流程：

```cj
services.addAuthentication()
    .addCookie() {
        options =>
        options.events.onSigningIn = {
            context =>
            // 登录前处理，如记录日志
            println("用户正在登录: ${context.principal.identity.name}")
        }
        options.events.onValidatePrincipal = {
            context =>
            // 验证主体，如检查用户是否被禁用
            if (shouldRejectUser(context.principal)) {
                context.rejectPrincipal()
            }
            // 标记需要续期
            context.shouldRenew = true
        }
        options.events.onCheckSlidingExpiration = {
            context =>
            // 自定义滑动过期逻辑
            if (context.remainingTime < Duration.minute * 30) {
                context.shouldRenew = true
            }
        }
        options.events.onRedirectToLogin = {
            context =>
            // 自定义未认证重定向逻辑
            if (isApiRequest(context.request)) {
                context.response.statusCode = StatusCodes.Unauthorized
            } else {
                context.response.redirect(context.redirectUri)
            }
        }
    }
```

### 使用服务端会话存储

当 Cookie 大小超过浏览器限制时，可使用服务端存储：

```cj
// 实现 ITicketStore 接口
class RedisTicketStore <: ITicketStore {
    func store(ticket: AuthenticationTicket): String {
        let key = generateSessionKey()
        // 存储到 Redis
        redis.set(key, serialize(ticket))
        return key
    }
    func renew(key: String, ticket: AuthenticationTicket): Unit {
        redis.set(key, serialize(ticket))
    }
    func retrieve(key: String): ?AuthenticationTicket {
        let data = redis.get(key)
        return data.map { d => deserialize(d) }
    }
    func remove(key: String): ?AuthenticationTicket {
        let ticket = retrieve(key)
        redis.del(key)
        return ticket
    }
}

// 配置使用自定义存储
services.addAuthentication()
    .addCookie() {
        options =>
        options.sessionStore = RedisTicketStore()
        // Cookie 中只存储会话 ID
        options.cookie.name = ".myapp.session"
    }
```

---

## API 参考

### CookieAuthenticationHandler

Cookie 身份验证处理器，实现完整的身份验证流程。

| 方法 | 说明 |
|------|------|
| `handleSignIn(user: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit` | 处理登录，创建并写入身份票据 Cookie |
| `handleSignOut(properties: ?AuthenticationProperties): Unit` | 处理登出，删除身份票据 Cookie |
| `handleAuthenticate(): AuthenticateResult` | 验证请求中的 Cookie，返回身份验证结果 |
| `handleChallenge(properties: AuthenticationProperties): Unit` | 处理未认证挑战，重定向到登录页 |
| `handleForbidden(properties: AuthenticationProperties): Unit` | 处理权限不足，重定向到拒绝访问页 |

### CookieAuthenticationOptions

Cookie 身份验证配置选项。

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `cookie` | `CookieBuilder` | `CookieBuilder()` | Cookie 构建器，配置名称、路径、域名等 |
| `slidingExpiration` | `Bool` | `false` | 是否启用滑动过期 |
| `expireTimeSpan` | `Duration` | `Duration.day * 14` | Cookie 过期时间跨度 |
| `events` | `CookieAuthenticationEvents` | `CookieAuthenticationEvents()` | 事件回调配置 |
| `sessionStore` | `?ITicketStore` | `None` | 服务端会话存储实现 |
| `dataProtector` | `?IDataProtector` | `None` | 数据保护器，用于加密票据 |
| `loginPath` | `PathString` | `/account/login` | 登录页路径 |
| `logoutPath` | `PathString` | `/account/logout` | 登出页路径 |
| `accessDeniedPath` | `PathString` | `/account/accessDenied` | 拒绝访问页路径 |
| `returnUrlParameter` | `String` | `"returnUrl"` | 返回 URL 参数名 |
| `cookieManager` | `ICookieManager` | `ChunkingCookieManager()` | Cookie 管理器 |
| `ticketDataFormat` | `?ISecureDataFormat<AuthenticationTicket>` | `None` | 票据序列化格式 |

### CookieAuthenticationEvents

身份验证事件回调配置。

| 属性 | 类型 | 说明 |
|------|------|------|
| `onSigningIn` | `(CookieSigningInContext) -> Unit` | 登录前回调 |
| `onSignedIn` | `(CookieSignedInContext) -> Unit` | 登录后回调 |
| `onSigningOut` | `(CookieSigningOutContext) -> Unit` | 登出前回调 |
| `onValidatePrincipal` | `(CookieValidatePrincipalContext) -> Unit` | 验证主体回调 |
| `onCheckSlidingExpiration` | `(CookieSlidingExpirationContext) -> Unit` | 检查滑动过期回调 |
| `onRedirectToLogin` | `(RedirectContext<CookieAuthenticationOptions>) -> Unit` | 重定向到登录页回调 |
| `onRedirectToAccessDenied` | `(RedirectContext<CookieAuthenticationOptions>) -> Unit` | 重定向到拒绝访问页回调 |
| `onRedirectToReturnUrl` | `(RedirectContext<CookieAuthenticationOptions>) -> Unit` | 重定向到返回 URL 回调 |

### ICookieManager

Cookie 管理器接口。

| 方法 | 说明 |
|------|------|
| `getRequestCookie(context: HttpContext, key: String): ?String` | 获取请求中的 Cookie 值 |
| `appendResponseCookie(context: HttpContext, key: String, value: ?String, options: CookieOptions): Unit` | 添加响应 Cookie |
| `deleteCookie(context: HttpContext, key: String, options: CookieOptions): Unit` | 删除 Cookie |

### ChunkingCookieManager

分块 Cookie 管理器实现，自动处理超大 Cookie。

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `chunkSize` | `?Int64` | `4050` | 单块大小限制 |
| `throwForPartialCookies` | `Bool` | `false` | 部分 Cookie 缺失时是否抛出异常 |

### ITicketStore

票据存储接口，用于服务端会话存储。

| 方法 | 说明 |
|------|------|
| `store(ticket: AuthenticationTicket): String` | 存储票据，返回存储键 |
| `renew(key: String, ticket: AuthenticationTicket): Unit` | 续期票据 |
| `retrieve(key: String): ?AuthenticationTicket` | 根据键检索票据 |
| `remove(key: String): ?AuthenticationTicket` | 删除票据 |

### CookieAuthenticationDefaults

Cookie 身份验证默认值常量。

| 常量 | 值 | 说明 |
|------|------|------|
| `Scheme` | `"Cookies"` | 默认身份验证方案名称 |
| `CookiePrefix` | `".cangjie."` | 默认 Cookie 名称前缀 |
| `LoginPath` | `PathString("/account/login")` | 默认登录路径 |
| `LogoutPath` | `PathString("/account/logout")` | 默认登出路径 |
| `AccessDeniedPath` | `PathString("/account/accessDenied")` | 默认拒绝访问路径 |
| `ReturnUrlParameter` | `"returnUrl"` | 默认返回 URL 参数名 |

### 扩展方法

#### CookieAuthenticationExtensions

为 `AuthenticationBuilder` 提供的扩展方法。

| 方法 | 说明 |
|------|------|
| `addCookie(): AuthenticationBuilder` | 添加默认配置的 Cookie 身份验证 |
| `addCookie(authenticationScheme: String): AuthenticationBuilder` | 使用指定方案名称添加 |
| `addCookie(configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder` | 使用配置回调添加 |
| `addCookie(authenticationScheme: String, configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder` | 使用方案名称和配置回调添加 |
| `addCookie(authenticationScheme: String, displayName: ?String, configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder` | 完整参数添加 |

---

## 相关包

- `soulsoft_web_http` - HTTP 核心功能，提供 HttpContext、Cookie 等基础类型
- `soulsoft_identity_claims` - 身份声明管理，提供 ClaimsPrincipal、ClaimsIdentity 等
- `soulsoft_web_authentication` - 身份验证抽象层，提供 AuthenticationHandler 基类
- `soulsoft_extensions_options` - 配置选项管理
- `soulsoft_extensions_logging` - 日志抽象
- `soulsoft_extensions_injection` - 依赖注入服务
- `soulsoft_extensions_protection` - 数据保护，提供 IDataProtector 加密接口

---

## 反馈与贡献

本项目由**灵软件 (Soul Software)** 开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
