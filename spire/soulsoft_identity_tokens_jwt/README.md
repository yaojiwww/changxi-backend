# soulsoft.identity.tokens.jwt

**JSON Web Token (JWT) 创建、解析与验证的完整实现库。**
---

## 关于

`soulsoft.identity.tokens.jwt` 基于 `soulsoft_identity_tokens` 抽象包构建，提供 JWT 的完整实现。核心入口是 `JwtSecurityTokenHandler`，支持通过 `SecurityTokenDescriptor` 创建 Token、通过 `TokenValidationParameters` 验证签名和负载，以及通过 `readJwtToken` 直接解析原始 JWT 字符串。

同时提供了 `JwtHeader`、`JwtPayload`、`JwtSerializer` 等底层类型，满足对 JWT 结构的精细化操作需求。

### 特性

| 特性 | 描述 |
|------|------|
| 🔑 **对称密钥签名** | 支持 HS256 / HS384 / HS512，通过 `SymmetricSecurityKey` 配置 |
| 🔐 **RSA 签名** | 支持 RS256 / RS384 / RS512 及 PS256 / PS384 / PS512（PSS 模式） |
| 📐 **ECDSA 签名** | 支持 ES256 / ES384 / ES512，通过 `ECDsaSecurityKey` 加载 PEM 密钥 |
| ✅ **多维度验证** | 内置发行者、受众、生命周期、签名、Token 类型和 Token 重放验证 |
| 🔧 **可扩展验证器** | `TokenValidationParameters` 支持为每个验证维度注入自定义验证函数 |
| 📦 **负载声明映射** | `JwtPayload` 自动映射 `iss`、`aud`、`exp`、`nbf`、`iat`、`sub`、`jti` 等标准声明 |
| 🔄 **声明双向转换** | `toClaims()` 将 JWT 负载转换为 `Claim` 列表，支持 String / Int / Bool / Float 类型 |

---

## 如何使用

### 对称密钥（HMAC）

```cj
import std.time.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*

// 创建密钥和签名凭证
let key = SymmetricSecurityKey(Array<Byte>(32, repeat: 0x5A))
let creds = SigningCredentials(key, SecurityAlgorithms.HmacSha256)

// 构造 Token 描述符
let desc = SecurityTokenDescriptor(creds)
desc.issuer = Some("https://issuer.example.com")
desc.audience = Some("https://api.example.com")
desc.issuedAt = Some(DateTime.nowUTC())
desc.expires = Some(DateTime.nowUTC().addSeconds(3600))
desc.claims = [Claim("role", "admin")]

// 一步生成 JWT 字符串
let handler = JwtSecurityTokenHandler()
let jwt = handler.createEncodedJwt(desc)

// 配置验证参数
let params = TokenValidationParameters()
params.validateIssuer = true
params.validateAudience = true
params.validateLifetime = true
params.requireExpirationTime = true
params.validIssuers = ["https://issuer.example.com"]
params.validAudiences = ["https://api.example.com"]
params.issuerSigningKeys = [key]

// 验证并提取身份信息
let result = handler.validateToken(jwt, params)
match (result) {
    case TokenValidationResult.Success(identity, _) =>
        println("验证成功，claims 数量：${identity.claims.size}")
    case TokenValidationResult.Failed(e) =>
        println("验证失败：${e.message}")
}
```

### 非对称密钥（RSA / ECDSA）

```cj
import std.fs.*
import std.io.*
import std.time.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*

// 加载 RSA PEM 密钥（签名用私钥，验证用公钥）
let privPem = String.fromUtf8(File("rsa_priv.pem", OpenMode.Read) |> readToEnd)
let pubPem  = String.fromUtf8(File("rsa_pub.pem",  OpenMode.Read) |> readToEnd)
let privKey = RsaSecurityKey.fromPrivateKeyPem(privPem)
let pubKey  = RsaSecurityKey.fromPublicKeyPem(pubPem)

// 创建 Token（使用私钥签名）
let creds = SigningCredentials(privKey, SecurityAlgorithms.RsaSha256)
let desc  = SecurityTokenDescriptor(creds)
desc.issuer   = Some("https://issuer.example.com")
desc.audience = Some("https://api.example.com")
desc.expires  = Some(DateTime.nowUTC().addSeconds(3600))

let handler = JwtSecurityTokenHandler()
let jwt = handler.createEncodedJwt(desc)

// 验证（使用公钥验签）
let params = TokenValidationParameters()
params.validateIssuer = true
params.validateAudience = true
params.validateLifetime = true
params.validIssuers   = ["https://issuer.example.com"]
params.validAudiences = ["https://api.example.com"]
params.issuerSigningKeys = [pubKey]

match (handler.validateToken(jwt, params)) {
    case TokenValidationResult.Success(_, _) => println("RS256 验证通过")
    case TokenValidationResult.Failed(e)     => println("验证失败：${e.message}")
}
```

> ECDSA 场景将 `RsaSecurityKey` 替换为 `ECDsaSecurityKey`，算法改为 `SecurityAlgorithms.EcdsaSha256` 即可，用法完全一致。

### 解析原始 JWT 字符串

```cj
import soulsoft_identity_tokens_jwt.*

// 直接解析 JWT，不验证签名
let handler = JwtSecurityTokenHandler()
let token = handler.readJwtToken("eyJ...")

// 读取头部和负载字段
if (let Some(alg) <- token.header.alg) {
    println("算法：${alg}")
}
if (let Some(iss) <- token.payload.iss) {
    println("发行者：${iss}")
}
let audiences = token.payload.aud |> collectArray
println("受众数量：${audiences.size}")
```

---

## API 参考

### JwtSecurityTokenHandler

| 方法 | 说明 |
|------|------|
| `createToken(descriptor: SecurityTokenDescriptor): SecurityToken` | 根据描述符创建 `JwtSecurityToken` 实例 |
| `writeToken(securityToken: SecurityToken): String` | 将 `JwtSecurityToken` 序列化为签名的 JWT 字符串 |
| `createEncodedJwt(descriptor: SecurityTokenDescriptor): String` | 创建并序列化 JWT，等同于 `writeToken(createToken(descriptor))` |
| `validateToken(token: String, parameters: TokenValidationParameters): TokenValidationResult` | 验证 JWT 签名和负载，返回成功或失败结果 |
| `readJwtToken(token: String): JwtSecurityToken` | 解析 JWT 字符串为结构体，不验证签名 |

### JwtSecurityToken

| 属性 | 类型 | 说明 |
|------|------|------|
| `header` | `JwtHeader` | JWT 头部 |
| `payload` | `JwtPayload` | JWT 负载 |
| `segments` | `?JwtSegments` | 原始分段（解析时填充，创建时为 `None`） |
| `id` | `?String` | 对应负载中的 `jti` 字段 |
| `issuer` | `?String` | 对应负载中的 `iss` 字段 |
| `signingKey` | `?SecurityKey` | 来自头部签名凭证的密钥 |
| `signingCredentials` | `?SigningCredentials` | 头部签名凭证 |
| `signatureAlgorithm` | `?String` | 头部 `alg` 字段 |

### JwtPayload

| 属性/方法 | 类型/签名 | 说明 |
|-----------|-----------|------|
| `jti` | `?String` | JWT ID |
| `sub` | `?String` | 主体 |
| `iss` | `?String` | 发行者 |
| `aud` | `Collection<String>` | 受众列表 |
| `exp` | `?Int64` | 过期时间（Unix 秒） |
| `nbf` | `?Int64` | 生效时间（Unix 秒） |
| `iat` | `?Int64` | 签发时间（Unix 秒） |
| `nonce` | `?String` | 随机数 |
| `addClaim(claim: Claim): Unit` | — | 添加单个声明，自动按值类型转换 |
| `addClaims(claims: Collection<Claim>): Unit` | — | 批量添加声明 |

### JwtHeader

| 属性 | 类型 | 说明 |
|------|------|------|
| `typ` | `String` | Token 类型，默认 `"JWT"` |
| `alg` | `?String` | 签名算法 |
| `kid` | `?String` | 密钥 ID |
| `signingCredentials` | `?SigningCredentials` | 签名凭证 |

### JwtContent（抽象基类）

| 方法 | 说明 |
|------|------|
| `add(name: String, value: Any): ?Any` | 添加键值对，同名键自动合并为列表 |
| `get(name: String): ?Any` | 获取值，不存在返回 `None` |
| `contains(name: String): Bool` | 检查键是否存在 |
| `remove(name: String)` | 移除指定键 |
| `serializeToJson(): String` | 序列化为 JSON 字符串 |
| `base64UrlEncode(): String` | 序列化后进行 Base64Url 编码 |
| `toClaims(): ArrayList<Claim>` | 将所有键值转换为 `Claim` 列表 |

### JwtSerializer

| 方法 | 说明 |
|------|------|
| `deserialize(str: String): HashMap<String, Any>` | 将 JSON 字符串反序列化为 `HashMap` |
| `serialize(hashMap: HashMap<String, Any>): String` | 将 `HashMap` 序列化为 JSON 字符串 |

### JwtSegments

| 属性 | 类型 | 说明 |
|------|------|------|
| `header` | `String` | Base64Url 编码的头部 |
| `payload` | `String` | Base64Url 编码的负载 |
| `signature` | `String` | Base64Url 编码的签名 |
| `rawData` | `String` | 完整的原始 JWT 字符串 |

---

## 相关包

- `soulsoft_identity_tokens` — 安全令牌处理抽象层，定义 `SecurityToken`、`SecurityTokenHandler`、`TokenValidationParameters` 等核心接口
- `soulsoft_identity_claims` — 身份声明（Claim）类型定义，包含 `Claim`、`ClaimsIdentity`、`ClaimTypes` 等

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [microsoft/dotnet](https://github.com/dotnet/aspnetcore) 中的 `Microsoft.IdentityModel.Tokens` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
