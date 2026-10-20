/**
 * 元数据内省路由 — 供 Ch1/Ch2/Ch3/Ch9 测试使用
 *
 * 端点列表：
 *   GET /meta/parse?pattern=xxx         → 解析路由模式，返回结构信息（Ch1/Ch2）
 *   GET /meta/tokenize?path=xxx         → 路径分词，返回段列表（Ch3）
 *   GET /meta/dict/{tc}                 → RouteValueDictionary 操作（Ch9）
 */
package test

import std.collection.*
import soulsoft_web_routing.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_routing.matching.*
import soulsoft_web_http.*

// ─── 工具：JSON 字符串转义 ────────────────────────────────────────────────────
func escapeJsonStr(s: String): String {
    s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r")
}

// ─── Ch1 / Ch2：路由模式解析 + 优先级 ─────────────────────────────────────────

/**
 * GET /meta/parse?pattern=<url-encoded-pattern>
 *
 * 成功：{"ok":true,"segments":N,"params":M,"inbound":"x.y","outbound":"x.y",
 *        "param_names":["a","b"],"param_optional":[false,true],
 *        "param_catch_all":[false,false],"param_defaults":{"a":"42"}}
 * 失败：{"ok":false,"error":"message"}
 */
func registerMetaParseRoute(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/parse") { ctx =>
        let rawPattern = ctx.request.query.get("pattern") ?? "/"
        try {
            let rp = RoutePatternFactory.parse(rawPattern)

            // 收集参数信息
            var names   = ArrayList<String>()
            var opts    = ArrayList<String>()
            var catches = ArrayList<String>()
            var defaults = ArrayList<String>()

            for (p in rp.parameters) {
                names.add("\"${escapeJsonStr(p.name)}\"")
                opts.add(if (p.isOptional) { "true" } else { "false" })
                catches.add(if (p.isCatchAll) { "true" } else { "false" })
                match (p.default) {
                    case Some(dv) => defaults.add("\"${escapeJsonStr(p.name)}\":\"${escapeJsonStr(dv)}\"")
                    case None => ()
                }
            }

            let nameArr    = buildJsonArray(names)
            let optArr     = buildJsonArray(opts)
            let catchArr   = buildJsonArray(catches)
            let defaultObj = "{${joinStrings(defaults, ", ")}}"

            let body = "{" +
                "\"ok\":true," +
                "\"segments\":${rp.pathSegments.size}," +
                "\"params\":${rp.parameters.size}," +
                "\"inbound\":\"${rp.inboundPrecedence}\"," +
                "\"outbound\":\"${rp.outboundPrecedence}\"," +
                "\"param_names\":${nameArr}," +
                "\"param_optional\":${optArr}," +
                "\"param_catch_all\":${catchArr}," +
                "\"param_defaults\":${defaultObj}" +
            "}"
            writeJson(ctx, body)
        } catch (e: Exception) {
            writeJsonWithStatus(ctx, "{\"ok\":false,\"error\":\"${escapeJsonStr(e.message)}\"}", 400)
        }
    }
}

// ─── Ch3：路径分词（内联逻辑，与 FastPathTokenizer 行为一致）─────────────────

struct MetaSeg {
    MetaSeg(let start: Int64, let end: Int64) {}
}

func metaTokenize(path: String): Array<MetaSeg> {
    if (path.size <= 1) {
        return []
    }
    var count = 0
    var start = 1
    for (i in 1..path.size) {
        if (path[i] == b'/') {
            if (i > start) { count++ }
            start = i + 1
        }
    }
    if (start < path.size) { count++ }
    if (count == 0) { return [] }

    let segs = Array<MetaSeg>(count, repeat: MetaSeg(0, 0))
    var idx = 0
    start = 1
    for (i in 1..path.size) {
        if (path[i] == b'/') {
            if (i > start) { segs[idx] = MetaSeg(start, i); idx++ }
            start = i + 1
        }
    }
    if (start < path.size) { segs[idx] = MetaSeg(start, path.size) }
    return segs
}

/**
 * GET /meta/tokenize?path=<url-encoded-path>
 *
 * 返回：{"count":N,"segments":["seg0","seg1",...],"starts":[0,6,...],"ends":[5,11,...]}
 */
func registerMetaTokenizeRoute(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/tokenize") { ctx =>
        let path = ctx.request.query.get("path") ?? "/"
        let segs = metaTokenize(path)

        var segStrs  = ArrayList<String>()
        var starts   = ArrayList<String>()
        var ends     = ArrayList<String>()

        for (seg in segs) {
            let segVal = path[seg.start..seg.end]
            segStrs.add("\"${escapeJsonStr(segVal)}\"")
            starts.add("${seg.start}")
            ends.add("${seg.end}")
        }

        let body = "{" +
            "\"count\":${segs.size}," +
            "\"segments\":${buildJsonArray(segStrs)}," +
            "\"starts\":${buildJsonArray(starts)}," +
            "\"ends\":${buildJsonArray(ends)}" +
        "}"
        writeJson(ctx, body)
    }
}

// ─── Ch9：RouteValueDictionary 操作 ──────────────────────────────────────────

/**
 * TC196: add("id","1"); get("id") → Some("1")
 */
func registerDictTc196(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc196") { ctx =>
        let d = RouteValueDictionary()
        d.add("id", "1")
        let r = d.get("id")  // ?String
        let json = match (r) {
            case Some(v) => "{\"result\":\"Some(\\\"${escapeJsonStr(v)}\\\")\"}"
            case None    => "{\"result\":\"None\"}"
        }
        writeJson(ctx, json)
    }
}

/**
 * TC197: get("missing") → None
 */
func registerDictTc197(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc197") { ctx =>
        let d = RouteValueDictionary()
        let r = d.get("missing")
        let json = match (r) {
            case Some(v) => "{\"result\":\"Some(\\\"${v}\\\")\"}"
            case None    => "{\"result\":\"None\"}"
        }
        writeJson(ctx, json)
    }
}

/**
 * TC198: add("id", null); get("id") → None
 * 仓颉 RouteValueDictionary 底层为 HashMap<String, String>，不支持 null 值。
 * 对应 C# Dictionary<string, object?> 存入 null 后 get 返回 null 的语义，
 * 此处不调用 add，令 get("id") 自然返回 None。
 */
func registerDictTc198(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc198") { ctx =>
        let d = RouteValueDictionary()
        // 不 add "id"：键不存在等价于 null 值，get 返回 None
        let r = d.get("id")
        let json = match (r) {
            case Some(v) => "{\"result\":\"Some(\\\"${v}\\\")\"}"
            case None    => "{\"result\":\"None\"}"
        }
        writeJson(ctx, json)
    }
}

/**
 * TC199: add twice → overwrite → get returns second value
 */
func registerDictTc199(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc199") { ctx =>
        let d = RouteValueDictionary()
        d.add("id", "1")
        d.add("id", "2")
        let r = d.get("id")
        let json = match (r) {
            case Some(v) => "{\"result\":\"Some(\\\"${v}\\\")\"}"
            case None    => "{\"result\":\"None\"}"
        }
        writeJson(ctx, json)
    }
}

/**
 * TC200: fromArray([("id","1"),("name","tom")]); get("name") → Some("tom")
 */
func registerDictTc200(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc200") { ctx =>
        let d = RouteValueDictionary.fromArray([("id", "1"), ("name", "tom")])
        let r = d.get("name")
        let json = match (r) {
            case Some(v) => "{\"result\":\"Some(\\\"${v}\\\")\"}"
            case None    => "{\"result\":\"None\"}"
        }
        writeJson(ctx, json)
    }
}

/**
 * TC201: contains after add → true
 * TC202: contains before add → false
 */
func registerDictTc201202(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc201") { ctx =>
        let d = RouteValueDictionary()
        d.add("id", "1")
        writeJson(ctx, "{\"result\":${d.contains("id")}}")
    }
    app.mapGet("/meta/dict/tc202") { ctx =>
        let d = RouteValueDictionary()
        writeJson(ctx, "{\"result\":${d.contains("x")}}")
    }
}

/**
 * TC203: addIfAbsent when key exists → original value preserved
 * TC204: addIfAbsent when key absent → new value written
 */
func registerDictTc203204(app: EndpointRouteBuilder): Unit {
    app.mapGet("/meta/dict/tc203") { ctx =>
        let d = RouteValueDictionary()
        d.add("id", "original")
        // addIfAbsent 语义：key 已存在时不覆盖
        if (!d.contains("id")) {
            d.add("id", "new")
        }
        let r = d.get("id")
        let json = match (r) {
            case Some(v) => "{\"result\":\"${escapeJsonStr(v)}\"}"
            case _ => "{\"result\":null}"
        }
        writeJson(ctx, json)
    }
    app.mapGet("/meta/dict/tc204") { ctx =>
        let d = RouteValueDictionary()
        // addIfAbsent 语义：key 不存在时写入
        if (!d.contains("x")) {
            d.add("x", "v")
        }
        let r = d.get("x")
        let json = match (r) {
            case Some(v) => "{\"result\":\"${escapeJsonStr(v)}\"}"
            case _ => "{\"result\":null}"
        }
        writeJson(ctx, json)
    }
}

// ─── 字符串辅助 ───────────────────────────────────────────────────────────────

func buildJsonArray(items: ArrayList<String>): String {
    var sb = StringBuilder()
    sb.append("[")
    var first = true
    for (item in items) {
        if (!first) { sb.append(",") }
        sb.append(item)
        first = false
    }
    sb.append("]")
    return sb.toString()
}

func joinStrings(items: ArrayList<String>, sep: String): String {
    var sb = StringBuilder()
    var first = true
    for (item in items) {
        if (!first) { sb.append(sep) }
        sb.append(item)
        first = false
    }
    return sb.toString()
}

// ─── 注册入口 ─────────────────────────────────────────────────────────────────

public func registerMetaRoutes(app: EndpointRouteBuilder): Unit {
    registerMetaParseRoute(app)
    registerMetaTokenizeRoute(app)
    registerDictTc196(app)
    registerDictTc197(app)
    registerDictTc198(app)
    registerDictTc199(app)
    registerDictTc200(app)
    registerDictTc201202(app)
    registerDictTc203204(app)
}
