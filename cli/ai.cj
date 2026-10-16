package changxi_backend

import std.env.*
import std.io.StringReader
import stdx.encoding.json.*
import stdx.net.http.*
import stdx.net.tls.*

// =============================================================================
// AI 助手（对接 Dify 智能体）
//
// 接口：POST <base>/chat-messages
//   Header: Authorization: Bearer <API Key>
//   Body:   { "inputs": {}, "query": "...", "response_mode": "streaming",
//             "conversation_id": "", "user": "<用户标识>" }
//
// 响应：text/event-stream（SSE）流。每个事件是一段 "data: {json}"，空行分隔：
//   - message / agent_message：answer 字段是增量文本
//   - message_end：本次回复结束
//   - error：出错，message 字段是原因
//   conversation_id 每个事件都带，取到就存下来，下一轮带上即多轮记忆。
//
// 为什么用 streaming：Dify 的「智能体」类型应用只支持 streaming，
// blocking 会直接返回 400。streaming 对 Chatbot / Chatflow 也都兼容。
//
// 配置：API Key 从环境变量 DIFY_API_KEY 读，不写进代码；
//       接口基地址默认 https://api.dify.ai/v1，自建版用 DIFY_API_BASE 覆盖。
// =============================================================================

// Dify 云端接口基地址
public const DIFY_BASE_DEFAULT: String = "https://api.dify.ai/v1"

// Dify 的 user 字段：区分不同终端用户的标识。
// 现在还没有把「登录用户」传进来，先写死一个占位；等 aiAssistant 拿到当前
// 用户的昵称/手机号后替换，那时每个用户各有独立的多轮记忆。
public const AI_USER: String = "changxi-terminal"

// 一轮回复的结果
public class ChatReply {
    public var answer: String = ""
    public var conversationId: String = ""
}

// —— 读取 Dify API Key ——
// 读不到、或者读到的是空白，都返回 None，让调用方统一处理
func readApiKey(): ?String {
    match (getVariable("DIFY_API_KEY")) {
        case Some(raw) =>
            let key = raw.trimAscii()
            if (key.isEmpty()) {
                return None
            }
            return Some(key)
        case None => return None
    }
}

// —— 密钥脱敏：只显示末 4 位，其余打码 ——
// 密钥不该原样出现在终端或日志里，连自己调试时也别养成习惯
func maskKey(key: String): String {
    if (key.size <= 4) {
        return "****"
    }
    return "****" + key[key.size - 4..key.size]
}

// —— 接口基地址：环境变量 DIFY_API_BASE，没配就用 Dify 云端 ——
func readApiBase(): String {
    match (getVariable("DIFY_API_BASE")) {
        case Some(raw) =>
            let v = raw.trimAscii()
            if (v.isEmpty()) {
                return DIFY_BASE_DEFAULT
            }
            // 去掉结尾的 /，避免拼成 //chat-messages
            if (v.endsWith("/")) {
                return v[0..v.size - 1]
            }
            return v
        case None => return DIFY_BASE_DEFAULT
    }
}

// —— 从基地址里取出主机名 ——
// TLS 握手时要靠这个填 SNI（Server Name Indication）。仓颉的 TLS 客户端默认
// 不带 SNI，而 api.dify.ai 前面有网关，看不到 SNI 会直接掐断握手（alert 40）。
// "https://api.dify.ai/v1" -> "api.dify.ai"
func hostFromBase(base: String): String {
    var rest = base
    if (rest.startsWith("https://")) {
        rest = rest[8..rest.size]
    } else if (rest.startsWith("http://")) {
        rest = rest[7..rest.size]
    }
    // 砍掉路径部分：api.dify.ai/v1 -> api.dify.ai
    match (rest.indexOf("/")) {
        case Some(i) => rest = rest[0..i]
        case None => ()
    }
    // 砍掉端口：api.dify.ai:443 -> api.dify.ai
    match (rest.indexOf(":")) {
        case Some(i) => rest = rest[0..i]
        case None => ()
    }
    return rest
}

// —— 拼请求体 ——
// 用 JsonObject 序列化而不是手拼字符串：引号、换行、中文都会被正确转义
func chatBody(query: String, conversationId: String): String {
    let body = JsonObject()
    body.put("inputs", JsonObject())
    body.put("query", JsonString(query))
    body.put("response_mode", JsonString("streaming"))
    body.put("conversation_id", JsonString(conversationId))
    body.put("user", JsonString(AI_USER))
    return body.toJsonString(0, bracketInNewLine: false, indent: "")
}

// —— 取 JSON 对象里的字符串字段；缺字段或类型不对时回退到默认值 ——
func jsonString(obj: JsonObject, key: String, default: String): String {
    match (obj.get(key)) {
        case Some(v) =>
            match (v.kind()) {
                case JsonKind.JsString => v.asString().getValue()
                case _ => default
            }
        case None => default
    }
}

// 一条流式回复的解析中间状态（handleDataLine 逐事件往里填）
class ChatStream {
    public var answer: String = ""         // 累积的完整回答
    public var conversationId: String = "" // 服务端返回的会话 ID
    public var finished: Bool = false      // 已收到 message_end
    public var failed: Bool = false        // 已收到 error 事件
}

// —— 处理一条 SSE 事件的 data 内容 ——
func handleDataLine(payload: String, stream: ChatStream): Unit {
    try {
        let root = JsonValue.fromStr(payload).asObject()
        let delta = jsonString(root, "answer", "")
        if (!delta.isEmpty()) {
            stream.answer += delta
            print(delta, flush: true)
        }
        let cid = jsonString(root, "conversation_id", "")
        if (!cid.isEmpty()) {
            stream.conversationId = cid
        }
        let eventName = jsonString(root, "event", "")
        if (eventName == "message_end") {
            stream.finished = true
        } else if (eventName == "error") {
            stream.failed = true
            println("\nDify 出错：${jsonString(root, "message", "未知错误")}")
        }
    } catch (_: Exception) {
        // 坏掉的事件（解析失败、结构不对）直接跳过，别让一个坏事件毁掉整轮对话
    }
}

// —— 解析整段 SSE 文本，把增量拼成完整回答 ——
func parseStream(text: String, initialConvId: String): ?ChatReply {
    let stream = ChatStream()
    stream.conversationId = initialConvId

    // SSE 事件之间用空行分隔；每行 trim 一下顺带消化 \r\n 结尾
    for (event in text.split("\n\n", removeEmpty: true)) {
        for (rawLine in event.split("\n")) {
            let line = rawLine.trimAscii()
            if (line.startsWith("data:")) {
                let payload = line[5..line.size].trimAscii()
                if (!payload.isEmpty()) {
                    handleDataLine(payload, stream)
                }
            }
        }
    }

    if (stream.failed || stream.answer.isEmpty()) {
        return None
    }
    if (!stream.finished) {
        println("\n（回复可能不完整，连接已中断）")
    }
    let reply = ChatReply()
    reply.answer = stream.answer
    reply.conversationId = stream.conversationId
    return Some(reply)
}

// —— 从 Dify 的错误响应 JSON 里提取 message；提不出就用原文 ——
func httpErrorMessage(raw: String): String {
    try {
        let root = JsonValue.fromStr(raw).asObject()
        let msg = jsonString(root, "message", "")
        if (!msg.isEmpty()) {
            return msg
        }
    } catch (_: Exception) {}
    return raw
}

// —— 发一轮消息；成功返回 (answer, conversation_id)，失败返回 None ——
func askDify(client: Client, apiKey: String, base: String, query: String,
             conversationId: String): ?ChatReply {
    let req = HttpRequestBuilder()
        .post()
        .url("${base}/chat-messages")
        .header("Authorization", "Bearer ${apiKey}")
        .header("Content-Type", "application/json")
        .body(chatBody(query, conversationId))
        .build()
    try {
        let resp = client.send(req)
        let text = StringReader(resp.body).readToEnd()
        if (resp.status != 200) {
            // Dify 的 HTTP 错误体是 { "code", "message", "status" }
            println("Dify 返回错误（HTTP ${resp.status}）：${httpErrorMessage(text)}")
            return None
        }
        return parseStream(text, conversationId)
    } catch (e: HttpTimeoutException) {
        println("请求超时：${e.message}")
        return None
    } catch (e: Exception) {
        println("请求失败：${e.message}")
        return None
    }
}

// —— 进入 AI 助手：终端里和 Dify 智能体多轮对话 ——
func aiAssistant(): Unit {
    println("")
    println("---- AI 助手 ----")

    let apiKey = match (readApiKey()) {
        case Some(k) => k
        case None =>
            println("没能读到 API 密钥，无法连接 Dify。")
            println("请先在终端里设置环境变量，然后重新启动本程序：")
            println("    export DIFY_API_KEY=app-你的密钥")
            return
    }
    let base = readApiBase()
    println("连接 Dify（${base}），密钥 ${maskKey(apiKey)}")

    // 智能体想事情可能要一两分钟，读超时放宽到 5 分钟
    var tls = TlsClientConfig()
    // 必须显式告诉 TLS 要去连哪个域名：仓颉默认不发 SNI，网关会拒握手
    tls.serverName = hostFromBase(base)
    let client = ClientBuilder()
        .tlsConfig(tls)
        .readTimeout(Duration.second * 300)
        .build()
    try {
        var conversationId = ""
        println("直接输入你的问题，输入 /exit 退出。")
        while (true) {
            println("")
            prompt("你：")
            let line = match (readLineOrEof()) {
                case Some(l) => l.trimAscii()
                case None => break
            }
            if (line == "/exit") {
                break
            }
            if (line.isEmpty()) {
                continue
            }
            print("AI：", flush: true)
            match (askDify(client, apiKey, base, line, conversationId)) {
                case Some(reply) =>
                    conversationId = reply.conversationId
                case None => ()
            }
            println("")
        }
    } finally {
        client.close()
    }
    println("已退出 AI 助手")
}
