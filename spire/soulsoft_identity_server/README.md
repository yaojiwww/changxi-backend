# soulsoft_identity_server

**身份认证服务器，支持 OAuth 2.0 和 OpenID Connect (OIDC) 协议，提供令牌颁发与验证能力。**


## 关于

`soulsoft_identity_server` 是基于仓颉语言实现的身份认证服务器，完全支持 OAuth 2.0 (RFC 6749/6750) 和 OpenID Connect Core 1.0 协议。核心接口包括 `IdentityServerBuilder`（服务构建器）、`TokenEndpoint`（令牌端点）、`UserInfoEndpoint`（用户信息端点）和 `DiscoveryEndpoint`（发现文档端点）。

`IdentityServerBuilder` 提供链式配置 API，支持内存存储和可插拔存储扩展。令牌服务支持 RSA-SHA256/384/512、ECDSA-SHA256/384/512、HMAC-SHA256/384/512 等签名算法。刷新令牌支持 `OneTimeOnly`（一次性）和 `ReUse`（可复用）两种使用策略，以及 `Sliding`（滑动过期）和 `Absolute`（绝对过期）两种过期策略。

`IClientStore`、`IApiScopeStore`、`IIdentityResourceStore` 等存储接口支持内存和分布式缓存实现。验证器接口 `IResourceOwnerPasswordValidator` 和 `IExtensionGrantValidator` 支持自定义授权类型扩展。

### 特性

| 特性 | 描述 |
|------|------|
| 🔐 **OAuth 2.0 + OIDC** | 支持 Authorization Code、Client Credentials、Password、Refresh Token 授权流程 |
| 🔑 **多签名算法** | RSA-SHA256/384/512、ECDSA-SHA256/384/512、HMAC-SHA256/384/512 |
| 🔄 **刷新令牌策略** | 支持 OneTimeOnly/ReUse 使用策略，Sliding/Absolute 过期策略 |
| 📦 **可插拔存储** | 内存存储、分布式缓存存储，支持自定义 IClientStore/IResourceStore |
| 🌐 **OIDC 发现端点** | 提供 `/.well-known/openid-configuration` 发现文档和 JWKS 公钥端点 |
| 🧩 **扩展授权** | 通过 IExtensionGrantValidator 支持自定义授权类型（如手机号、邮箱） |
| 🛡️ **客户端认证** | 支持 client_secret_post 和 client_secret_basic 两种认证方式 |

## 如何使用

### 基本配置

```cj
import soulsoft_web_hosting.*
import soulsoft_identity_server.*
import soulsoft_identity_server.models.*

main() {
    let builder = WebHost.createBuilder()

    // 配置签名密钥
    let rsaKey = RsaSecurityKey.fromPemFiles("rsa256_public.pem", "rsa256_private.pem")

    builder.services.addIdentityServer({
        options =>
            options.issuer = "soulsoft"
            options.issuerUri = "http://localhost:5000"
    })
    .addInMemoryClients([
        Client(
            clientId: "mobile-app",
            allowedGrantTypes: [GrantTypes.Password, GrantTypes.RefreshToken],
            allowedScopes: ["openid", "profile", "api.read"]
        )
    ])
    .addInMemoryApiScopes([
        ApiScope(name: "api.read"),
        ApiScope(name: "api.write")
    ])
    .addInMemoryIdentityResources([
        IdentityResource.openId(),
        IdentityResource.profile()
    ])
    .addInMemorySigningCredentials(
        [SigningCredentials(rsaKey, SecurityAlgorithms.RsaSha256)])
    .addPasswordGrantValidator<MyPasswordValidator>()

    let host = builder.build()
    host.useIdentityServer()
    host.run("http://localhost:5000")
}
```

### 实现密码验证器

```cj
import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

public class MyPasswordValidator <: IResourceOwnerPasswordValidator {
    public func validate(request: ResourceOwnerPasswordValidationRequest): IdentityUser {
        if (request.username == "admin" && request.password == "1024") {
            return IdentityUser("1024")
        }
        throw ValidationException(ValidationErrors.ServerError, "Invalid credentials")
    }
}
```

### 实现扩展授权验证器

```cj
import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

public class PhoneExtensionGrantValidator <: IExtensionGrantValidator {
    public prop grantType: String { get() { "phone" } }

    public func validate(request: ExtensionGrantValidationRequest): IdentityUser {
        let phone = request.parameters.get("phone").getOrThrow {
            ValidationException(ValidationErrors.ServerError, "Missing phone parameter")
        }
        let code = request.parameters.get("code").getOrThrow {
            ValidationException(ValidationErrors.ServerError, "Missing code parameter")
        }
        return IdentityUser("user-123")
    }
}

// 注册时
.addExtensionGrantValidator<PhoneExtensionGrantValidator>("phone")
```

### 实现用户信息服务

```cj
import soulsoft_identity_claims.*
import soulsoft_identity_server.services.*

public class ProfileService <: IProfileService {
    public func getProfileData(request: ProfileDataRequest): Collection<Claim> {
        let claims = ArrayList<Claim>()
        claims.add(Claim("name", "张三"))
        claims.add(Claim("email", "zhangsan@example.com"))
        return claims
    }
}

// 注册时
.addProfileService<ProfileService>()
```

## API 参考

### IdentityServerBuilder

| 方法 | 说明 |
|------|------|
| `addIdentityServer(configureOptions): IdentityServerBuilder` | 添加 Identity Server 服务 |
| `addInMemoryClients(clients: Collection<Client>): IdentityServerBuilder` | 添加内存客户端存储 |
| `addInMemoryApiScopes(apiScopes: Collection<ApiScope>): IdentityServerBuilder` | 添加内存 API 作用域存储 |
| `addInMemoryApiResources(apiResources: Collection<ApiResource>): IdentityServerBuilder` | 添加内存 API 资源存储 |
| `addInMemoryIdentityResources(identityResources: Collection<IdentityResource>): IdentityServerBuilder` | 添加内存身份资源存储 |
| `addInMemorySigningCredentials(credential: Collection<SigningCredentials>): IdentityServerBuilder` | 添加签名凭证 |
| `addPasswordGrantValidator<TValidator>(): IdentityServerBuilder` | 添加密码授权验证器 |
| `addExtensionGrantValidator<TValidator>(grantType: String): IdentityServerBuilder` | 添加扩展授权验证器 |
| `addProfileService<TProfileService>(): IdentityServerBuilder` | 添加用户信息服务 |

### Client

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `clientId` | `String` | `""` | 客户端唯一标识 |
| `allowedGrantTypes` | `Array<String>` | `[]` | 允许的授权类型 |
| `allowedScopes` | `Array<String>` | `[]` | 允许的作用域 |
| `refreshTokenUsage` | `RefreshTokenUsage` | `ReUse` | 刷新令牌使用策略 |
| `refreshTokenExpiration` | `RefreshTokenExpiration` | `Absolute` | 刷新令牌过期策略 |

### IdentityResource

| 方法 | 说明 |
|------|------|
| `IdentityResource(name: String, claimTypes: Array<String>)` | 创建身份资源 |
| `IdentityResource.openId(): IdentityResource` | 创建 OpenID 身份资源（sub） |
| `IdentityResource.profile(): IdentityResource` | 创建 Profile 身份资源 |

### Secret

| 属性 | 类型 | 说明 |
|------|------|------|
| `value` | `String` | 密钥值（通常使用 SHA256 哈希） |
| `expiration` | `?DateTime` | 过期时间 |

### IdentityUser

| 属性 | 类型 | 说明 |
|------|------|------|
| `sub` | `String` | 用户唯一标识（必填） |
| `amr` | `String` | 认证方法，默认 `"pwd"` |
| `idp` | `String` | 身份提供者，默认 `"local"` |

| 方法 | 说明 |
|------|------|
| `addClaim(type: String, value: String)` | 添加用户声明 |
| `toPrincipal(): ClaimsPrincipal` | 转换为 ClaimsPrincipal |

### 验证器接口

**IResourceOwnerPasswordValidator**
```cj
func validate(request: ResourceOwnerPasswordValidationRequest): IdentityUser
```

**IExtensionGrantValidator**
```cj
prop grantType: String
func validate(request: ExtensionGrantValidationRequest): IdentityUser
```

## 相关包

- `soulsoft_web_http` - HTTP 请求/响应处理
- `soulsoft_web_cors` - CORS 跨域支持
- `soulsoft_identity_claims` - 声明类型定义
- `soulsoft_identity_tokens` - 令牌模型与签名
- `soulsoft_identity_tokens_jwt` - JWT 令牌支持
- `soulsoft_identity_protocols_oidc` - OIDC 协议支持
- `soulsoft_web_authentication` - 认证中间件
- `soulsoft_extensions_injection` - 依赖注入
- `soulsoft_extensions_options` - 配置选项
- `soulsoft_extensions_caching` - 缓存支持

## 反馈与贡献

本项目由杭州颃创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
