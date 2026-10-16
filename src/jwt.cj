package changxi_backend

import std.convert.*
import std.time.*
import stdx.crypto.digest.*
import stdx.encoding.json.*

// =============================================================================
// JWT 令牌（HS256，自己实现）
//
// 为什么不用框架自带的 JwtSecurityTokenHandler？
//   能用，但它的类型链很长（SecurityTokenDescriptor / SigningCredentials /
//   ClaimsIdentity / TokenValidationParameters…），而我们要的只是「签发一个
//   带几个自定义声明的 HS256 串」和「验签 + 读声明」两件事。自己实现换来两个好处：
//     1. 本机（macOS）就能跑通全部测试，不用每次进容器等一分钟；
//     2. 令牌里放什么、报什么错，完全在我们掌控内——这个契约前端要对着写，
//        不能受第三方库版本变化影响。
//   HS256 本身是「HMAC-SHA256 + base64url 拼接」，标准算法，不是自己发明密码学。
//
// 声明（payload）设计：
//   sub = 用户 id        （JWT 标准字段，字符串）
//   ver = token_version  （★ 关键：登出/注销时数据库里这个值 +1，旧令牌立刻全废）
//   iat = 签发时间（秒）  exp = 过期时间（秒）  iss/aud 防串用
// =============================================================================

// 头部是固定字面量：不经过序列化库，保证每次输出的字节完全一样（签名才可复现）
let JWT_HEADER_B64: String = base64UrlEncode("{\"alg\":\"HS256\",\"typ\":\"JWT\"}".toArray())

// 当前 unix 时间戳（秒）
public func nowEpochSeconds(): Int64 {
    return DateTime.nowUTC().toUnixTimeStamp().toSeconds()
}

// HMAC-SHA256：用密钥对消息做一次带密钥的摘要
func hmacSha256(key: String, message: String): Array<Byte> {
    let hmac = HMAC(key.toArray(), {=> SHA256() })
    hmac.write(message.toArray())
    return hmac.finish()
}

// 对 "头部.载荷" 这段字符串签名。验签时用同样方式重算一遍再比对即可，
// 所以**完全不需要**去解码签名段。
func signSegments(headerB64: String, payloadB64: String, secret: String): String {
    return base64UrlEncode(hmacSha256(secret, headerB64 + "." + payloadB64))
}

// 从令牌里取出来的声明
public class TokenClaims {
    public var userId: Int64 = 0
    public var tokenVersion: Int64 = 0
    public var expiresAt: Int64 = 0
}

// 签发令牌
public func createAuthToken(userId: Int64, tokenVersion: Int64, config: JwtConfig): String {
    let now = nowEpochSeconds()
    let payload = JsonObject()
    payload.put("iss", JsonString(config.issuer))
    payload.put("aud", JsonString(config.audience))
    payload.put("sub", JsonString(userId.toString()))
    payload.put("ver", JsonInt(tokenVersion))
    payload.put("iat", JsonInt(now))
    payload.put("exp", JsonInt(now + config.expiresHours * 3600))

    let payloadB64 = base64UrlEncode(payload.toString().toArray())
    return JWT_HEADER_B64 + "." + payloadB64 + "." + signSegments(JWT_HEADER_B64, payloadB64, config.secret)
}

// 校验令牌并取出声明。任何一项不满足都返回 None（调用方统一按「未登录」处理，
// 不告诉客户端到底是签名错还是过期了——那种细节只会帮攻击者试错）。
public func parseAuthToken(token: String, config: JwtConfig): ?TokenClaims {
    let parts = token.split(".")
    if (parts.size != 3) {
        return None
    }
    // ① 验签：用同样的密钥重算签名，比对时用等时比较，避免通过响应时间猜签名
    if (!constantTimeEquals(signSegments(parts[0], parts[1], config.secret), parts[2])) {
        return None
    }
    // ② 解出载荷（这里必须容忍解析失败：令牌是客户端给的，随便什么垃圾都可能送进来）
    let payloadBytes = match (base64UrlDecode(parts[1])) {
        case Some(b) => b
        case None => return None
    }
    let payload = try {
        JsonValue.fromStr(String.fromUtf8(payloadBytes)).asObject()
    } catch (e: Exception) {
        return None
    }
    // ③ 签发者/受众必须对得上：否则别处签的令牌能直接拿来登我们的系统
    if ((jsonStringOf(payload, "iss") ?? "") != config.issuer ||
        (jsonStringOf(payload, "aud") ?? "") != config.audience) {
        return None
    }
    let userId = match (jsonStringOf(payload, "sub")) {
        case Some(text) =>
            match (Int64.tryParse(text)) {
                case Some(v) => v
                case None => return None
            }
        case None => return None
    }
    let version = jsonIntOf(payload, "ver") ?? return None
    let exp = jsonIntOf(payload, "exp") ?? return None
    if (exp <= nowEpochSeconds()) {
        return None
    }

    let claims = TokenClaims()
    claims.userId = userId
    claims.tokenVersion = version
    claims.expiresAt = exp
    return claims
}
