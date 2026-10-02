package changxi_backend

import std.time.*
import std.collection.*
import std.convert.*
import soulsoft_web_http.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*

// JWT 相关配置集中在这里：签发和校验都是本进程，issuer/audience 用常量即可，
// 不必再引入两个环境变量（少两个"配漏了就启动失败"的点）
const JWT_ISSUER = "changxi-backend"
const JWT_AUDIENCE = "changxi-app"
const JWT_EXPIRE_SECONDS: Int64 = 7 * 24 * 60 * 60 // 7 天

// 签名密钥只从环境变量来，读不到就抛
func jwtSigningKey(): SymmetricSecurityKey {
    let secret = mustGetEnv("CHANGXI_JWT_SECRET")
    return SymmetricSecurityKey(secret.toArray())
}

// 绑定 JwtBearer 的校验参数
func configureJwtBearer(options: JwtBearerOptions): Unit {
    let params = options.tokenValidationParameters
    params.validateIssuer = true
    params.validateAudience = true
    params.validateLifetime = true
    params.requireExpirationTime = true
    params.validIssuers = [JWT_ISSUER]
    params.validAudiences = [JWT_AUDIENCE]
    params.issuerSigningKeys = [jwtSigningKey()]
    // Spire 的 clockSkew 默认是 0（不是 .NET 的 5 分钟）。
    // 鸿蒙设备与服务器的时钟难免有偏差，不留容错的话刚签发的 token 会立刻判过期
    params.clockSkew = Duration.second * 30
}

// 签发标准 HS256 JWT（三段式 header.payload.signature）
func issueToken(userId: Int64): String {
    let creds = SigningCredentials(jwtSigningKey(), SecurityAlgorithms.HmacSha256)
    let desc = SecurityTokenDescriptor(creds)
    let now = DateTime.nowUTC()
    desc.issuer = Some(JWT_ISSUER)
    desc.audience = Some(JWT_AUDIENCE)
    desc.issuedAt = Some(now)
    desc.expires = Some(now.addSeconds(JWT_EXPIRE_SECONDS))

    let claims = ArrayList<Claim>()
    claims.add(Claim(ClaimTypes.UserId, userId.toString()))
    desc.claims = claims

    return JwtSecurityTokenHandler().createEncodedJwt(desc)
}

// 从请求上下文取当前用户 id：没带 token、token 无效或过期，都会走到 None
func currentUser(ctx: HttpContext): Option<Int64> {
    let raw = match (ctx.user.findFirstValue(ClaimTypes.UserId)) {
        case Some(s) => s
        case None => return None
    }
    try {
        return Some(Int64.parse(raw))
    } catch (_: Exception) {
        // claim 内容不是合法数字（伪造的 token 签名校验已经挡掉，这里是兜底）
        return None
    }
}
