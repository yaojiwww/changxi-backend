package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// SSE（Server-Sent Events）写出工具
//
// 只负责"怎么把事件写到响应上"，不关心事件内容从哪来（Dify 那边的事在
// dify_client.cj / ai_controller.cj）。分开的理由：这一层的坑全是 HTTP 层的
// （分帧、缓冲、换行转义），跟业务一点关系都没有，混在一起会两边都看不清。
//
// 线格式很短：每个事件是 `data: {json}` 加一个空行。
//
//   data: {"event":"message","answer":"保育师需要掌握","conversationId":"abc"}
//
//   data: {"event":"message_end","conversationId":"abc"}
//
// =============================================================================

// —— 开流：设 SSE 响应头 ——
//
// 必须在**第一次 write 之前**调用。响应头不是独立的动作：第一次往 body 写字节时，
// 框架才把状态行 + 头一起发出去（见 DefaultHttpResponse.write），之后就锁死了
// （再改会被 ensureMutable 抛 IllegalStateException）。
//
// 三个头各自的理由：
//   ① Content-Type: text/event-stream —— 前端/网关据此认这是流。charset 必须显式写
//      utf-8，中文增量不能靠猜。
//   ② **不设 Content-Length** —— 长度在流结束前根本不知道。框架发现既没有
//      Content-Length 也没有 Transfer-Encoding 时会自动按 chunked 分帧，
//      正好是我们想要的"边算边发"。一旦手贱设了长度，就得攒完才能发，流式就没了。
//   ③ X-Accel-Buffering: no —— 给 nginx 这类反向代理看的：别把这个响应缓存起来
//      再一次性吐给前端，否则用户会看到"干等二十秒 → 哗一下全出来"。
//      Cache-Control 同理，中间任何一环缓存都可能把流式吃掉。
public func startSseResponse(response: HttpResponse): Unit {
    response.statusCode = StatusCodes.Ok
    response.contentType = "text/event-stream; charset=utf-8"
    response.headers.add("Cache-Control", ["no-cache"])
    response.headers.add("X-Accel-Buffering", ["no"])
}

// —— 把响应头真正推出去 ——
//
// ★ 开流之后必须**紧接着**调这个，不能等到第一个 Dify 增量。
//
// 原因：第一次 write 时框架才把状态行 + 响应头发给客户端，光设 content-type
// 是不发任何字节的。而智能体思考要 6~10 秒，这期间客户端一个字节都收不到——
// 前端的 connectTimeout 是 5 秒，会在 AI 开口之前就把连接掐了，然后报一句
// "AI 没有返回任何内容"（它那边收到的是空 body）。180 秒的 readTimeout 救不了，
// 因为那管的是"已经连上之后读数据"，这 5 秒是在它之前。
//
// 发的内容是一个 SSE 注释行（以冒号开头）。按 SSE 规范，客户端应当忽略它；
// 项目里的前端也是只认 `data:` 开头的行、其余跳过。所以它纯粹是"我还活着，
// 头先给你"的信号，不产生任何事件。
public func flushSseHeaders(response: HttpResponse): Unit {
    response.write(": stream opened\n\n")
}

// —— 写一个事件块 ——
//
// 两条不能破的规矩：
//   ① 分隔符是 **LF 空行**（\n\n），不是 CRLF。前端是按 '\n\n' 切块的，
//      发 \r\n\r\n 它那块就切不开。
//   ② 块内不能出现裸换行。answer 里带换行是家常便饭（AI 最爱用列表），
//      但它进 JSON 时是走 JsonString 的，换行会被转义成 \n 这两个**字符**，
//      正好既保住内容又不破坏分帧 —— 这就是"别手拼 JSON"的真正原因：
//      手拼字符串时，一个带换行的 answer 会把一个事件劈成两半，前端当场懵。
//
// 为什么每写完一个事件就 write 一次、不攒着一起写？——被调用的 write 就是
// "把这段数据发到客户端"，攒着就等于回到"等全部生成完再发"，前端逐字上屏
// 就没了。这是整个接口存在的意义。
public func writeSseEvent(response: HttpResponse, event: JsonObject): Unit {
    response.write("data: " + event.toString() + "\n\n")
}

// —— 一段增量文本 ——
// 字段名照抄 Dify（event / answer / conversationId），前端就是按这几个名字取的，
// 改名等于毁约。
public func writeSseDelta(response: HttpResponse, answer: String, conversationId: String): Unit {
    let event = JsonObject()
    event.put("event", JsonString("message"))
    event.put("answer", JsonString(answer))
    event.put("conversationId", JsonString(conversationId))
    writeSseEvent(response, event)
}

// —— 本轮结束 ——
// 只带 event 和 conversationId：前端收到它就认为这轮收完了。
public func writeSseMessageEnd(response: HttpResponse, conversationId: String): Unit {
    let event = JsonObject()
    event.put("event", JsonString("message_end"))
    event.put("conversationId", JsonString(conversationId))
    writeSseEvent(response, event)
}

// —— 流建立**之后**的失败 ——
//
// 这时候响应头早就发出去了，不可能再回头改成 4xx + JSON 信封，只能在流里
// 用一个 error 事件把原因告诉前端（前端会把它当一轮回答写进气泡）。
//
// 注意和"流建立之前的失败"的分工：那种走 writeApiError 回信封。两者的分界线
// 就是 response.hasStarted —— 一旦开写，就没有回头路。
public func writeSseError(response: HttpResponse, message: String): Unit {
    let event = JsonObject()
    event.put("event", JsonString("error"))
    event.put("message", JsonString(message))
    writeSseEvent(response, event)
}
