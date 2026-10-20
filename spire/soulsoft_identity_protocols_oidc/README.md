# soulsoft.identity.protocols.oidc

**OpenID Connect 协议核心类型库，提供配置模型、元数据常量与发现文档检索器。**
---

## 关于

soulsoft.identity.protocols.oidc 是处理 OpenID Connect (OIDC) 协议的抽象基础库。核心类型 `OpenIdConnectConfiguration` 支持从 OIDC 发现文档（`.well-known/openid-configuration`）的 JSON 字符串解析配置，并可序列化回 JSON；`OpenIdConnectConfigurationRetriever` 实现 `IConfigurationRetriever<OpenIdConnectConfiguration>` 接口，通过 `IDocumentRetriever` 获取远程发现文档并自动解析 JWKS 签名密钥。此外，库中还包含 OIDC 协议标准常量定义，供上层协议处理组件统一引用。

### 特性

| 特性 | 描述 |
|------|------|
| 📄 **发现文档解析** | `OpenIdConnectConfiguration.create(json)` 将 OIDC 发现文档 JSON 反序列化为强类型配置对象 |
| 📝 **配置序列化** | `OpenIdConnectConfiguration.write(config)` 将配置对象序列化为 JSON，空字段和空列表自动省略 |
| 🔑 **JWKS 自动获取** | `OpenIdConnectConfigurationRetriever` 在解析发现文档后，自动获取 `jwks_uri` 指向的密钥集并填充 `signingKeys` |
| 📌 **元数据名称常量** | `OpenIdProviderMetadataNames` 定义所有 OIDC Provider 元数据 JSON 字段名，避免魔法字符串 |
| 🔖 **参数名称常量** | `OpenIdConnectParameterNames` 定义 OIDC 请求/响应参数名（如 `code`、`state`、`nonce` 等） |
| 🎯 **作用域与授权类型常量** | `OpenIdConnectScopes` 和 `OpenIdConnectGrantTypes` 提供标准 scope 与 grant_type 字符串常量 |

## 如何使用

### 解析与序列化配置

```cj
import soulsoft_identity_protocols_oidc.*

// 从 OIDC 发现文档 JSON 解析配置
let json = "{\"issuer\":\"https://idp.example.com\",\"authorization_endpoint\":\"https://idp.example.com/auth\",\"scopes_supported\":[\"openid\",\"profile\",\"email\"]}"
let config = OpenIdConnectConfiguration.create(json)

println(config.issuer)               // https://idp.example.com
println(config.authorizationEndpoint) // https://idp.example.com/auth
println(config.scopesSupported.size) // 3

// 手动构造配置并序列化
let newConfig = OpenIdConnectConfiguration()
newConfig.issuer = "https://my-idp.example.com"
newConfig.tokenEndpoint = "https://my-idp.example.com/token"
newConfig.scopesSupported.add(OpenIdConnectScopes.OpenId)
newConfig.scopesSupported.add(OpenIdConnectScopes.Profile)

let output = OpenIdConnectConfiguration.write(newConfig)
// 空字段自动省略，布尔字段始终输出
```

### 获取远程 OIDC 配置

```cj
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_protocols.*

// 使用 HttpDocumentRetriever 从远程端点获取配置
let retriever = OpenIdConnectConfigurationRetriever()
let httpRetriever = HttpDocumentRetriever()

let config = retriever.get(
    "https://idp.example.com/.well-known/openid-configuration",
    httpRetriever
)

// 若发现文档包含 jwks_uri，签名密钥会被自动填充
println(config.issuer)
println(config.signingKeys.size)
```

### 使用常量构造请求参数

```cj
import soulsoft_identity_protocols_oidc.*

// 构造授权请求时引用常量，避免拼写错误
let params = HashMap<String, String>()
params[OpenIdConnectParameterNames.ResponseType] = "code"
params[OpenIdConnectParameterNames.Scope] = OpenIdConnectScopes.OpenId + " " + OpenIdConnectScopes.Profile
params[OpenIdConnectParameterNames.State] = "random_state_value"
params[OpenIdConnectParameterNames.Nonce] = "random_nonce_value"
params[OpenIdConnectParameterNames.RedirectUri] = "https://myapp.example.com/callback"

// 检查 grant type
let grantType = OpenIdConnectGrantTypes.AuthorizationCode // "authorization_code"
```

## API 参考

### OpenIdConnectConfiguration

| 方法 | 说明 |
|------|------|
| `static create(json: String): OpenIdConnectConfiguration` | 从 OIDC 发现文档 JSON 字符串解析配置对象 |
| `static write(configuration: OpenIdConnectConfiguration): String` | 将配置对象序列化为 JSON 字符串，空字段和空列表自动省略 |

**主要属性（均为 `public var`）：**

| 属性 | 类型 | 说明 |
|------|------|------|
| `issuer` | `String` | 发行者标识，通常为 IdP 的 URL |
| `authorizationEndpoint` | `String` | 授权端点 URL |
| `tokenEndpoint` | `String` | 令牌端点 URL |
| `userInfoEndpoint` | `String` | 用户信息端点 URL |
| `jwksUri` | `String` | JSON Web Key Set URI |
| `endSessionEndpoint` | `String` | 结束会话端点 URL |
| `revocationEndpoint` | `String` | 令牌撤销端点 URL |
| `introspectionEndpoint` | `String` | Token Introspection 端点 URL |
| `signingKeys` | `List<SecurityKey>` | 签名密钥集合，由检索器自动填充 |
| `scopesSupported` | `List<String>` | 支持的作用域列表 |
| `responseTypesSupported` | `List<String>` | 支持的响应类型列表 |
| `claimsSupported` | `List<String>` | 支持的声明列表 |
| `grantTypesSupported` | `List<String>` | 支持的授权类型列表 |
| `claimsParameterSupported` | `Bool` | 是否支持 claims 参数 |
| `requestParameterSupported` | `Bool` | 是否支持 request 参数 |
| `additionalData` | `HashMap<String, Any>` | 保存未定义的额外字段 |

### OpenIdConnectConfigurationRetriever

| 方法 | 说明 |
|------|------|
| `get(address: String, retriever: IDocumentRetriever): OpenIdConnectConfiguration` | 从指定地址获取发现文档，解析配置并自动填充 JWKS 签名密钥 |
| `getConfiguration(address: String, documentRetriever: IDocumentRetriever): OpenIdConnectConfiguration` | 同 `get`，实现 `IConfigurationRetriever` 接口 |

### OpenIdConnectParameterNames

常量类，定义 OIDC 请求/响应参数名称字符串，包括 `AccessToken`、`Code`、`State`、`Nonce`、`Scope`、`RedirectUri`、`GrantType`、`IdToken`、`RefreshToken`、`CodeChallenge`、`CodeChallengeMethod` 等。

### OpenIdProviderMetadataNames

常量类，定义 OIDC 发现文档 JSON 字段名，包含 `Issuer`、`AuthorizationEndpoint`、`TokenEndpoint`、`JwksUri`、`Discovery`（`.well-known/openid-configuration`）等所有标准元数据字段名。

### OpenIdConnectScopes

| 常量 | 值 |
|------|----|
| `OpenId` | `"openid"` |
| `Profile` | `"profile"` |
| `Email` | `"email"` |
| `Address` | `"address"` |
| `Phone` | `"phone"` |
| `OfflineAccess` | `"offline_access"` |
| `UserImpersonation` | `"user_impersonation"` |

### OpenIdConnectGrantTypes

| 常量 | 值 |
|------|----|
| `AuthorizationCode` | `"authorization_code"` |
| `RefreshToken` | `"refresh_token"` |
| `Password` | `"password"` |
| `ClientCredentials` | `"client_credentials"` |

## 相关包

- `soulsoft_identity_protocols` - 身份验证协议基础抽象，提供 `IConfigurationRetriever`、`IDocumentRetriever` 等接口
- `soulsoft_identity_tokens` - JWT/JWK 令牌处理，提供 `JsonWebKeySet`、`SecurityKey` 等类型

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

## 开源声明

本库的核心实现参考了 [microsoft/azure-activedirectory-identitymodel-extensions-for-dotnet](https://github.com/AzureAD/azure-activedirectory-identitymodel-extensions-for-dotnet) 中的 OpenIdConnect 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。
