package changxi_backend

import std.time.*
import stdx.encoding.json.*
import stdx.encoding.hex.*
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
        writeError(ctx.response, 400, CODE_PARAM_INVALID, "手机号和用途不能为空")
        return
    }
    
    // 生成6位随机验证码
    let code = generateCode()
    println("【验证码】手机号: ${number}, 验证码: ${code}, 用途: ${purpose}")
    
    // 计算过期时间（5分钟后）
    let expireTime = DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000 + 5 * 60 * 1000
    
    // 查找用户是否已存在
    match (findUserByNumber(number)) {
        case Some(_) =>
            // 用户存在，更新验证码
            updateVerifyCode(number, code, expireTime)
        case None =>
            // 用户不存在，如果是注册用途，先建一条记录
            if (purpose == "register") {
                createUser(number, "")
                updateVerifyCode(number, code, expireTime)
            } else {
                writeError(ctx.response, 400, CODE_NUMBER_NOT_REGISTERED, "手机号未注册")
                return
            }
    }
    
    // 开发模式把验证码放进响应 data，方便鸿蒙 APP 联调；
    // CHANGXI_DEV_MODE 默认关，生产环境不设即符合接口文档（验证码只走短信）
    if (devMode()) {
        writeOk(ctx.response, JsonString(code))
    } else {
        writeOk(ctx.response, JsonNull())
    }
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
    match (findUserByNumber(number)) {
        case None =>
            writeError(ctx.response, 400, 2, "请先获取验证码")
            return
        case Some(user) =>
            // 校验验证码
            if (user.verifyCode.isEmpty() || user.verifyCode != code) {
                writeError(ctx.response, 400, 3, "验证码错误")
                return
            }

            // 校验是否过期
            if (DateTime.nowUTC().toUnixTimeStamp().toSeconds() * 1000 > user.codeExpire) {
                writeError(ctx.response, 400, 4, "验证码已过期")
                return
            }

            // 密码加密（简单哈希），写库并清掉验证码
            setPasswordAndClearCode(number, hashPassword(password))

            // 签发 token
            let token = issueToken(user.id)
            writeOk(ctx.response, JsonString(token))
    }
}

// 登录接口
public func handleLogin(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let number = jsonField(body, "number")
    let password = jsonField(body, "password")
    
    if (number.isEmpty() || password.isEmpty()) {
        writeError(ctx.response, 400, CODE_PARAM_INVALID, "手机号和密码不能为空")
        return
    }
    
    // 查找用户
    match (findUserByNumber(number)) {
        case None =>
            writeError(ctx.response, 400, CODE_NUMBER_NOT_REGISTERED, "手机号未注册")
            return
        case Some(user) =>
            // 校验密码
            let hashedPwd = hashPassword(password)
            if (user.password.isEmpty() || user.password != hashedPwd) {
                writeError(ctx.response, 400, CODE_PASSWORD_WRONG, "密码错误")
                return
            }

            // 签发 token
            let token = issueToken(user.id)
            writeOk(ctx.response, JsonString(token))
    }
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

// 简单密码哈希：SHA256 后转 64 字符十六进制
// 不能用 "hexChars[i].toString()" 自己拼 —— String 下标取到的是 Byte(ASCII码)，
// 转出来是 "102" 而不是 "f"，长度会膨胀到 150+，塞不进 VARCHAR(64)
func hashPassword(password: String): String {
    let sha256Instance = SHA256()
    let md = digest(sha256Instance, password)
    return toHexString(md)
}
