package changxi_backend

import std.io.*
import std.convert.*
import stdx.encoding.json.*
import soulsoft_web_http.*

// 把请求体读成字符串（天擎官方示例的写法）
public func readRequestBody(request: HttpRequest): String {
    try {
        let buffer = ByteBuffer()
        copy(request.body, to: buffer)
        return buffer |> readString
    } catch (_: Exception) {
        return ""
    }
}

// 从 JSON 文本里取一个字符串字段；取不到一律返回空串，绝不抛异常
public func jsonField(jsonStr: String, name: String): String {
    try {
        let obj = JsonValue.fromStr(jsonStr).asObject()
        match (obj.get(name)) {
            case Some(v) => match (v.kind()) {
                case JsonKind.JsString => return v.asString().getValue()
                case _ => ()
            }
            case None => ()
        }
    } catch (_: Exception) {
        // 请求体不是合法 JSON，按"字段不存在"处理
    }
    return ""
}

// 统一响应格式：{"code":0,"message":"ok","data":{...}}
public func writeJson(response: HttpResponse, status: UInt16, code: Int64,
                      message: String, data: JsonValue): Unit {
    let root = JsonObject()
    root.put("code", JsonInt(code))
    root.put("message", JsonString(message))
    root.put("data", data)
    response.statusCode = status
    response.contentType = "application/json; charset=utf-8"
    response.write(root.toString())
}

public func writeOk(response: HttpResponse, data: JsonValue): Unit {
    writeJson(response, 200, 0, "ok", data)
}

// 失败时 data 必须是 null —— 接口文档明确要求"失败统一返回 null"，
// 返回空对象 {} 会让 APP 按 spec 判空的逻辑失效
public func writeError(response: HttpResponse, status: UInt16, code: Int64, message: String): Unit {
    writeJson(response, status, code, message, JsonNull())
}

// 从查询串取一个整数：取不到、解析失败、越界，一律夹回合法区间
public func queryInt(request: HttpRequest, name: String,
                     fallback: Int64, minValue: Int64, maxValue: Int64): Int64 {
    let raw = match (request.query.get(name)) {
        case Some(s) => s
        case None => return fallback
    }
    var value = fallback
    try {
        value = Int64.parse(raw)
    } catch (_: Exception) {
        return fallback           // 传了个 "abc"，当没传
    }
    if (value < minValue) { return minValue }
    if (value > maxValue) { return maxValue }
    return value
}

// 从查询串取一个字符串：取不到返回空串，超长按"字符"截断（不是按字节）
public func queryText(request: HttpRequest, name: String, maxLength: Int64): String {
    let raw = match (request.query.get(name)) {
        case Some(s) => s
        case None => return ""
    }
    let runes = raw.toRuneArray()
    if (runes.size <= maxLength) {
        return raw
    }
    var out = ""
    var i = 0
    while (i < maxLength) {
        out += runes[i].toString()
        i++
    }
    return out
}

// 从路径参数取一个整数：取不到或解析失败返回 -1（调用方据此返回 404）
public func routeInt(request: HttpRequest, name: String): Int64 {
    let raw = match (request.routeValues.get(name)) {
        case Some(s) => s
        case None => return -1
    }
    try {
        return Int64.parse(raw)
    } catch (_: Exception) {
        return -1
    }
}
