# soulsoft.identity.claims

**声明式身份验证核心库，提供 Claim、ClaimsIdentity、ClaimsPrincipal 三层身份模型及标准声明类型常量。**
---

## 关于

`soulsoft.identity.claims` 是 ASP.NET Core 声明式身份验证模型的仓颉移植版，实现了 `Claim`（单条声明）、`ClaimsIdentity`（身份）、`ClaimsPrincipal`（主体）三层结构。库内置 JWT（RFC 7519）、OpenID Connect、OAuth、角色权限等标准声明类型常量（`ClaimTypes`），以及基于 XML Schema / SOAP 规范的声明值类型常量（`ClaimValueTypes`）。所有核心类型均实现了 `Serializable` 接口，支持完整的序列化/反序列化往返。

### 特性

| 特性 | 描述 |
|------|------|
| 🪪 **三层身份模型** | `Claim` → `ClaimsIdentity` → `ClaimsPrincipal`，与 ASP.NET Core 身份验证模型保持一致 |
| 🔍 **灵活查询** | `findAll`、`findFirst`、`findFirstValue` 支持按类型字符串或自定义谓词筛选，跨 identity 聚合 |
| ✅ **角色检查** | `ClaimsPrincipal.isInRole` 基于 `ClaimTypes.Role` 声明跨 identity 做角色判断 |
| 📋 **标准常量** | `ClaimTypes` 覆盖 JWT、OIDC、OAuth、角色/权限、租户等 40+ 常量；`ClaimValueTypes` 覆盖 XML Schema 20+ 类型 |
| 🔄 **序列化支持** | 三个核心类均实现 `Serializable`，支持 `serialize()` / `deserialize()` 往返 |
| 🧬 **深拷贝** | `ClaimsIdentity.clone()` 与 `ClaimsPrincipal.clone()` 返回完全独立的副本 |
| 🎛️ **可扩展主体选择器** | `ClaimsPrincipal.setPrimaryIdentitySelector` 允许自定义首选 identity 的选取策略 |

---

## 如何使用

### 构建声明与身份

```cj
import soulsoft_identity_claims.*

// 创建单条声明
let subClaim = Claim(ClaimTypes.Sub, "user-001")
let roleClaim = Claim(ClaimTypes.Role, "admin")
let emailClaim = Claim(ClaimTypes.Email, "user@example.com", ClaimValueTypes.Email)

// 创建已认证身份
let identity = ClaimsIdentity(Some("Bearer"))
identity.addClaim(subClaim)
identity.addClaim(roleClaim)
identity.addClaim("age", "30", ClaimValueTypes.Integer)

// 批量添加
let extraClaims: Array<Claim> = [emailClaim, Claim(ClaimTypes.Name, "张三")]
identity.addClaims(extraClaims)

// 检查认证状态
println(identity.isAuthenticated)       // true
println(identity.authenticationType)   // Some("Bearer")
```

### 构建主体与查询

```cj
import soulsoft_identity_claims.*

let id1 = ClaimsIdentity(Some("Bearer"))
id1.addClaim(ClaimTypes.Sub, "user-001")
id1.addClaim(ClaimTypes.Role, "admin")

let id2 = ClaimsIdentity(Some("Cookie"))
id2.addClaim(ClaimTypes.Role, "editor")
id2.addClaim(ClaimTypes.Email, "user@example.com")

let principal = ClaimsPrincipal([id1, id2])

// 跨 identity 聚合查询
let allRoles = principal.findAll(ClaimTypes.Role)          // [admin, editor]
let email = principal.findFirstValue(ClaimTypes.Email)     // Some("user@example.com")

// 角色检查
println(principal.isInRole("admin"))    // true
println(principal.isInRole("guest"))    // false

// 断言式检查
println(principal.hasClaim(ClaimTypes.Sub, "user-001"))  // true

// 获取主 identity（默认取第一个）
if (let Some(primaryId) <- principal.identity) {
    println(primaryId.authenticationType)  // Some("Bearer")
}
```

### 克隆与自定义选择器

```cj
import soulsoft_identity_claims.*

// 深拷贝 principal，修改副本不影响原对象
let original = ClaimsPrincipal([id1])
let cloned = original.clone()
cloned.addIdentity(ClaimsIdentity())
// original.identities 仍为 1 个，cloned.identities 为 2 个

// 自定义主 identity 选择策略（取最后一个）
ClaimsPrincipal.setPrimaryIdentitySelector { identities =>
    let arr = identities.toArray()
    if (arr.isEmpty()) { None } else { Some(arr[arr.size - 1]) }
}
```

---

## API 参考

### Claim

| 方法 / 属性 | 说明 |
|-------------|------|
| `init(type: String, value: String)` | 构造声明，`valueType` 默认为 `ClaimValueTypes.String` |
| `init(type: String, value: String, valueType: String)` | 构造声明，指定值类型 |
| `prop type: String` | 声明类型名，如 `"sub"`、`"role"` |
| `prop value: String` | 声明值 |
| `prop valueType: String` | 声明值类型，来自 `ClaimValueTypes` 常量 |
| `func toString(): String` | 格式为 `"type = value [valueType]"` |
| `func serialize(): DataModelStruct` | 序列化为结构体 |
| `static func deserialize(dm: DataModel): Claim` | 从结构体还原，入参非 `DataModelStruct` 时抛 `DataModelException` |

### ClaimsIdentity

| 方法 / 属性 | 说明 |
|-------------|------|
| `init()` | 空身份，未认证 |
| `init(claims: Collection<Claim>)` | 带初始声明集合，未认证 |
| `init(authenticationType: ?String)` | 指定认证类型，`Some(...)` 时为已认证 |
| `init(authenticationType: ?String, claims: Collection<Claim>)` | 完整构造 |
| `prop claims: Collection<Claim>` | 当前身份的所有声明 |
| `prop isAuthenticated: Bool` | `authenticationType` 为 `Some` 时为 `true` |
| `prop authenticationType: ?String` | 认证方案名，如 `"Bearer"`、`"Cookie"` |
| `func addClaim(claim: Claim): Unit` | 追加声明对象 |
| `func addClaim(type: String, value: String): Unit` | 追加声明（默认 valueType） |
| `func addClaim(type: String, value: String, valueType: String): Unit` | 追加声明（指定 valueType） |
| `func addClaims(claims: Collection<Claim>): Unit` | 批量追加 |
| `func findAll(predicate: (Claim) -> Bool): Array<Claim>` | 按谓词筛选，无匹配返回空数组 |
| `func findAll(type: String): Array<Claim>` | 按类型筛选 |
| `func findFirst(predicate: (Claim) -> Bool): ?Claim` | 返回首个匹配项，无匹配返回 `None` |
| `func findFirst(type: String): ?Claim` | 按类型返回首个 |
| `func findFirstValue(predicate: (Claim) -> Bool): ?String` | 返回首个匹配的 value，无匹配返回 `None` |
| `func findFirstValue(type: String): ?String` | 按类型返回首个 value |
| `func hasClaim(predicate: (Claim) -> Bool): Bool` | 是否存在满足谓词的声明 |
| `func hasClaim(type: String, value: String): Bool` | 是否存在精确匹配的声明 |
| `func clone(): ClaimsIdentity` | 深拷贝，返回独立副本 |
| `func serialize(): DataModelStruct` | 序列化 |
| `static func deserialize(dm: DataModel): ClaimsIdentity` | 反序列化 |

### ClaimsPrincipal

| 方法 / 属性 | 说明 |
|-------------|------|
| `init(claimsIdentities: Array<ClaimsIdentity>)` | 构造主体 |
| `prop claims: Collection<Claim>` | 跨所有 identity 聚合的声明集合 |
| `prop identities: Collection<ClaimsIdentity>` | 所有 identity |
| `prop identity: ?ClaimsIdentity` | 主 identity，默认取第一个，可通过 `setPrimaryIdentitySelector` 自定义 |
| `func addIdentity(claimsIdentity: ClaimsIdentity): Unit` | 追加单个 identity |
| `func addIdentities(claimsIdentities: Collection<ClaimsIdentity>): Unit` | 批量追加 |
| `func hasClaim(predicate: (Claim) -> Bool): Bool` | 跨 identity 检查是否存在满足谓词的声明 |
| `func hasClaim(type: String, value: String): Bool` | 跨 identity 精确匹配 |
| `func findAll(selector: (Claim) -> Bool): Array<Claim>` | 跨 identity 按谓词筛选 |
| `func findAll(type: String): Array<Claim>` | 跨 identity 按类型筛选 |
| `func findFirst(selector: (Claim) -> Bool): ?Claim` | 跨 identity 返回首个匹配，无匹配返回 `None` |
| `func findFirst(type: String): ?Claim` | 跨 identity 按类型返回首个 |
| `func findFirstValue(selector: (Claim) -> Bool): ?String` | 跨 identity 返回首个匹配的 value |
| `func findFirstValue(type: String): ?String` | 跨 identity 按类型返回首个 value |
| `func isInRole(role: String): Bool` | 检查是否持有指定角色（基于 `ClaimTypes.Role` 声明） |
| `func clone(): ClaimsPrincipal` | 深拷贝，返回独立副本 |
| `static func setPrimaryIdentitySelector(selector: (identities: Collection<ClaimsIdentity>) -> ?ClaimsIdentity): Unit` | 自定义主 identity 选取策略 |
| `func serialize(): DataModelStruct` | 序列化 |
| `static func deserialize(dm: DataModel): ClaimsPrincipal` | 反序列化 |

### ClaimTypes

常用常量（共 40+）：

| 分类 | 常量示例 |
|------|----------|
| JWT（RFC 7519） | `Sub`、`Exp`、`Iss`、`Aud`、`Iat`、`Jti`、`Nbf` |
| OpenID Connect | `Name`、`Email`、`PhoneNumber`、`Birthdate`、`Locale`、`Nonce`、`Sid` |
| 角色 / 权限 | `Role`、`Roles`、`Scope`、`Permissions` |
| 组织自定义 | `TenantId`、`ClientId`、`UserId`、`EmployeeId` |
| OAuth | `AccessTokenHash`、`CodeHash` |

### ClaimValueTypes

常用常量（共 20+）：

| 来源规范 | 常量示例 |
|----------|----------|
| XML Schema | `String`、`Boolean`、`Integer`、`Double`、`DateTime`、`Date` |
| SOAP | `Email`、`DnsName`、`Rsa`、`UpnName` |
| XML Signature | `DsaKeyValue`、`RsaKeyValue`、`KeyInfo` |
| XQuery | `DaytimeDuration`、`YearMonthDuration` |

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [dotnet/runtime](https://github.com/dotnet/runtime/tree/main/src/libraries/System.Security.Claims) 中的 `System.Security.Claims` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
