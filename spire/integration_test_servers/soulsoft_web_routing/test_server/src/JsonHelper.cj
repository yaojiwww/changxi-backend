package test

import soulsoft_web_http.*

/**
 * 辅助函数：将 String 路由值格式化为 JSON 值
 */
func jsonVal(v: String): String {
    "\"${v}\""
}

/**
 * 辅助函数：读取路由值并格式化为 JSON 值（缺键返回 JSON null）
 */
func rv(ctx: HttpContext, key: String): String {
    match (ctx.request.routeValues.get(key)) {
        case Some(v) => "\"${v}\""
        case None => "null"
    }
}

/**
 * 辅助函数：构建包含匹配成功标志的 JSON 响应体
 * pairs: [("key", jsonValue), ...]，jsonValue 已是 JSON 字面量（含引号或 null）
 */
func buildJson(pairs: Array<(String, String)>): String {
    var sb = StringBuilder()
    sb.append("{")
    var first = true
    for ((k, v) in pairs) {
        if (!first) {
            sb.append(", ")
        }
        sb.append("\"${k}\": ${v}")
        first = false
    }
    sb.append("}")
    return sb.toString()
}

/**
 * 辅助函数：写入 JSON 响应（指定状态码）
 */
func writeJsonWithStatus(ctx: HttpContext, body: String, status: UInt16): Unit {
    ctx.response.statusCode = status
    ctx.response.contentType = "application/json; charset=utf-8"
    ctx.response.write(body)
}

/**
 * 辅助函数：写入 JSON 响应，状态码 200
 */
func writeJson(ctx: HttpContext, body: String): Unit {
    writeJsonWithStatus(ctx, body, 200)
}

/**
 * 辅助函数：写入成功匹配的 JSON 响应（仅含 matched=true）
 */
func writeMatched(ctx: HttpContext): Unit {
    writeJson(ctx, "{\"matched\": true}")
}
