# Soulsoft Identity Server

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-Cangjie-orange.svg)](https://www.codegeex.cn/)

基于 Cangjie 语言实现的企业级身份认证服务器，完全支持 OAuth 2.0 和 OpenID Connect (OIDC) 协议。为微服务架构提供统一的身份认证、授权和令牌管理能力。

## ✨ 特性

- 🔐 **协议支持**: OAuth 2.0 (RFC 6749/6750)、OpenID Connect Core 1.0、JWT (RFC 7519)
- 🚀 **授权流程**: Client Credentials、Resource Owner Password、Refresh Token、自定义扩展授权
- 🔑 **令牌管理**: Access Token、Refresh Token、ID Token，支持 RSA256/ECDSA256/HMAC 签名
- 🧩 **高扩展性**: 自定义授权类型、可插拔存储、自定义验证规则
- 🛡️ **企业安全**: 多种客户端认证、密钥加密存储、作用域权限控制

## 📖 核心概念

### 角色定义

| 角色 | 说明 | 示例 |
|------|------|------|
| **Client（客户端）** | 请求访问资源的应用程序 | Web应用、移动应用、后台服务 |
| **Resource Owner** | 资源所有者，通常是最终用户 | 登录的用户 |
| **Authorization Server** | 授权服务器，本项目核心 | Soulsoft Identity Server |
| **Resource Server** | 托管受保护资源的API服务器 | 订单服务、用户服务 |
| **Identity Provider (IdP)** | 身份提供者，认证来源 | local、wechat、google |

### 资源与权限

**ApiScope（API作用域）** - 细粒度权限单位
```
order.read, order.create, order.delete  → 具体操作权限
```

**ApiResource（API资源）** - API资源集合，包含多个Scope
```
order-api → [order.read, order.create, order.delete]
出现在 Access Token 的 aud（audience）声明中
```

**IdentityResource（身份资源）** - OIDC用户信息集合
```
openid → 必需，表示启用OIDC
profile → 用户资料（name, picture等）
email → 用户邮箱信息
```

**关系对比**:
- **ApiScope vs ApiResource**: 细粒度权限 vs 粗粒度资源集合
- **ApiResource vs IdentityResource**: OAuth 2.0 API访问权限 vs OIDC 用户身份信息

### 令牌类型

| 令牌 | 用途 | 生命周期 | 包含内容 |
|------|------|----------|----------|
| **Access Token** | 访问API资源 | 15-60分钟 | scope、aud、client_id |
| **Refresh Token** | 刷新访问令牌 | 7-30天 | 用于获取新Access Token |
| **ID Token** (OIDC) | 用户身份认证 | 5-15分钟 | 用户信息（name、email等） |

## 🚀 快速开始

### 1. 配置授权服务器

```cj
import soulsoft_identity_server.*

main() {
    let builder = WebApplicationBuilder.createDefault()

    builder.services.addIdentityServer({
        options =>
            options.issuer = "my-auth"
            options.issuerUri = "http://localhost:5000"
    })
    .addInMemoryClients([
        Client(
            clientId: "mobile-app",
            requireSecret: true,
            allowedGrantTypes: [GrantTypes.Password, GrantTypes.RefreshToken],
            allowedScopes: ["openid", "profile", "api.read"],
            allowedSecrets: [Secret(value: "secret".sha256())],
            refreshTokenUsage: RefreshTokenUsage.OneTimeOnly,  // 一次性使用
            refreshTokenExpiration: RefreshTokenExpiration.Sliding  // 滑动过期
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
    .addInMeorySigningCredentials([SigningCredentials(rsaKey, "RS256")])
    .addResourceOwnerPasswordValidator<MyPasswordValidator>()

    let app = builder.build()
    app.useIdentityServer()
    app.run()
}
```

### 2. 实现密码验证器

```cj
public class MyPasswordValidator <: IResourceOwnerPasswordValidator {
    public func validate(request: ResourceOwnerPasswordValidationRequest): ClaimsIdentity {
        if (request.username == "admin" && request.password == "password") {
            let identity = ClaimsIdentity()
            identity.addClaim(ClaimTypes.Subject, "user123")
            identity.addClaim(ClaimTypes.AuthTime, DateTime.now().toString())
            identity.addClaim(ClaimTypes.Amr, "pwd")
            identity.addClaim(ClaimTypes.Idp, "local")
            return identity
        }
        throw ValidationException(ValidationErrors.InvalidGrant, "Invalid credentials")
    }
}
```

### 3. 保护API资源（资源服务器）

API资源会通过`options.authority`获取发现文档，并且下载`JWK`公钥在本地完成令牌验证：

```cj
import soulsoft_web_hosting.*
import soulsoft_web_authentication_jwtbearer.*

main() {
    let builder = WebHost.createBuilder()

    // 配置JWT Bearer认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.authority = "http://localhost:5000"  // 授权服务器地址
            options.requireHttpsMetadata = false
            options.tokenValidationParameters.validateAudience = false
        }
    builder.services.addAuthorization()

    let host = builder.build()

    host.useRouting()
    host.useAuthentication()
    host.useAuthorization()

    // 受保护的端点
    host.mapGet("hello") { context =>
        context.response.write("hello")
    }.requireAuthorization()

    host.run("http://localhost:8080")
}
```

### 4. 获取和使用令牌

```bash
# 获取令牌
curl -X POST http://localhost:5000/connect/token \
  -d "grant_type=password" \
  -d "client_id=mobile-app" \
  -d "client_secret=secret" \
  -d "username=admin" \
  -d "password=password" \
  -d "scope=openid api.read"

# 响应
{
  "access_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "scope": "openid api.read"
}

# 访问受保护的API
curl -H "Authorization: Bearer eyJhbGc..." http://localhost:8080/hello
```

## 🔌 API端点

| 端点 | 路径 | 说明 |
|------|------|------|
| Token | `POST /connect/token` | 获取访问令牌 |
| UserInfo | `GET /connect/userinfo` | 获取用户信息 |
| Discovery | `GET /.well-known/openid-configuration` | OIDC发现文档 |
| JWKS | `GET /.well-known/openid-configuration/jwks` | 公钥集合 |

## 🔧 授权流程

### Client Credentials（机器对机器）
```bash
grant_type=client_credentials&scope=api.read
```
限制：不能请求 `openid` 和 `offline_access`

### Resource Owner Password（用户名密码）
```bash
grant_type=password&username=admin&password=***&scope=openid api.read
```

### Refresh Token（刷新令牌）
```bash
grant_type=refresh_token&refresh_token=***
```

### 自定义扩展授权
```cj
// 实现验证器
public class PhoneGrantValidator <: IExtensionGrantValidator {
    public prop grantType: String { get() { "phone" } }
    public func validate(request: ExtensionGrantValidationRequest): ClaimsIdentity {
        // 验证逻辑
    }
}

// 注册
builder.services.addIdentityServer(...)
    .addExtensionGrantValidator<PhoneGrantValidator>("phone")
```

## 🏗️ 架构设计

### 分布式微服务架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          客户端层 (Clients)                              │
├─────────────────┬─────────────────┬─────────────────┬──────────────────┤
│   Web 应用      │   移动应用      │   桌面应用      │   后台服务       │
│   (SPA/MVC)     │   (iOS/Android) │   (Electron)    │   (Service)      │
└────────┬────────┴────────┬────────┴────────┬────────┴────────┬─────────┘
         │                 │                 │                 │
         │ ① 请求令牌      │                 │                 │
         └─────────────────┼─────────────────┼─────────────────┘
                           ↓
         ┌─────────────────────────────────────────────────────┐
         │      🔐 Identity Server (授权服务器)                 │
         │      http://auth.example.com:5000                   │
         ├─────────────────────────────────────────────────────┤
         │  • 用户认证 (Password, Phone, Email)                │
         │  • 令牌颁发 (Access Token, Refresh Token, ID Token) │
         │  • 客户端验证 (Client Secret)                       │
         │  • Discovery 文档 / JWKS 公钥                       │
         ├─────────────────────────────────────────────────────┤
         │  Stores: Redis/MySQL/Memory                        │
         └────────┬────────────────────────────────────────────┘
                  │ ② 返回令牌
                  │ {access_token, refresh_token, id_token}
                  ↓
         ┌────────────────────────────────────────────────┐
         │         API Gateway (可选)                      │
         │         • 统一入口                              │
         │         • 令牌验证                              │
         │         • 路由转发                              │
         └────────┬───────────────────────────────────────┘
                  │ ③ Bearer Token
                  │
     ┌────────────┼────────────┬────────────┬─────────────┐
     ↓            ↓            ↓            ↓             ↓
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐
│ 订单服务 │ │ 商品服务 │ │ 用户服务 │ │ 支付服务 │ │ 通知服务  │
│ Order   │ │ Product │ │  User   │ │ Payment │ │ Notify   │
│ API     │ │  API    │ │  API    │ │  API    │ │  API     │
├─────────┤ ├─────────┤ ├─────────┤ ├─────────┤ ├──────────┤
│ :8001   │ │ :8002   │ │ :8003   │ │ :8004   │ │ :8005    │
├─────────┤ ├─────────┤ ├─────────┤ ├─────────┤ ├──────────┤
│ JWT验证 │ │ JWT验证 │ │ JWT验证 │ │ JWT验证 │ │ JWT验证  │
│ Scope:  │ │ Scope:  │ │ Scope:  │ │ Scope:  │ │ Scope:   │
│ order.* │ │product.*│ │ user.*  │ │payment.*│ │ notify.* │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘
     │           │           │           │           │
     │           │     ④ 验证 Token 签名               │
     │           └───────────┼───────────┴───────────┘
     │                       ↓
     │          ┌───────────────────────────┐
     │          │  获取 JWKS 公钥 (首次)     │
     │          │  GET /.well-known/         │
     │          │  openid-configuration/jwks │
     │          └───────────────────────────┘
     │
     └─────────────────────────────────────────┐
                                               ↓
                                    ┌─────────────────────┐
                                    │   数据库层           │
                                    ├─────────────────────┤
                                    │ MySQL / PostgreSQL  │
                                    │ MongoDB / Redis     │
                                    └─────────────────────┘

认证流程：
1️⃣  客户端向 Identity Server 请求令牌 (POST /connect/token)
2️⃣  Identity Server 验证后颁发 JWT 令牌
3️⃣  客户端携带 Access Token 访问微服务 API (Authorization: Bearer xxx)
4️⃣  微服务验证 Token 签名和权限 (scope/aud)，处理请求
```

### 服务器内部分层

```
HTTP Request
    ↓
Middleware (IdentityServerMiddleware)
    ↓
Endpoints (TokenEndpoint, UserInfoEndpoint)
    ↓
Validation (TokenRequestValidator, ClientSecretValidator)
    ↓
Services (AccessTokenService, RefreshTokenService)
    ↓
Stores (IClientStore, IRefreshTokenStore)
```

**核心组件**:
- **Models**: Client, AccessToken, RefreshToken, ApiScope, ApiResource
- **Services**: 令牌生成、密钥管理、资源管理、扩展授权
- **Validation**: 请求验证、客户端验证、令牌验证、资源权限验证
- **Stores**: 可插拔存储接口（内存/数据库/缓存）

## 🔐 安全最佳实践

1. **Refresh Token安全**
   - 使用 `RefreshTokenUsage.OneTimeOnly` 策略（一次性使用）
   - 配合 `RefreshTokenExpiration.Sliding`（滑动过期）
   - 推荐配置：15天滑动 + 30天绝对上限

2. **令牌生命周期**
   - Access Token: 15-60分钟
   - Refresh Token: 7-30天
   - ID Token: 5-15分钟

3. **客户端密钥**
   - 使用 SHA256 及以上哈希算法
   - 定期轮换密钥
   - 生产环境必须使用 HTTPS

4. **权限控制**
   - 遵循最小权限原则
   - 使用细粒度的 ApiScope
   - 为不同客户端配置不同权限

## 📁 项目结构

```
src/
├── constants/       # 常量定义
├── models/          # Client, Token, Resource模型
├── services/        # 令牌服务、密钥管理、资源管理
├── validation/      # 请求验证、令牌验证
├── stores/          # 存储接口及内存实现
├── endpoints/       # Token、UserInfo、Discovery端点
├── hosting/         # 中间件、路由
└── options/         # 配置选项
```

## 🗺️ 路线图

- [x] Client Credentials、Password、Refresh Token授权
- [x] UserInfo端点、Discovery文档
- [x] 自定义授权扩展
- [ ] Authorization Code授权
- [ ] PKCE支持
- [ ] 单点登录(SSO)
- [ ] 令牌撤销/自省端点

## 📖 参考

- [OAuth 2.0 - RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [JWT - RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)

## 📄 许可证

[MIT License](LICENSE)

## 反馈与贡献

soulsoft_identity_server 以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。
