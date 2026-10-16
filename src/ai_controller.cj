package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// AI 伴学接口：POST /api/v1/ai/chat（SSE 流式）
//
// 请求体：{ "query": "…", "conversationId": "", "mode": "solve" }
//   conversationId —— 首轮空串；之后前端把上一轮下发的 ID 原样带回（多轮记忆靠它）
//   mode           —— solve(题目解答) / plan(专属规划)，作为 Dify 的 inputs.mode 传下去
//
// 成功：text/event-stream，事件块之间用 LF 空行分隔，字段名照抄 Dify：
//   data: {"event":"message","answer":"增量","conversationId":"abc"}
//   data: {"event":"message_end","conversationId":"abc"}
//
// 失败分两种，分界线是"响应开写了没有"：
//   · 开写之前（没带令牌 / query 为空 / 连不上 Dify / Dify 报 4xx）→ 统一信封
//     4xx + {code,message,data:null}。前端拿不到 SSE 事件时正是靠解析这个信封
//     把 message 弹给用户，**空 body 会让它只剩一句"AI 没有返回任何内容"**，
//     排查方向全歪。
//   · 开写之后（流中途断、Dify 中途报错）→ 没法改状态码了，只能在流里发一条
//     {"event":"error","message":"原因"}。
//
// 关于线程：这个 handler 会一直阻塞到本轮回答结束（可能几十秒到几分钟）。
// stdx 的服务端是"一条连接一个线程"，各请求互不排队，所以这个阻塞是可接受的——
// 但也意味着别在这里面做需要共享状态的事。
// =============================================================================

// 提问模式，值与前端 model/ChatModels.ets 里的常量一一对应。
// 不认别的值（比如大写 SOLVE）：静默放行的话，前端把 mode 拼错时会拿到一份
// "看起来正常、其实是通用提示词"的回答，比直接报错难查得多——和 practice
// 接口里 tab 只认 basic/professional 是同一个理由。
const AI_MODE_SOLVE: String = "solve"
const AI_MODE_PLAN: String = "plan"

public func handleAiChat(context: HttpContext, services: AppServices): Unit {
    // ① 鉴权。拿不到就直接 return——authenticate 自己已经回过 401 信封了，
    //    这里再写一遍会变成两个响应体。
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return
    }
    let user = userOpt.getOrThrow()

    // ② 取参。所有校验都必须在"开写"之前做完：一旦写了第一个字节，
    //    状态码和响应头就发出去了，想改也改不了。
    let body = requireBodyObject(context) ?? return

    let query = (jsonStringOf(body, "query") ?? "").trimAscii()
    if (query.isEmpty()) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
            "缺少 query 字段或内容为空")
        return
    }

    let mode = jsonStringOf(body, "mode") ?? ""
    if (!mode.isEmpty() && mode != AI_MODE_SOLVE && mode != AI_MODE_PLAN) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
            "mode 只能是 solve 或 plan")
        return
    }

    // 空串 = 首轮，是合法输入，不是错误
    let conversationId = jsonStringOf(body, "conversationId") ?? ""

    serverLog("AI 提问 user=${user.id} mode=${mode} 轮次=${if (conversationId.isEmpty()) { "首轮" } else { "续聊" }} 字数=${query.size}")

    // ③ 先连 Dify，再开流 —— 顺序不能反。
    //
    // "连不上 Dify"和"Dify 返回非 200"都属于**流建立之前**的失败：这时候响应还
    // 一个字节没写，可以老老实实回统一信封（4xx + JSON），前端就能把 message
    // 弹给用户。一旦调了 startSseResponse，状态码和响应头就发出去了，再想回
    // JSON 信封是做不到的，只能往流里塞一条 error 事件。
    //
    // ★ 这里千万别写成 `let dify = openDifyStream(...) ?? return`：仓颉的 return
    //   后面可以跟一个表达式，于是下一行的 startSseResponse(...) 会被当成这个
    //   表达式的开头，编译器只能猜（并报 "possibly confusing line terminator"）。
    //   猜对了是"提前返回"，猜错了就是"返回 startSseResponse(...) 的结果"——
    //   整个流式循环被静默跳过。显式写成 if 就没有这种余地。
    let difyOpt = openDifyStream(context, query, conversationId, mode, user.id.toString())
    if (difyOpt.isNone()) {
        return   // 失败时 openDifyStream 已经把信封写好了
    }
    let dify = difyOpt.getOrThrow()
    startSseResponse(context.response)
    // ★ 立刻把响应头发出去。Dify 第一个字可能 6~10 秒后才到，这段空窗期里
    //   客户端一个字节都收不到，会被自己的连接超时干掉（见 sse.cj 的说明）。
    flushSseHeaders(context.response)

    // ④ 边收边发
    let state = DifyForwardState()
    state.conversationId = conversationId
    try {
        let reader = SseLineReader(dify.response.body)
        // 收到 message_end 或 error 就收工。多读无益：前者本轮已结束，
        // 后者是在给 Dify 白打工。
        while (!state.finished && !state.failed) {
            match (reader.readLine()) {
                case Some(line) => handleDifyLine(context.response, line, state)
                case None => break
            }
        }
        // 没等到 message_end 流就没了：Dify 半路把连接掐了，或者一个事件都没吐。
        // 得告诉前端，否则它那边只会显示"AI 没有返回内容"，排查方向全歪。
        if (!state.finished && !state.failed) {
            tryWriteSseError(context.response, "AI 回复中断，请重试")
        }
    } catch (e: Exception) {
        // 读 Dify 流、往响应写字节都可能抛。往响应写的时候抛，通常是**前端自己
        // 断开了**（用户退出页面）——那种情况下这条 error 事件没人收，写它只会
        // 再抛一次，所以必须用"尽力而为"的版本。
        serverLog("[AI 流中断] user=${user.id}：${e.toString()}")
        tryWriteSseError(context.response, "AI 连接中断，请重试")
    } finally {
        closeDifyStream(dify)
    }

    serverLog("AI 回答结束 user=${user.id} 会话=${state.conversationId}")
}
