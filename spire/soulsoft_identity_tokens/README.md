# soulsoft.identity.tokens

**安全令牌处理的核心类型库，为 JWT 等具体令牌实现提供密钥、签名与验证基础支撑。**
---

## 关于

`soulsoft.identity.tokens` 定义了安全令牌处理的核心抽象层：密钥体系（对称/RSA/ECDSA）、签名凭证、签名/验签 Provider 及验证参数配置。作为基础库，它不直接处理具体令牌格式（如 JWT），而是为上层实现提供统一的类型契约和加密工厂。

`CryptoProviderFactory` 基于 `ConcurrentHashMap` 和原子操作实现 SignatureProvider 对象池缓存，线程安全。

### 特性

| 特性 | 描述 |
|------|------|
| 🔑 **多种密钥类型** | `SymmetricSecurityKey`、`RsaSecurityKey`、`ECDsaSecurityKey`，支持从字节数组、PEM 或 JWK 构建 |
| ✍️ **签名与验签** | `SymmetricSignatureProvider`（HMAC）和 `AsymmetricSignatureProvider`（RSA/ECDSA）实现 `sign`/`verify` |
| 🏭 **缓存工厂** | `CryptoProviderFactory` 按 keyId 缓存 SignatureProvider，支持注入自定义加密提供者（HSM 等） |
| 🔧 **便捷工厂** | `SecurityKeyFactory` 提供从 PEM 字符串或文件直接创建 RSA/ECDSA 密钥的静态方法 |
| 🔄 **JWK 互转** | `JsonWebKeyConverter` 在 `SecurityKey` 与 JWK/JWKS JSON 之间双向转换 |
| 🛡️ **算法常量** | `SecurityAlgorithms` 提供 HS/RS/ES/PS 全系列标准算法标识符（256/384/512） |
| 📋 **验证参数** | `TokenValidationParameters` 配置颁发者、受众、生命周期、签名密钥等全套验证选项 |

---

## 如何使用

### 对称密钥签名与验签（HMAC）

```cj
import soulsoft_identity_tokens.*

// 创建 256-bit 对称密钥并绑定算法
let key = SymmetricSecurityKey(Array<Byte>(32, repeat: 0x42))
let creds = SigningCredentials(key, SecurityAlgorithms.HmacSha256)

// 通过 CryptoProviderFactory 创建 Provider（自动缓存）
let factory = CryptoProviderFactory.default
let provider = factory.createForSigning(key, SecurityAlgorithms.HmacSha256)

let input = "header.payload".toArray()
let signature = provider.sign(input)
let valid = provider.verify(input, signature)  // true

// 用完归还资源
factory.releaseSignatureProvider(provider)
```

### 非对称密钥签名与验签（RSA / ECDSA）

```cj
import soulsoft_identity_tokens.*

// 从 PEM 文件创建 RSA 密钥
let privKey = SecurityKeyFactory.createRsaPrivateKeyFromPemFile("private.pem")
let pubKey  = SecurityKeyFactory.createRsaPublicKeyFromPemFile("public.pem")

// 私钥签名，公钥验签
let signer   = AsymmetricSignatureProvider(privKey, SecurityAlgorithms.RsaSha256)
let verifier = AsymmetricSignatureProvider(pubKey,  SecurityAlgorithms.RsaSha256)
let data = "my payload".toArray()
let sig  = signer.sign(data)
let ok   = verifier.verify(data, sig)  // true

// ECDSA（P-256）
let ecPriv     = SecurityKeyFactory.createECDsaPrivateKey(ecPrivPem)
let ecPub      = SecurityKeyFactory.createECDsaPublicKey(ecPubPem)
let ecSigner   = AsymmetricSignatureProvider(ecPriv, SecurityAlgorithms.EcdsaSha256)
let ecVerifier = AsymmetricSignatureProvider(ecPub,  SecurityAlgorithms.EcdsaSha256)
```

### JWK / JWKS 处理

```cj
import soulsoft_identity_tokens.*

// 从 JSON 解析单个 JWK 并转换为 SecurityKey
let jwk    = JsonWebKey.create("""{"kty":"RSA","n":"...","e":"AQAB","kid":"key-1"}""")
let rsaKey = RsaSecurityKey(jwk)

// 解析 JWKS 并获取所有签名密钥
let jwks        = JsonWebKeySet.create("""{"keys":[...]}""")
let signingKeys = jwks.getSigningKeys()

// SecurityKey ↔ JWK 双向转换
let symKey    = SymmetricSecurityKey(Array<Byte>(32, repeat: 0))
let converted = JsonWebKeyConverter.convertFromSecurityKey(symKey)
let backKey   = JsonWebKeyConverter.convertToSecurityKey(converted)
```

---

## API 参考

### SecurityKey

| 属性 / 方法 | 说明 |
|-------------|------|
| `keyId: ?String` | 密钥标识符（kid），可为 `None` |
| `keySize: Int64` | 密钥位长度（如 `2048` 表示 2048-bit RSA） |
| `cryptoProviderFactory: CryptoProviderFactory` | 关联加密工厂，可替换为自定义实现 |
| `isSupportedAlgorithm(algorithm: String): Bool` | 判断密钥是否支持指定算法 |

### SymmetricSecurityKey

| 构造函数 / 属性 | 说明 |
|----------------|------|
| `init(key: Array<Byte>)` | 从原始字节构建 |
| `init(jsonWebKey: JsonWebKey)` | 从 JWK（`k` 字段 Base64Url）构建 |
| `key: Array<Byte>` | 原始密钥字节 |

### RsaSecurityKey

| 构造函数 / 方法 | 说明 |
|----------------|------|
| `init(publicKey!: ?RSAPublicKey, privateKey!: ?RSAPrivateKey)` | 从已有密钥对象构建 |
| `init(jsonWebKey: JsonWebKey)` | 从 RSA JWK 解析（含私钥字段时同时载入私钥） |
| `init(params: RsaParameters)` | 从 DER 参数结构构建 |
| `publicKey: ?RSAPublicKey` | 公钥对象 |
| `privateKey: ?RSAPrivateKey` | 私钥对象 |
| `exportParameters(includePrivateParameters: Bool): RsaParameters` | 导出密钥参数（用于 JWK 序列化） |

### ECDsaSecurityKey

| 构造函数 / 方法 | 说明 |
|----------------|------|
| `init(publicKey!: ?ECDSAPublicKey, privateKey!: ?ECDSAPrivateKey)` | 从已有密钥对象构建 |
| `init(jsonWebKey: JsonWebKey)` | 从 EC JWK 解析（支持 P-256/P-384/P-521） |
| `init(params: ECParameters)` | 从 ECParameters 结构构建 |
| `publicKey: ?ECDSAPublicKey` | 公钥对象 |
| `privateKey: ?ECDSAPrivateKey` | 私钥对象 |
| `exportParameters(includePrivateParameters: Bool): ECParameters` | 导出曲线坐标参数 |

### SigningCredentials

| 构造函数 / 属性 / 方法 | 说明 |
|-----------------------|------|
| `init(key: SecurityKey, algorithm: String)` | 绑定密钥与算法标识 |
| `key: SecurityKey` | 关联的安全密钥 |
| `algorithm: String` | 算法标识符（如 `"HS256"`） |
| `createSignatureProvider(): SignatureProvider` | 通过密钥关联工厂创建签名 Provider |

### SignatureProvider

| 属性 / 方法 | 说明 |
|------------|------|
| `key: SecurityKey` | 关联密钥 |
| `algorithm: String` | 算法标识符 |
| `willCreateSignatures: Bool` | `true` 签名模式，`false` 验签模式 |
| `sign(input: Array<Byte>): Array<Byte>` | 对输入数据签名 |
| `verify(input: Array<Byte>, signature: Array<Byte>): Bool` | 验证签名是否合法 |
| `close(): Unit` | 释放资源（幂等） |
| `isClosed(): Bool` | 是否已关闭 |

### CryptoProviderFactory

| 属性 / 方法 | 说明 |
|------------|------|
| `static default: CryptoProviderFactory` | 全局默认工厂实例（可替换） |
| `static defaultCacheSignatureProviders: Bool` | 全局缓存开关，默认 `true` |
| `cacheSignatureProviders: Bool` | 实例级缓存开关 |
| `customCryptoProvider: ?ICryptoProvider` | 自定义提供者，优先于内置实现 |
| `createForSigning(key: SecurityKey, algorithm: String): SignatureProvider` | 创建签名 Provider（需私钥） |
| `createForVerifying(key: SecurityKey, algorithm: String): SignatureProvider` | 创建验签 Provider（仅需公钥） |
| `releaseSignatureProvider(provider: SignatureProvider): Unit` | 归还 Provider |
| `isSupportedAlgorithm(algorithm: String, key: SecurityKey): Bool` | 判断算法与密钥的组合是否受支持 |

### SecurityKeyFactory

| 方法 | 说明 |
|------|------|
| `createSymmetricKey(key: Array<Byte>): SymmetricSecurityKey` | 从字节数组创建对称密钥 |
| `createSymmetricKey(text: String): SymmetricSecurityKey` | 从字符串创建对称密钥 |
| `createRsaPublicKey(pem: String): RsaSecurityKey` | 从 PEM 字符串创建 RSA 公钥 |
| `createRsaPrivateKey(pem: String): RsaSecurityKey` | 从 PEM 字符串创建 RSA 私钥 |
| `createRsaPublicKeyFromPemFile(path: String): RsaSecurityKey` | 从 PEM 文件创建 RSA 公钥 |
| `createRsaPrivateKeyFromPemFile(path: String): RsaSecurityKey` | 从 PEM 文件创建 RSA 私钥 |
| `createECDsaPublicKey(pem: String): ECDsaSecurityKey` | 从 PEM 字符串创建 ECDSA 公钥 |
| `createECDsaPrivateKey(pem: String): ECDsaSecurityKey` | 从 PEM 字符串创建 ECDSA 私钥 |
| `createECDsaPublicKeyFromPemFile(path: String): ECDsaSecurityKey` | 从 PEM 文件创建 ECDSA 公钥 |
| `createECDsaPrivateKeyFromPemFile(path: String): ECDsaSecurityKey` | 从 PEM 文件创建 ECDSA 私钥 |

### JsonWebKey

| 构造函数 / 属性 / 方法 | 说明 |
|-----------------------|------|
| `init(kty?, kid?, alg?, use?, n?, e?, k?, x?, y?, d?, crv?, x5c?, ...)` | 命名参数构造，所有字段均可选 |
| `static create(json: String): JsonWebKey` | 从 JSON 字符串解析 JWK |
| `keyId: ?String` | 代理 `kid` 字段 |
| `keySize: Int64` | 按 `kty` 自动计算密钥位长（`RSA`→`n`、`EC`→`x`、`oct`→`k`），未知时返回 `0` |
| `hasPrivateKey: Bool` | RSA 时检查 `d/dp/dq/p/q/qi`；EC 时检查 `d` |

### JsonWebKeySet

| 构造函数 / 属性 / 方法 | 说明 |
|-----------------------|------|
| `static create(json: String): JsonWebKeySet` | 从 JWKS JSON 字符串解析 |
| `keys: List<JsonWebKey>` | JWK 列表 |
| `getSigningKeys(): ReadOnlyList<SecurityKey>` | 将所有 RSA/EC/oct 类型 JWK 转换为 SecurityKey 列表 |

### JsonWebKeyConverter

| 方法 | 说明 |
|------|------|
| `convertFromSecurityKey(key: SecurityKey): JsonWebKey` | SecurityKey → JWK（自动识别类型） |
| `convertFromSymmetricSecurityKey(key: SymmetricSecurityKey, algorithm!: ?String): JsonWebKey` | 对称密钥 → JWK |
| `convertFromRsaSecurityKey(key: RsaSecurityKey, algorithm!: ?String): JsonWebKey` | RSA 密钥 → JWK |
| `convertFromECDsaSecurityKey(key: ECDsaSecurityKey, algorithm!: ?String): JsonWebKey` | ECDSA 密钥 → JWK |
| `convertFromSigningCredentials(signingCredentials: SigningCredentials): JsonWebKey` | 签名凭证 → JWK（携带 alg 字段） |
| `convertToSecurityKey(jsonWebKey: JsonWebKey): SecurityKey` | JWK → SecurityKey（结果内部缓存，避免重复构建） |

### SecurityAlgorithms

| 常量 | 值 |
|------|----|
| `HmacSha256` / `HmacSha384` / `HmacSha512` | `"HS256"` / `"HS384"` / `"HS512"` |
| `RsaSha256` / `RsaSha384` / `RsaSha512` | `"RS256"` / `"RS384"` / `"RS512"` |
| `EcdsaSha256` / `EcdsaSha384` / `EcdsaSha512` | `"ES256"` / `"ES384"` / `"ES512"` |
| `RsaSsaPssSha256` / `RsaSsaPssSha384` / `RsaSsaPssSha512` | `"PS256"` / `"PS384"` / `"PS512"` |

### Base64UrlEncoder

| 方法 | 说明 |
|------|------|
| `static encode(input: String): String` | 字符串 → Base64URL（无 padding） |
| `static encode(data: Array<Byte>): String` | 字节数组 → Base64URL |
| `static decodeBytes(input: String): ?Array<Byte>` | Base64URL → 字节数组，格式错误返回 `None` |
| `static decode(input: String): ?String` | Base64URL → UTF-8 字符串，格式错误返回 `None` |

### TokenValidationParameters

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `validateIssuer` | `Bool` | `true` | 是否验证颁发者 |
| `validateAudience` | `Bool` | `true` | 是否验证受众 |
| `validateLifetime` | `Bool` | `true` | 是否验证生命周期 |
| `validateIssuerSigningKey` | `Bool` | `true` | 是否验证签名密钥 |
| `requireAudience` | `Bool` | `true` | 是否要求受众字段 |
| `requireExpirationTime` | `Bool` | `true` | 是否要求过期时间 |
| `validateTokenReplay` | `Bool` | `false` | 是否验证令牌重放 |
| `clockSkew` | `Duration` | `Duration.Zero` | 允许的时钟偏差 |
| `validIssuers` | `Array<String>` | `[]` | 有效颁发者列表 |
| `validAudiences` | `Array<String>` | `[]` | 有效受众列表 |
| `issuerSigningKeys` | `Array<SecurityKey>` | `[]` | 签名验证用密钥列表 |
| `clone(): TokenValidationParameters` | — | — | 深拷贝验证参数 |

### TokenValidationResult

枚举类型，表示令牌验证结果。

| 变体 / 方法 | 说明 |
|------------|------|
| `Success(ClaimsIdentity, SecurityToken)` | 验证成功，携带身份声明和安全令牌 |
| `Failed(Exception)` | 验证失败，携带异常信息 |
| `isValid(): Bool` | 是否为 `Success` 变体 |

---

## 相关包

- `soulsoft_formats_asn1` — ASN.1 DER 编解码，用于 RSA/ECDSA 密钥的 DER 格式处理
- `soulsoft_identity_claims` — 声明式身份（`ClaimsIdentity` 等），用于令牌验证结果

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [AzureAD/azure-activedirectory-identitymodel-extensions-for-dotnet](https://github.com/AzureAD/azure-activedirectory-identitymodel-extensions-for-dotnet) 中的 Microsoft.IdentityModel.Tokens 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
