package changxi_backend

import std.time.*
import stdx.encoding.json.*
import std.crypto.digest.*
import stdx.crypto.digest.*
import soulsoft_web_http.*

// 发送验证码接口
public func handleSendCode(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let number = jsonField(body, "number")
    let purpose = jsonField(body, "purpose")
    
    // 参数校验
    if (number.isEmpty() || purpose.isEmpty()) {
        writeError(ctx.response, 400, 1, "手机号和用途不能为空")
        return
    }
    
    // 生成6位随机验证码
    let code = generateCode()
    println("【验证码】手机号: ${number}, 验证码: ${code}, 用途: ${purpose}")
    
    // 计算过期时间（5分钟后）
    let expireTime = DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000 + 5 * 60 * 1000
    
    // 查找用户是否已存在
    let idx = findUserByNumber(number)
    
    if (idx >= 0) {
        // 用户存在，更新验证码
        updateVerifyCode(number, code, expireTime)
    } else {
        // 用户不存在，如果是注册用途，先创建一条记录
        if (purpose == "register") {
            createUser(number, "")
            updateVerifyCode(number, code, expireTime)
        } else {
            writeError(ctx.response, 400, 2, "手机号未注册")
            return
        }
    }
    
    writeOk(ctx.response, JsonNull())
}

// 注册接口
public func handleRegister(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let number = jsonField(body, "number")
    let code = jsonField(body, "code")
    let password = jsonField(body, "password")
    
    // 参数校验
    if (number.isEmpty() || code.isEmpty() || password.isEmpty()) {
        writeError(ctx.response, 400, 1, "手机号、验证码和密码不能为空")
        return
    }
    
    // 查找用户
    let idx = findUserByNumber(number)
    if (idx < 0) {
        writeError(ctx.response, 400, 2, "请先获取验证码")
        return
    }
    
    // 校验验证码
    let dbCode = userVerifyCodes[idx]
    let expireTime = userCodeExpires[idx]
    
    if (dbCode.isEmpty() || dbCode != code) {
        writeError(ctx.response, 400, 3, "验证码错误")
        return
    }
    
    // 校验是否过期
    if (DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000 > expireTime) {
        writeError(ctx.response, 400, 4, "验证码已过期")
        return
    }
    
    // 密码加密（简单哈希）
    let hashedPwd = hashPassword(password)
    
    // 更新密码，清除验证码
    updatePassword(idx, hashedPwd)
    clearVerifyCode(idx)
    
    // 签发 token
    let userId = userIds[idx]
    let token = issueToken(userId.toString())
    writeOk(ctx.response, JsonString(token))
}

// 登录接口
public func handleLogin(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let number = jsonField(body, "number")
    let password = jsonField(body, "password")
    
    if (number.isEmpty() || password.isEmpty()) {
        writeError(ctx.response, 400, 1, "手机号和密码不能为空")
        return
    }
    
    // 查找用户
    let idx = findUserByNumber(number)
    if (idx < 0) {
        writeError(ctx.response, 400, 2, "手机号未注册")
        return
    }
    
    let dbPwd = userPasswords[idx]
    
    // 校验密码
    let hashedPwd = hashPassword(password)
    if (dbPwd.isEmpty() || dbPwd != hashedPwd) {
        writeError(ctx.response, 400, 3, "密码错误")
        return
    }
    
    // 签发 token
    let userId = userIds[idx]
    let token = issueToken(userId.toString())
    writeOk(ctx.response, JsonString(token))
}

// 登出接口
public func handleLogout(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let number = jsonField(body, "number")
    
    if (number.isEmpty()) {
        writeError(ctx.response, 400, 1, "手机号不能为空")
        return
    }
    
    // 实际项目中可以在这里把 token 加入黑名单
    // 这里简单返回成功
    writeOk(ctx.response, JsonString("logout success"))
}

// 生成6位数字验证码
func generateCode(): String {
    let now = DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000
    let code = (now % 900000) + 100000
    return code.toString()
}

// 简单密码哈希
func hashPassword(password: String): String {
    let sha256Instance = SHA256()
    let md = digest(sha256Instance, password)
    return bytesToHex(md)
}

// 字节数组转十六进制字符串
func bytesToHex(bytes: Array<Byte>): String {
    let hexChars = "0123456789abcdef"
    var result = ""
    var i = 0
    while (i < bytes.size) {
        let b = bytes[i]
        let bInt = Int64(b)
        let high = (bInt >> 4) & 0xF
        let low = bInt & 0xF
        result += hexChars[high].toString()
        result += hexChars[low].toString()
        i++
    }
    return result
}

// 签发 JWT token（简化版）
func issueToken(userId: String): String {
    let jwtSecret = mustGetEnv("PHARMACY_JWT_SECRET")
    // 简单实现：userId + 过期时间 + 签名
    let expireTime = DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000 + 7 * 24 * 60 * 60 * 1000 // 7天
    let payload = "${userId}|${expireTime}"
    let sha256Instance = SHA256()
    let signature = bytesToHex(digest(sha256Instance, "${payload}|${jwtSecret}"))
    return "${payload}|${signature}"
}
