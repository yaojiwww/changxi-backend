package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// 认证接口：/api/v1/auth/*
//
// 五个接口，两条铁律：
//   ① 注册成功和登录成功的响应**必须一模一样**（都是 data 为令牌字符串），
//      这样前端可以在两处复用同一段「存令牌 → 进首页」的代码。
//   ② 所有失败都必须回信封（writeApiError），绝不能空 body——前端对每个响应
//      都做 JSON.parse，空 body 会被它报成"网络异常"，排查方向就全错了。
//
// 关于错误码的分工：
//   1001 = 手机号或密码错误（登录专属，且**不区分**是账号不存在还是密码错）
//   1002 = 请求参数问题（缺字段、格式不对、验证码不对、手机号已注册……）
//   1003 = 未登录 / 令牌无效 / 已登出
// =============================================================================

const SMS_SCENE_REGISTER: String = "register"

// 手机号：11 位、1 开头、第二位 3-9。这里手写判断而不是上正则库，
// 规则就这么几条，写出来比读正则表达式更快。
public func isValidPhone(phone: String): Bool {
    if (phone.size != 11) {
        return false
    }
    if (phone[0] != b'1' || phone[1] < b'3' || phone[1] > b'9') {
        return false
    }
    for (i in 0..phone.size) {
        if (phone[i] < b'0' || phone[i] > b'9') {
            return false
        }
    }
    return true
}

// 6 位数字验证码。取 4 字节真随机数再对 1000000 取模，然后补零到 6 位
// ——"000123"这种码也是合法的，不能直接把数字转字符串就完事。
public func generateSmsCode(): String {
    let bytes = randomBytes(4)
    var value: UInt32 = 0
    for (i in 0..4) {
        value = (value << 8) | UInt32(bytes[i])
    }
    var text = (Int64(value % 1000000)).toString()
    while (text.size < 6) {
        text = "0" + text
    }
    return text
}

// 统一的两个失败出口
func writeLoginFailed(context: HttpContext): Unit {
    writeApiError(context.response, StatusCodes.Unauthorized, ApiCode.LOGIN_FAILED, "手机号或密码错误")
}

func writeUnauthorized(context: HttpContext): Unit {
    writeApiError(context.response, StatusCodes.Unauthorized, ApiCode.UNAUTHORIZED, "未登录或登录已过期")
}

// 读请求体，顺带把"body 不是 JSON 对象"这条错误路径统一回掉。
// 返回 None 就表示已经回过响应了，调用方直接 return 即可。
func requireBodyObject(context: HttpContext): ?JsonObject {
    let body = readJsonBody(context)
    if (body.isNone()) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
            "请求体格式不正确，应为 JSON 对象")
    }
    return body
}

// 从 Authorization 头里解析当前用户。
// 校验链：Bearer 前缀 → 令牌签名/有效期/签发者 → 库里这条用户是否存在
// → 账号状态正常 → 令牌版本号与库里一致。
// 最后一步是登出能立即生效的关键：登出时库里 token_version +1，
// 旧令牌里的版本号还对不上，于是全部作废。
//
// 失败时**自己已经回过 401 响应**，调用方拿到 None 直接 return。
// 细节原因只写服务端日志：告诉客户端"你签名错了"等于给攻击者反馈。
public func authenticate(context: HttpContext, services: AppServices): ?UserRecord {
    let headers = context.request.headers
    // HTTP 头名理论上大小写不敏感，客户端写法不完全一致，两个都试一下再放弃
    let header = headers.get("Authorization") ?? headers.get("authorization") ?? ""
    if (!header.startsWith("Bearer ")) {
        serverLog("[认证失败] ${context.request.method} ${context.request.getDisplayUrl()} 缺少 Bearer 令牌")
        writeUnauthorized(context)
        return None
    }
    let claims = match (parseAuthToken(header[7..], services.config.jwt)) {
        case Some(c) => c
        case None =>
            serverLog("[认证失败] 令牌无效、已过期或签名不对")
            writeUnauthorized(context)
            return None
    }
    let user = match (services.users.findById(claims.userId)) {
        case Some(u) => u
        case None =>
            serverLog("[认证失败] 令牌里的用户 ${claims.userId} 已不存在")
            writeUnauthorized(context)
            return None
    }
    if (user.status != 0) {
        serverLog("[认证失败] 用户 ${user.id} 状态为 ${user.status}（非正常）")
        writeUnauthorized(context)
        return None
    }
    if (user.tokenVersion != claims.tokenVersion) {
        serverLog("[认证失败] 用户 ${user.id} 的令牌已作废（令牌 ver=${claims.tokenVersion}，当前 ver=${user.tokenVersion}）")
        writeUnauthorized(context)
        return None
    }
    return Some(user)
}

// -----------------------------------------------------------------------------
// 发送验证码
// 开发阶段不接短信通道，验证码直接打到服务端终端上（serverLog 带 flush，
// 不然容器里要等缓冲区满才显示，看不到就等于没有）。
// -----------------------------------------------------------------------------
public func handleSendCode(context: HttpContext, services: AppServices): Unit {
    let body = requireBodyObject(context) ?? return
    let number = jsonStringOf(body, "number") ?? ""
    if (!isValidPhone(number)) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "手机号格式不正确")
        return
    }

    let code = generateSmsCode()
    services.smsCodes.insert(number, code, SMS_SCENE_REGISTER, services.config.smsCodeExpireSeconds)

    serverLog("════════════ 验证码 ════════════")
    serverLog("  手机号：${number}")
    serverLog("  验证码：${code}   （${services.config.smsCodeExpireSeconds} 秒内有效）")
    serverLog("════════════════════════════════")

    writeApiOk(context.response, JsonNull())
}

// -----------------------------------------------------------------------------
// 注册
// -----------------------------------------------------------------------------
public func handleRegister(context: HttpContext, services: AppServices): Unit {
    let body = requireBodyObject(context) ?? return
    let number = jsonStringOf(body, "number") ?? ""
    let password = jsonStringOf(body, "password") ?? ""
    let code = jsonStringOf(body, "code") ?? ""

    // 注册这里可以明说哪里不对：这不是"猜凭证"，参数错就是参数错，
    // 前端能直接看到原因，比统一回一句"注册失败"好用得多。
    if (!isValidPhone(number)) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "手机号格式不正确")
        return
    }
    if (password.size < 6) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "密码长度不能少于 6 位")
        return
    }
    if (code.size != 6) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "验证码格式不正确")
        return
    }
    if (services.users.findByPhone(number).isSome()) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "该手机号已注册")
        return
    }

    // 验证码校验：取最近一条"没用过且没过期"的码比对。
    // "不存在"和"填错了"回同一句话——否则可以靠错误文案判断某个号有没有发过码。
    let record = match (services.smsCodes.findLatestUsable(number, SMS_SCENE_REGISTER)) {
        case Some(r) => r
        case None =>
            writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "验证码错误或已过期")
            return
    }
    if (!constantTimeEquals(record.code, code)) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "验证码错误或已过期")
        return
    }

    // 密码只存哈希（sha256 + 每用户随机盐 + 12000 轮），库里没有明文可查
    let passwordHash = hashPassword(password)
    let nickname = "学员${number[7..11]}"
    let userId = services.users.insert(number, passwordHash, nickname)
    // 用掉这条验证码，防止同一码重复注册（重放）
    services.smsCodes.markUsed(record.id)

    serverLog("新用户注册成功 id=${userId} 手机号=${number} 昵称=${nickname}")
    // ★ 和登录成功的响应保持逐字节一致：前端两处共用同一段处理逻辑
    writeApiOk(context.response, JsonString(createAuthToken(userId, 0, services.config.jwt)))
}

// -----------------------------------------------------------------------------
// 登录
// -----------------------------------------------------------------------------
public func handleLogin(context: HttpContext, services: AppServices): Unit {
    let body = requireBodyObject(context) ?? return
    let number = jsonStringOf(body, "number")
    let password = jsonStringOf(body, "password")

    // 字段压根没传 = 前端契约对不上（比如把 number 写成了 phone），这是**开发期 bug**，
    // 和"凭证对不对"无关，所以回 1002 并说清楚，方便立刻发现字段名写错。
    if (number.isNone() || password.isNone() || number.getOrThrow().isEmpty()) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
            "缺少 number 或 password 字段")
        return
    }
    let phone = number.getOrThrow()
    let pwd = password.getOrThrow()

    // 从这里往下，不管失败原因是什么，客户端看到的都是同一句"手机号或密码错误"，
    // 真实原因只写服务端日志——避免账号枚举。
    let found = services.users.findByPhone(phone)
    // 账号不存在时也做一次哈希校验（拿 dummyPasswordHash 当靶子），
    // 让两条路径耗时接近，堵住"用响应时间判断账号存不存在"这条路。
    let storedHash = match (found) {
        case Some(u) => u.passwordHash
        case None => services.dummyPasswordHash
    }
    let passwordOk = verifyPassword(pwd, storedHash)

    match (found) {
        case None =>
            serverLog("[登录失败] 手机号未注册：${phone}")
            writeLoginFailed(context)
            return
        case Some(user) =>
            if (!passwordOk) {
                serverLog("[登录失败] 密码错误：id=${user.id} 手机号=${phone}")
                writeLoginFailed(context)
                return
            }
            if (user.status != 0) {
                serverLog("[登录失败] 账号状态异常（status=${user.status}）：id=${user.id}")
                writeLoginFailed(context)
                return
            }
            services.users.touchLastLogin(user.id)
            serverLog("[登录成功] id=${user.id} 手机号=${phone}")
            // 令牌里带上当前 token_version：之后只要这个值被 +1，这条令牌就失效
            writeApiOk(context.response, JsonString(createAuthToken(user.id, user.tokenVersion, services.config.jwt)))
    }
}

// -----------------------------------------------------------------------------
// 登出
// 前端不存手机号，所以这里**只看 Authorization 头**，请求体是空的 {}。
// -----------------------------------------------------------------------------
public func handleLogout(context: HttpContext, services: AppServices): Unit {
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return // authenticate 已经回过 401
    }
    let user = userOpt.getOrThrow()
    let newVersion = services.users.bumpTokenVersion(user.id)
    serverLog("登出成功 id=${user.id}，token_version 已递增到 ${newVersion}，此前签发的令牌全部失效")
    writeApiOk(context.response, JsonNull())
}

// -----------------------------------------------------------------------------
// 注销账号
// -----------------------------------------------------------------------------
public func handleDeleteAccount(context: HttpContext, services: AppServices): Unit {
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return // authenticate 已经回过 401
    }
    let user = userOpt.getOrThrow()
    services.users.softDelete(user.id, user.phone)
    serverLog("账号已注销 id=${user.id}，手机号改写为 del_${user.id}_${user.phone}（释放唯一键），status=2")
    writeApiOk(context.response, JsonNull())
}
