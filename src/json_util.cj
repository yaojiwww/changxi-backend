package changxi_backend

import std.io.StringReader
import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// 请求体 / JSON 读取小工具
//
// 仓颉的 JsonValue 取值方式是"类型匹配后调 getValue()"：
//   json.asObject() 直接返回 JsonObject（类型不对会抛异常），
//   obj.get("k") 返回 ?JsonValue，再 match 到 JsonString/JsonInt 才知道真实类型。
// 每个接口都要写这一套太啰嗦，收在这里。
//
// 关键约定：**取不到 / 类型不对一律返回 None，不抛异常**。
// 请求体是客户端送来的，本来就是不可信输入，用异常处理它会把正常业务路径
// 和真正的 bug 混在一起（500 和 400 分不清）。
// =============================================================================

// 取字符串字段
public func jsonStringOf(obj: JsonObject, key: String): ?String {
    match (obj.get(key)) {
        case Some(v) =>
            match (v) {
                case s: JsonString => return s.getValue()
                case _ => return None
            }
        case None => return None
    }
}

// 取整数字段
public func jsonIntOf(obj: JsonObject, key: String): ?Int64 {
    match (obj.get(key)) {
        case Some(v) =>
            match (v) {
                case i: JsonInt => return i.getValue()
                case _ => return None
            }
        case None => return None
    }
}

// 可空字符串 → JSON：有值给 JsonString，没值给 JsonNull。
// 存在的意义是"数据库里的 NULL 必须是 JSON 的 null 而不是空字符串"这条约定：
// 前端的 parentKpId 用它判断"这是不是一级章节"，返回 "" 会被当成一个合法父节点名。
public func jsonStringOrNull(value: ?String): JsonValue {
    match (value) {
        case Some(v) => return JsonString(v)
        case None => return JsonNull()
    }
}

// 把请求体读成 JsonObject。
// 注意两种"看起来像错误、其实是正常输入"的情况：空请求体、body 不是 JSON 对象——
// 都返回 None，由调用方回 {code:1002}，而不是让异常冒到 500。
public func readJsonBody(context: HttpContext): ?JsonObject {
    let text = try {
        StringReader(context.request.body).readToEnd()
    } catch (e: Exception) {
        return None
    }
    if (text.isEmpty()) {
        return None
    }
    return try {
        Some(JsonValue.fromStr(text).asObject())
    } catch (e: Exception) {
        None
    }
}
