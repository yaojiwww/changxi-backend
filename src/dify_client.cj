package changxi_backend

import std.collection.*
import std.env.*
import std.io.*
import stdx.encoding.json.*
// ★ 这里**不能**写 stdx.net.http.* —— 它和 soulsoft_web_http 都导出了
//   HttpResponse / HttpContext 两个同名类型，通配导入会让编译器分不清用哪个，
//   报一堆 "ambiguous use of 'HttpResponse'"。只按名字取要用的三个。
import stdx.net.http.{Client, ClientBuilder, HttpRequestBuilder, HttpResponse as DifyHttpResponse}
import stdx.net.tls.*
import soulsoft_web_http.*

// =============================================================================
// Dify 客户端（流式）
//
// 这是 cli/ai.cj 那套东西的服务端版本。相同的部分照搬（配置读取、TLS SNI、
// 请求体拼法、错误信息提取），**根本区别在解析**：
//
//   cli 版是 readToEnd() 把整段响应读回来，再一次性切成事件、拼成完整回答，
//   最后才 print —— 因为终端就是要"打完这一轮的字"。
//
//   这里必须反过来：读一段就往外发一段。所以解析器从"整段切"改成"增量切片"，
//   见下面的 SseLineReader。这是整个文件里唯一真正需要动脑的地方。
//
// 接口：POST <base>/chat-messages
//   Header: Authorization: Bearer <API Key>
//   Body:   { "inputs": {"mode": "…"}, "query": "…", "response_mode": "streaming",
//             "conversation_id": "…", "user": "<用户 id>" }
//
// 为什么 response_mode 一定是 streaming：Dify 的「智能体」类型应用只支持 streaming，
// blocking 会直接返回 400。对 Chatbot / Chatflow 也都兼容。
// =============================================================================

// Dify 云端接口基地址（自建版用环境变量 DIFY_API_BASE 覆盖）
const DIFY_BASE_DEFAULT: String = "https://api.dify.ai/v1"

// 一次 read 要多少字节。4KB 是个折中：太小则系统调用次数多，太大则首字延迟变高
// （得等缓冲区攒满或对端关闭才返回）。
const DIFY_READ_CHUNK: Int64 = 4096

// —— 读 API Key ——
// 读不到、或者读到的是空白，都返回 None，让调用方统一处理。
// 密钥只走环境变量，不进代码也不进 appsettings.json（那个文件是要提交的）。
func readDifyApiKey(): ?String {
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

// —— 接口基地址 ——
func readDifyApiBase(): String {
    match (getVariable("DIFY_API_BASE")) {
        case Some(raw) =>
            let value = raw.trimAscii()
            if (value.isEmpty()) {
                return DIFY_BASE_DEFAULT
            }
            // 去掉结尾的 /，否则会拼成 //chat-messages
            if (value.endsWith("/")) {
                return value[0..value.size - 1]
            }
            return value
        case None => return DIFY_BASE_DEFAULT
    }
}

// —— 从基地址里取出主机名 ——
//
// TLS 握手时要靠这个填 SNI（Server Name Indication）。仓颉的 TLS 客户端**默认不发
// SNI**，而 api.dify.ai 前面有网关，看不到 SNI 会直接掐断握手（alert 40）。
// 这个坑在 cli 版踩过一次，实测必须显式设 tls.serverName。
//   https://api.dify.ai/v1 -> api.dify.ai
func hostFromBase(base: String): String {
    var rest = base
    if (rest.startsWith("https://")) {
        rest = rest[8..rest.size]
    } else if (rest.startsWith("http://")) {
        rest = rest[7..rest.size]
    }
    // 砍掉路径：api.dify.ai/v1 -> api.dify.ai
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

// —— 启动横幅里加一行 ——
// "密钥到底读到了没有"是这套东西最容易出岔子的地方（容器里环境变量没传进来、
// 拼错了名字），必须开机就看得见，而不是等第一次提问失败再去猜。
func logDifyConfig(): Unit {
    match (readDifyApiKey()) {
        case Some(key) => serverLog("  Dify    : ${readDifyApiBase()}  密钥 ${maskSecret(key)}")
        case None =>
            serverLog("  Dify    : ！！没读到环境变量 DIFY_API_KEY，/api/v1/ai/chat 会直接回错")
    }
}

// —— 拼请求体 ——
// 用 JsonObject 而不是手拼字符串：query 里的引号、换行、中文都会被正确转义。
func difyChatBody(query: String, conversationId: String, mode: String, user: String): String {
    let inputs = JsonObject()
    // mode 由前端传下来，Dify 那边拿它做分支（题目解答 / 专属规划）。
    // Dify 侧没定义这个变量时会被忽略，不影响提问本身。
    inputs.put("mode", JsonString(mode))

    let body = JsonObject()
    body.put("inputs", inputs)
    body.put("query", JsonString(query))
    body.put("response_mode", JsonString("streaming"))
    // 空串 = 新会话；带上上一轮的 ID = 续聊，Dify 靠它取历史做多轮记忆
    body.put("conversation_id", JsonString(conversationId))
    // ★ 用户标识必须跟着登录用户走。写死一个常量的话，所有人共用同一份多轮记忆，
    //   甲问过的问题会以"上下文"的形式影响乙拿到的回答。
    body.put("user", JsonString(user))
    return body.toString()
}

// —— 从 Dify 的错误响应里提取给用户看的原因 ——
func difyErrorMessage(raw: String): String {
    let text = raw.trimAscii()
    if (text.isEmpty()) {
        return "无响应内容"
    }
    // Dify 的 HTTP 错误体是 { "code": "…", "message": "…", "status": … }
    let parsed: ?JsonObject = try {
        Some(JsonValue.fromStr(text).asObject())
    } catch (e: Exception) {
        None
    }
    match (parsed) {
        case Some(obj) =>
            let message = jsonStringOf(obj, "message") ?? ""
            if (!message.isEmpty()) {
                return message
            }
        case None => ()
    }
    // 不是 JSON（比如网关返回的 HTML 错误页）：截断再用，别把一大坨塞进 message
    if (text.size > 200) {
        return text[0..200] + "…"
    }
    return text
}

// =============================================================================
// 一条还没读完的 Dify 流
//
// client 和 response 要一起交给上层，读完由上层统一关掉。分开传的话很容易
// 只关一个——client 是每次请求现建的，漏关就是漏一个连接池 + 一条 TLS 连接。
// =============================================================================
class DifyStream {
    public let client: Client
    // 注意这里是 stdx 的 HttpResponse（Dify 是我们用 HTTP 客户端连的**外部**服务），
    // 不是 Spire 那个——同名不同物，所以导入时给它起了别名 DifyHttpResponse。
    public let response: DifyHttpResponse

    public init(client: Client, response: DifyHttpResponse) {
        this.client = client
        this.response = response
    }
}

// 关流。任何一步失败都不该盖住真正的业务错误，所以各自 try 掉。
func closeDifyStream(stream: DifyStream): Unit {
    try {
        // 没读完的 body 必须显式 close，否则连接不会被回收
        stream.response.close()
    } catch (e: Exception) {
        ()
    }
    try {
        stream.client.close()
    } catch (e: Exception) {
        ()
    }
}

// =============================================================================
// 开流：连 Dify 并把响应头拿到手
//
// 返回 None 表示**已经回过响应了**（统一信封），调用方直接 return 即可——
// 和 authenticate() / requireBodyObject() 一个路子。
//
// 返回值拿到手时，SSE 流还没开始写：调用方可以放心地先用信封回错误。这就是
// "流建立之前的失败"和"之后的失败"的分界线。
//
// 为什么每次请求新建一个 Client 而不是复用一个全局的？
//   ① stdx 的 Client 对同一个服务端有"最多 10 条连接"的限制，超了直接抛异常。
//      AI 问答是长连接、慢请求，几个用户同时问就可能撞上。
//   ② 复用就得考虑并发安全，成本远大于一条 TLS 握手的开销（约 100~300ms，
//      相对智能体十几秒的思考时间可以忽略）。
//   代价是每轮问答多一次 TLS 握手。等真机上量了再考虑连接池，现在不值得。
// =============================================================================
func openDifyStream(context: HttpContext, query: String, conversationId: String,
                    mode: String, userId: String): ?DifyStream {
    let apiKey = match (readDifyApiKey()) {
        case Some(key) => key
        case None =>
            // 这是服务端自己没配好，不是用户请求有问题，所以回 500 而不是 4xx
            serverLog("[AI] 环境变量 DIFY_API_KEY 没读到，拒绝本轮提问")
            writeApiError(context.response, StatusCodes.InternalServerError, ApiCode.SERVER_ERROR,
                "服务端未配置 AI 服务密钥，暂时无法使用 AI 伴学")
            return None
    }

    let base = readDifyApiBase()
    var tls = TlsClientConfig()
    // ★ 显式设 SNI，不设会被 Dify 前面的网关拒握手
    tls.serverName = hostFromBase(base)
    let client = ClientBuilder()
        .tlsConfig(tls)
        // 智能体要先想、再调工具，首字十几秒很正常。前端读超时是 180 秒，
        // 后端必须比它更宽容，否则会变成"后端先掐，前端莫名报网络错误"。
        .readTimeout(Duration.second * 300)
        .build()

    let request = HttpRequestBuilder()
        .post()
        .url("${base}/chat-messages")
        .header("Authorization", "Bearer ${apiKey}")
        .header("Content-Type", "application/json")
        .body(difyChatBody(query, conversationId, mode, userId))
        .build()

    let response = try {
        client.send(request)
    } catch (e: Exception) {
        closeClientQuietly(client)
        // 连不上（DNS、TLS、超时、网络不通）——属于"流建立之前"，回信封
        serverLog("[AI] 连接 Dify 失败：${e.toString()}")
        writeApiError(context.response, StatusCodes.BadGateway, ApiCode.SERVER_ERROR,
            "连接 AI 服务失败：${shorten(e.message)}")
        return None
    }

    if (response.status != 200) {
        // 非 200 时 body 是错误 JSON，读出来给用户看原因（密钥错、额度用完、
        // 应用类型不对……都在这里面）。这一步仍然在"开流之前"，照样回信封。
        let raw = try {
            StringReader(response.body).readToEnd()
        } catch (e: Exception) {
            ""
        }
        try {
            response.close()
        } catch (e: Exception) {
            ()
        }
        closeClientQuietly(client)
        let reason = difyErrorMessage(raw)
        serverLog("[AI] Dify 返回 HTTP ${response.status}：${reason}")
        writeApiError(context.response, StatusCodes.BadGateway, ApiCode.SERVER_ERROR,
            "AI 服务返回错误（HTTP ${response.status}）：${reason}")
        return None
    }

    return Some(DifyStream(client, response))
}

func closeClientQuietly(client: Client): Unit {
    try {
        client.close()
    } catch (e: Exception) {
        ()
    }
}

// 日志和给前端的 message 都可能被贴出去，长错误信息截一下
func shorten(text: String): String {
    if (text.size > 200) {
        return text[0..200] + "…"
    }
    return text
}

// =============================================================================
// SseLineReader：把字节流切成一行行
//
// 两个必须处理的现实：
//   ① 一次 read() 回来多少字节是不确定的：可能正好断在 `data:` 中间，也可能一次
//      带回三个半事件。所以要有"待处理缓冲区"，凑齐一个换行才算一行。
//   ② **缓冲区里可能有半个汉字**。一次 read 很可能正好切在 UTF-8 三字节序列中间，
//      这时直接 fromUtf8 会解出乱码甚至抛异常，而且后面再也补不回来。
//
//      这里的解法是：只在**换行符处**切分、然后才解码。UTF-8 里 \n（0x0A）只会
//      以单字节形态出现，绝不可能出现在某个多字节字符的内部，所以"按 \n 切出来的
//      每一段一定是完整合法的 UTF-8"。凑不出换行的残留就留在缓冲区等下次 read，
//      天然不会解到半个字——不需要手写 UTF-8 状态机。
//
// （前端 AIChatApi.ets 遇到的是同一个问题，它那边是开 stream 模式让解码器自己缓，
//   我们这边没有现成的流式解码器，就用上面这个更朴素的招。）
// =============================================================================
class SseLineReader {
    private let input: InputStream
    private let chunk = Array<Byte>(DIFY_READ_CHUNK, repeat: 0)
    private var pending = ArrayList<Byte>()   // 已读进来、还没凑出换行的字节
    private var eof = false

    public init(input: InputStream) {
        this.input = input
    }

    // 读下一行（不含行尾换行符）。流读完且没有残留时返回 None。
    public func readLine(): ?String {
        while (true) {
            let index = indexOfLf()
            if (index >= 0) {
                let line = decodeRange(0, index)
                // 连同换行符一起消费掉（range 是左闭右开，+1 把它也包含进来）
                pending.remove(0..index + 1)
                return Some(line)
            }
            if (eof) {
                if (pending.isEmpty()) {
                    return None
                }
                // 最后一行可能不带换行符（SSE 规范允许），也得吐出去
                let line = decodeRange(0, pending.size)
                pending.clear()
                return Some(line)
            }
            // read 返回 0 表示 Dify 那边正常结束了；连接中途断开则抛 ConnectionException
            let count = input.read(chunk)
            if (count <= 0) {
                eof = true
                continue
            }
            for (i in 0..count) {
                pending.add(chunk[i])
            }
        }
        // 走不到这儿（上面 while(true) 只会 return 或者继续），但仓颉不认为
        // while(true) 一定发散，函数体末尾得有个显式的返回值才肯编译。
        return None
    }

    // 缓冲区里第一个 \n 的下标，找不到返回 -1
    private func indexOfLf(): Int64 {
        for (i in 0..pending.size) {
            if (pending[i] == b'\n') {
                return i
            }
        }
        return -1
    }

    private func decodeRange(from: Int64, to: Int64): String {
        let bytes = Array<Byte>(to - from, repeat: 0)
        for (i in 0..(to - from)) {
            bytes[i] = pending[from + i]
        }
        return String.fromUtf8(bytes)
    }
}

// =============================================================================
// 事件转发
// =============================================================================

// 转发过程中要记住的状态
class DifyForwardState {
    public var conversationId: String = ""   // 最近一次收到的会话 ID
    public var finished: Bool = false        // 收到 message_end
    public var failed: Bool = false          // 收到 error
}

// 处理 Dify 流里的一行：只有 `data:` 开头的行是事件
// （Dify 把事件类型放在 JSON 的 event 字段里，不另起 event: 行）
func handleDifyLine(response: HttpResponse, line: String, state: DifyForwardState): Unit {
    let trimmed = line.trimAscii()
    if (!trimmed.startsWith("data:")) {
        return   // 空行、注释行等，跳过
    }
    let payload = trimmed[5..].trimAscii()
    if (payload.isEmpty()) {
        return
    }
    forwardDifyEvent(response, payload, state)
}

// 把一个 Dify 事件转成前端契约里的事件并写出去。
//
// 转发规则：有 answer 就发、message_end 就发、error 就发，其余丢掉
// （ping 心跳、workflow_started / node_finished 这类中间事件前端用不上）。
//
// 必须重新拼 JSON 而不是原样转发：Dify 的字段是 snake_case 的 conversation_id，
// 前端取的是 camelCase 的 conversationId，且它只认 event/answer/conversationId/message
// 这四个名字。
func forwardDifyEvent(response: HttpResponse, payload: String, state: DifyForwardState): Unit {
    let parsed: ?JsonObject = try {
        Some(JsonValue.fromStr(payload).asObject())
    } catch (e: Exception) {
        None
    }
    let root = match (parsed) {
        case Some(obj) => obj
        case None =>
            // 坏掉的事件（解析失败、不是对象）直接跳过：别让一个坏事件毁掉整轮回答
            serverLog("[AI] 跳过解析不了的事件：${shorten(payload)}")
            return
    }

    // conversation_id 不是每条都带，但取到就存下来，后面的事件沿用
    let conversationId = jsonStringOf(root, "conversation_id") ?? ""
    if (!conversationId.isEmpty()) {
        state.conversationId = conversationId
    }

    let eventName = jsonStringOf(root, "event") ?? ""

    if (eventName == "error") {
        state.failed = true
        writeSseError(response, jsonStringOf(root, "message") ?? "AI 服务出错")
        return
    }

    let delta = jsonStringOf(root, "answer") ?? ""
    if (!delta.isEmpty()) {
        // ★ 增量立刻转发，一个字节都不攒 —— 前端是逐字上屏的
        writeSseDelta(response, delta, state.conversationId)
        return
    }

    if (eventName == "message_end") {
        state.finished = true
        writeSseMessageEnd(response, state.conversationId)
    }
}

// 尽力发一条 error 事件。前端已经断开（用户退出页面）时 write 会抛，
// 那种场合没人收这条事件，别让它再炸一次把日志刷满。
func tryWriteSseError(response: HttpResponse, message: String): Unit {
    try {
        writeSseError(response, message)
    } catch (e: Exception) {
        ()
    }
}
