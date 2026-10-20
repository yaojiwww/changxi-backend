# soulsoft.web.authentication.jwtbearer

**为 soulsoft 框架提供完整的 JWT Bearer 令牌认证解决方案。**
---

## 关于

soulsoft.web.authentication.jwtbearer 是一个专为 soulsoft 框架设计的 JWT Bearer 认证库。核心处理器 `JwtBearerHandler` 继承自 `AuthenticationHandler`，负责从 HTTP 请求中提取 Bearer 令牌、调用 `ISecurityTokenValidator` 完成签名与声明验证，并将验证结果转换为 `AuthenticationTicket`。支持通过应用配置文件或 OIDC 元数据端点自动加载验证参数，并通过 `JwtBearerEvents` 提供全流程事件钩子。

### 特性

| 特性 | 描述 |
|------|------|
| 🔐 **Bearer 令牌提取** | 自动从 `Authorization: Bearer <token>` 头或自定义 `MessageReceived` 事件中提取令牌 |
| ✅ **JWT 签名验证** | 通过 `JwtSecurityTokenHandler` 验证签名、有效期、颁发者、受众等参数 |
| 🌐 **OIDC 自动发现** | 配置 `authority` 后自动拉取 `.well-known/openid-configuration` 并定期刷新公钥 |
| ⚙️ **配置文件驱动** | 支持通过 `appsettings.json` 的 `authentication:schemes:<scheme>` 节点配置所有验证参数 |
| 🎣 **全流程事件钩子** | 提供 `onMessageReceived`、`onTokenValidated`、`onAuthenticationFailed`、`onChallenge`、`onForbidden` 五类事件 |
| 📋 **RFC 6750 质询响应** | 认证失败时按 RFC 6750 规范构建 `WWW-Authenticate` 响应头，含 `error` 和 `error_description` |
| 🔑 **密钥按需刷新** | 令牌验证失败时（`SecurityTokenValidationException`）自动请求配置管理器刷新签名密钥 |

---

## 如何使用

### 代码配置 JWT 认证

```cj
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_identity_claims.*
import std.time.*

// 1. 注册认证服务
builder.services.addAuthentication(JwtBearerDefaults.Scheme)
    .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
        let key = SymmetricSecurityKey("your-256-bit-secret-key-here".toArray())
        options.tokenValidationParameters.validIssuers = ["my-issuer"]
        options.tokenValidationParameters.validAudiences = ["my-audience"]
        options.tokenValidationParameters.issuerSigningKeys = [key]
        options.tokenValidationParameters.validateLifetime = true
    }

builder.services.addAuthorization()

// 2. 配置中间件管道
app.useRouting()
app.useAuthentication()
app.useAuthorization()

// 3. 受保护路由
app.mapGet("/protected") { context =>
    context.response.write("Hello, authenticated user!")
}.requireAuthorization()

// 4. 颁发令牌端点
app.mapPost("/token") { context =>
    let key = SymmetricSecurityKey("your-256-bit-secret-key-here".toArray())
    let creds = SigningCredentials(key, SecurityAlgorithms.HmacSha256)
    let desc = SecurityTokenDescriptor(creds)
    desc.issuer = Some("my-issuer")
    desc.audience = Some("my-audience")
    desc.expires = Some(DateTime.nowUTC().addSeconds(3600))

    let handler = JwtSecurityTokenHandler()
    let token = handler.createEncodedJwt(desc)
    context.response.write(token)
}
```

### 使用配置文件

无需代码指定密钥，直接调用 `addJwtBearer()` 并在配置文件中声明参数：

```cj
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*

builder.services.addAuthentication(JwtBearerDefaults.Scheme)
    .addJwtBearer(JwtBearerDefaults.Scheme)  // 从配置文件读取
```

`appsettings.json` 对应配置节点（方案名称大小写不敏感）：

```json
{
    "authentication": {
        "schemes": {
            "Bearer": {
                "validateIssuer": true,
                "validateAudience": true,
                "validateLifetime": true,
                "validIssuers": ["my-issuer"],
                "validAudiences": ["my-audience"],
                "signingKeys": [
                    {
                        "issuer": "my-issuer",
                        "value": "<Base64编码的密钥字节>"
                    }
                ]
            }
        }
    }
}
```

### 使用 OIDC 自动发现

配置 `authority` 后，库会自动拼接 `.well-known/openid-configuration` 并定期刷新公钥：

```cj
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*

builder.services.addAuthentication(JwtBearerDefaults.Scheme)
    .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
        options.authority = "https://your-identity-provider.com"
        // requireHttpsMetadata 默认为 true，开发环境可设为 false
    }
```

### 自定义事件钩子

```cj
import soulsoft_web_authentication_jwtbearer.*

builder.services.addAuthentication(JwtBearerDefaults.Scheme)
    .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
        // 从非标准位置（如 Query String）提取令牌
        options.events.onMessageReceived = { context =>
            context.token = context.request.query["access_token"]
        }

        // 令牌验证成功后的回调
        options.events.onTokenValidated = { context =>
            // 可访问 context.principal 和 context.securityToken
        }

        // 认证失败时的回调
        options.events.onAuthenticationFailed = { context =>
            // context.exception 包含失败原因
        }
    }
```

---

## API 参考

### JwtBearerHandler

| 方法 | 说明 |
|------|------|
| `handleAuthenticate(): AuthenticateResult` | 提取并验证 Bearer 令牌，返回认证结果 |
| `handleChallenge(properties: AuthenticationProperties): Unit` | 认证失败时发送 401 和 RFC 6750 规范的 `WWW-Authenticate` 头 |
| `handleForbidden(properties: AuthenticationProperties): Unit` | 授权失败时发送 403 响应 |

### JwtBearerOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `saveToken` | `Bool` | `true` | 验证成功后将令牌存入 `AuthenticationProperties` |
| `authority` | `String` | `""` | OIDC 颁发者地址，自动拼接 `/.well-known/openid-configuration` |
| `metadataAddress` | `String` | `""` | 直接指定元数据端点 URL，优先于 `authority` |
| `requireHttpsMetadata` | `Bool` | `true` | 是否要求元数据端点使用 HTTPS |
| `includeErrorDetails` | `Bool` | `true` | 质询响应是否包含 `error_description` |
| `challenge` | `String` | `"Bearer"` | `WWW-Authenticate` 头的方案名称 |
| `refreshOnIssuerKeyNotFound` | `Bool` | `true` | 签名验证失败时是否自动刷新密钥 |
| `backchannelTimeout` | `Duration` | `Duration.minute * 1` | 拉取元数据的 HTTP 超时时间 |
| `tokenValidationParameters` | `TokenValidationParameters` | 默认实例 | JWT 验证参数（颁发者、受众、密钥、生命周期等） |
| `securityTokenValidators` | `List<ISecurityTokenValidator>` | `[JwtSecurityTokenHandler()]` | 令牌验证器列表 |
| `events` | `JwtBearerEvents` | 默认实例 | 认证事件回调集合 |

### JwtBearerEvents

| 事件属性 | 类型 | 触发时机 |
|----------|------|----------|
| `onMessageReceived` | `?(MessageReceivedContext) -> ?String` | 令牌提取阶段，可覆盖默认的 Header 提取逻辑 |
| `onTokenValidated` | `?(TokenValidatedContext) -> ?String` | 令牌验证成功后 |
| `onAuthenticationFailed` | `?(AuthenticationFailedContext) -> ?String` | 令牌验证失败时 |
| `onChallenge` | `?(JwtBearerChallengeContext) -> Unit` | 发送 401 质询前，可调用 `context.handleResponse()` 阻止默认响应 |
| `onForbidden` | `?(ForbiddenContext) -> Unit` | 发送 403 响应时 |

### JwtBearerDefaults

| 常量 | 值 | 说明 |
|------|----|------|
| `Scheme` | `"Bearer"` | 默认认证方案名称 |

### JwtBearerBuilderExtensions

扩展 `AuthenticationBuilder` 的注册方法：

| 方法 | 说明 |
|------|------|
| `addJwtBearer(): AuthenticationBuilder` | 使用默认方案名 `"Bearer"` 注册，从配置读取选项 |
| `addJwtBearer(configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder` | 使用默认方案名，通过回调配置选项 |
| `addJwtBearer(authenticateScheme: String): AuthenticationBuilder` | 指定方案名注册 |
| `addJwtBearer(authenticateScheme: String, configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder` | 指定方案名并配置选项 |
| `addJwtBearer(authenticateScheme: String, displayName: ?String, configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder` | 完整签名，支持显示名称 |

---

## 相关包

- `soulsoft_web_authentication` - Web 认证基础框架，提供 `AuthenticationHandler`、`AuthenticationBuilder` 等核心抽象
- `soulsoft_identity_tokens` - 安全令牌基础类型，含 `SecurityToken`、`TokenValidationParameters`、`SecurityKey`
- `soulsoft_identity_tokens_jwt` - JWT 实现，提供 `JwtSecurityTokenHandler` 和 `SecurityTokenDescriptor`
- `soulsoft_identity_protocols_oidc` - OpenID Connect 协议支持，含 `OpenIdConnectConfiguration` 和配置管理器
- `soulsoft_identity_claims` - Claims 身份模型，提供 `ClaimsPrincipal`、`ClaimsIdentity`、`Claim`
- `soulsoft_extensions_options` - 选项模式框架，含 `IOptionsMonitor`、`IConfigureNamedOptions`
- `soulsoft_extensions_logging` - 日志抽象，提供 `ILoggerFactory`
- `soulsoft_extensions_configuration` - 配置读取，支持从 `appsettings.json` 加载认证参数

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [dotnet/aspnetcore](https://github.com/dotnet/aspnetcore) 中的 `JwtBearer` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
