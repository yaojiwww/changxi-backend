package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// 统一响应信封
//
// 前端拿到的每一个响应体都必须是这个形状，没有例外：
//   { "code": 0, "message": "ok", "data": null }
// 成功 code=0（HTTP 200）；业务失败 code≠0（HTTP 用 4xx）。data 可以是 null、
// 字符串（比如 JWT 令牌）或者对象。
//
// 为什么不用框架自带的 ok<T>(value) / badRequest()？
//   - ok(value) 会产生 200 + 裸 JSON，**没有 code/message 这两个字段**；
//   - badRequest() / unauthorized() 产生的响应**没有 body**，前端 JSON.parse 直接崩。
// 两者都不符合契约，所以这里自己拼 JSON，一个字都不靠框架的默认行为。
//
// 为什么手拼 JSON（stdx.encoding.json 的 JsonObject）而不是用序列化库把对象转成 JSON？
//   信封只有 code/message/data 三个键，形状固定且极简；手拼能保证输出**逐字节可控**，
//   不会因为序列化库的命名策略、空值策略、泛型处理方式而在某个角落里变出 {"code":0,...}
//   之外的形状。这个契约太关键了，值得用最笨但最确定的方式实现。
// =============================================================================

// 业务码。
// 0 是唯一表示成功的值；非 0 一律表示失败，具体值由各接口约定：
//   1001 登录失败（任务书指定）、1002 请求格式错、1003 未认证、1004 接口不存在、1005 服务器内部错误
public class ApiCode {
    public static const OK: Int64 = 0
    public static const LOGIN_FAILED: Int64 = 1001      // 手机号或密码错误
    public static const BAD_REQUEST: Int64 = 1002       // 请求体格式/参数不合法
    public static const UNAUTHORIZED: Int64 = 1003      // 未登录、令牌无效或已登出
    public static const NOT_FOUND: Int64 = 1004         // 接口不存在
    public static const SERVER_ERROR: Int64 = 1005      // 服务器内部错误
}

// 拼信封并写进响应。所有对外输出的唯一出口，改格式只改这里。
public func writeApiEnvelope(response: HttpResponse, status: UInt16, code: Int64, message: String,
                             data: JsonValue): Unit {
    let envelope = JsonObject()
    envelope.put("code", JsonInt(code))
    envelope.put("message", JsonString(message))
    envelope.put("data", data)

    // 先设状态码和 Content-Type，再写 body —— 顺序不能反：
    // 一旦写了 body，响应头就已经发出去了（hasStarted 变 true），再改状态码无效。
    response.statusCode = status
    response.contentType = "application/json; charset=utf-8"
    response.write(envelope.toString())
}

// 成功：code=0、HTTP 200、message 固定 "ok"
public func writeApiOk(response: HttpResponse, data: JsonValue): Unit {
    writeApiEnvelope(response, StatusCodes.Ok, ApiCode.OK, "ok", data)
}

// 失败：data 固定 null，HTTP 状态码与业务码分开传
// （前端只看 code，但 HTTP 状态码要正确，否则日志、网关、监控全是误报）
public func writeApiError(response: HttpResponse, status: UInt16, code: Int64, message: String): Unit {
    writeApiEnvelope(response, status, code, message, JsonNull())
}

// 框架级失败时，把 HTTP 状态码翻译成业务码
private func codeForStatus(status: UInt16): Int64 {
    if (status == StatusCodes.NotFound) {
        return ApiCode.NOT_FOUND
    }
    if (status == StatusCodes.Unauthorized || status == StatusCodes.Forbidden) {
        return ApiCode.UNAUTHORIZED
    }
    if (status >= 500) {
        return ApiCode.SERVER_ERROR
    }
    return ApiCode.BAD_REQUEST
}

// 框架级失败时，给用户看的兜底文案
private func messageForStatus(status: UInt16): String {
    if (status == StatusCodes.NotFound) {
        return "接口不存在"
    }
    if (status == StatusCodes.MethodNotAllowed) {
        return "请求方法不允许"
    }
    if (status == StatusCodes.Unauthorized) {
        return "未登录或登录已过期"
    }
    if (status == StatusCodes.Forbidden) {
        return "没有权限"
    }
    if (status >= 500) {
        return "服务器内部错误"
    }
    return "请求格式有误"
}

// =============================================================================
// 信封中间件：把「框架自己处理的路径」也拉回信封里
//
// 两类响应是框架直接产出的、绕过我们所有业务代码的：
//   1. 路由没匹配上 → 框架把状态码设成 404，body 是空的；
//   2. 业务代码抛异常 → 异常沿着管道往上传，没人接就是空 body 的 500。
// 中间件是唯一能同时兜住这两者的地方。
//
// 为什么它必须在 useRouting() **之前**注册？
//   中间件的注册顺序 = 执行顺序（先注册的最外层）。放在最外层才能：
//   - 用 try/catch 包住里面所有东西（包括控制器抛的异常）；
//   - 在路由中间件跑完之后，回头看到「没人处理的 404」这个状态码。
//   如果注册在 useRouting() 之后，异常和 404 都已经走到它外面去了，兜不住。
// =============================================================================
public func apiEnvelopeMiddleware(context: HttpContext, next: RequestDelegate): Unit {
    try {
        next(context)
    } catch (e: Exception) {
        // 异常详情只进服务端日志：给前端返回堆栈会把内部结构暴露出去，
        // 而且用户看了也没用。日志里必须有，否则线上问题没法查。
        serverLog("[异常] ${context.request.method} ${context.request.getDisplayUrl()} -> ${e.toString()}")
        if (!context.response.hasStarted) {
            writeApiError(context.response, StatusCodes.InternalServerError, ApiCode.SERVER_ERROR, "服务器内部错误")
        }
        return
    }

    let response = context.response
    // 里层已经自己写好响应了（比如某个直接 write 文本的旧接口），不插手
    if (response.hasStarted) {
        return
    }
    // 204/304 按 HTTP 规范就是没有 body，硬塞一个反而违规
    if (response.statusCode == StatusCodes.NoContent || response.statusCode == StatusCodes.NotModified) {
        return
    }
    // 走到这里说明状态码定好了但一个字节都没写：要么是没人处理的错误，要么是
    // 某个端点忘了返回东西。统一补上信封，保证「任何路径都是 JSON」这条底线。
    if (response.statusCode >= 400) {
        writeApiError(response, response.statusCode, codeForStatus(response.statusCode),
            messageForStatus(response.statusCode))
    } else {
        writeApiOk(response, JsonNull())
    }
}
