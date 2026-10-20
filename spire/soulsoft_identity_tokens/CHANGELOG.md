# CHANGELOG — soulsoft.identity.tokens

## v1.1.0 - 2026-03-10

### Breaking Changes

- **`JsonWebKey.x5c`** 类型由 `?String` 变更为 `Array<String>`，与 RFC 7517 Section 4.7 规范（x5c 为 X.509 证书链数组）对齐；迁移方式：将 `Option<String>` 的模式匹配改为遍历数组，空证书链用 `[]` 替代 `None`

- **`SecurityKeyHelper`** 类已删除；迁移方式：改用各密钥类的静态工厂方法（`RsaSecurityKey.fromPublicKeyPemFile()`、`ECDsaSecurityKey.fromPrivateKeyPemFile()` 等）

- **`SecurityKeyFactory`** 类已删除（在本版本开发周期内引入后移除）；PEM 加载功能已内联到各密钥类：`RsaSecurityKey.fromPublicKeyPem()`、`RsaSecurityKey.fromPrivateKeyPem()`、`RsaSecurityKey.fromPemFiles()`、`ECDsaSecurityKey.fromPublicKeyPem()`、`ECDsaSecurityKey.fromPrivateKeyPem()`、`ECDsaSecurityKey.fromPemFiles()`；迁移方式：将 `SecurityKeyFactory.createRsaXxx()` 替换为 `RsaSecurityKey.fromXxx()`，将 `SecurityKeyFactory.createECDsaXxx()` 替换为 `ECDsaSecurityKey.fromXxx()`，将 `SecurityKeyFactory.createSymmetricKey()` 替换为 `SymmetricSecurityKey()` 构造函数

- **`AsymmetricSignatureProvider.getECDsaPrivateKey()`**、**`getECDsaPublicKey()`**、**`getRsaPrivateKey()`**、**`getRsaPublicKey()`** 由 `public` 改为 `private`，不再对外暴露；迁移方式：通过 `key` 属性直接转型到具体密钥类（`ECDsaSecurityKey` / `RsaSecurityKey`）

- **`ECDsaSecurityKey.exportParameters(): ?ECParameters`** → **`exportParameters(includePrivateParameters: Bool): ECParameters`**；迁移方式：传入 `false` 获取公钥参数，传入 `true` 获取含私钥的完整参数；返回值不再为 `Option` 类型，无法导出时直接抛出 `IllegalArgumentException`

- **`RsaSecurityKey.exportParameters(): ?RsaParameters`** → **`exportParameters(includePrivateParameters: Bool): RsaParameters`**；迁移方式同上

- **`RsaParameters` 构造函数** 字段 `exponent` / `modulus` 类型由 `?Array<Byte>` 改为 `Array<Byte>`（非 Option）；迁移方式：直接传入字节数组，移除 `Some(...)` 包装；私钥字段（`d`、`p`、`q`、`dp`、`dq`、`inverseQ`）仍为 `?Array<Byte>`

### Added

- **`SecurityKey.isSupportedAlgorithm(algorithm: String): Bool`** — 委托 `SupportedAlgorithms` 判断密钥是否支持指定算法，子类可 override 收窄范围
- **`SecurityKey.cryptoProviderFactory: CryptoProviderFactory`** — 可替换的加密工厂，支持注入自定义缓存策略或 HSM 实现
- **`SignatureProvider.willCreateSignatures: Bool`** — 标识此 Provider 用于签名（需要私钥）还是验签（仅需公钥）
- **`SignatureProvider.isClosed(): Bool`** / **`close(): Unit`** — 实现 `Resource` 接口，支持 `try-with-resources` 和对象池安全归还，`close()` 保证幂等
- **`SignatureProvider.createSignatureProvider(): SignatureProvider`** — 委托关联密钥的 `CryptoProviderFactory` 创建新 Provider
- 新增 **`CryptoProviderFactory`** — 加密 Provider 的创建与缓存工厂，提供全局 `default` 单例
- 新增 **`ICryptoProvider`** — 加密 Provider 的抽象接口
- 新增 **`SupportedAlgorithms`** — 集中管理各算法与密钥类型的兼容性映射
- 新增 **`ECDsaAdapter`** — ECDsa 曲线 OID 与 JWK `crv` 名称互转工具（替代已删除的 `CryptoHelper`）
- **`ECDsaSecurityKey.init(JsonWebKey)`** — 直接从 JWK 构建 ECDsa 密钥（自动解析 `crv`/`x`/`y`/`d` 字段）
- **`ECDsaSecurityKey.init(ECParameters)`** — 从原始曲线参数构建 ECDsa 密钥，支持仅公钥（无 `d`）或完整密钥对
- **`RsaSecurityKey.init(JsonWebKey)`** — 直接从 JWK 构建 RSA 密钥（自动解析 `n`/`e` 及完整私钥参数）
- **`AsymmetricSignatureProvider`** 新增 RSA-PSS 签名/验签支持：`PS256`（`RsaSsaPssSha256`）、`PS384`、`PS512`
- **`RsaSecurityKey.fromPublicKeyPem(pem: String): RsaSecurityKey`** — 从 PEM 字符串加载 RSA 公钥
- **`RsaSecurityKey.fromPrivateKeyPem(pem: String): RsaSecurityKey`** — 从 PEM 字符串加载 RSA 私钥
- **`RsaSecurityKey.fromPublicKeyPemFile(path: String): RsaSecurityKey`** — 从文件路径加载 RSA 公钥
- **`RsaSecurityKey.fromPrivateKeyPemFile(path: String): RsaSecurityKey`** — 从文件路径加载 RSA 私钥
- **`RsaSecurityKey.fromPemFiles(publicKeyPath: String, privateKeyPath: String): RsaSecurityKey`** — 同时加载公钥和私钥 PEM 文件，构造完整密钥对
- **`ECDsaSecurityKey.fromPublicKeyPem(pem: String): ECDsaSecurityKey`** — 从 PEM 字符串加载 ECDsa 公钥
- **`ECDsaSecurityKey.fromPrivateKeyPem(pem: String): ECDsaSecurityKey`** — 从 PEM 字符串加载 ECDsa 私钥
- **`ECDsaSecurityKey.fromPublicKeyPemFile(path: String): ECDsaSecurityKey`** — 从文件路径加载 ECDsa 公钥
- **`ECDsaSecurityKey.fromPrivateKeyPemFile(path: String): ECDsaSecurityKey`** — 从文件路径加载 ECDsa 私钥
- **`ECDsaSecurityKey.fromPemFiles(publicKeyPath: String, privateKeyPath: String): ECDsaSecurityKey`** — 同时加载公钥和私钥 PEM 文件，构造完整密钥对
- **`SymmetricSecurityKey.init(text: String)`** — 将 UTF-8 字符串作为原始字节密钥使用，等价于 `init(text.toArray())`

### Fixed

- **`JsonWebKeySerializer`** — `x5c` 反序列化由单字符串改为 JSON 数组解析；序列化输出由单 `JsonString` 改为 `JsonArray`，空数组时自动跳过该字段
- **`JsonWebKeySet`** — 将 `stdx.crypto.x509.*` 替换为 `stdx.crypto.common.*`，修复编译时的模块依赖错误
- **`SymmetricSecurityKey.init(key: Array<Byte>)`** / **`init(text: String)`** — 传入空字节数组或空字符串时抛出 `IllegalArgumentException("IDX10703: The SymmetricKey cannot have zero length.")`，对齐 C# Microsoft.IdentityModel IDX10703 行为；之前版本会静默接受空密钥，导致后续签名操作产生不可预期的错误

---

## v1.0.0

初始发布。
