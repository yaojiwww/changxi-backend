package changxi_backend

import std.convert.*
import stdx.encoding.json.*
import soulsoft_web_http.*

// 把前端传回的会话ID解析成整数；非法或非正数一律返回 -1
func tryParseId(raw: String): Int64 {
    try {
        let value = Int64.parse(raw)
        if (value <= 0) {
            return -1
        }
        return value
    } catch (_: Exception) {
        return -1
    }
}

// 聊天接口（mock 版本，后续接入 Dify）
public func handleChat(ctx: HttpContext): Unit {
    // 鉴权：没带 token，或 token 无效/过期，统一按未登录处理。
    // 校验放在 handler 开头而不是用 requireAuthorization，
    // 是因为框架的 401 不带 JSON body，和本项目统一响应格式对不上
    let userId = match (currentUser(ctx)) {
        case Some(id) => id
        case None =>
            writeError(ctx.response, 401, 401, "未登录或登录已过期")
            return
    }

    let body = readRequestBody(ctx.request)
    let message = jsonField(body, "message")
    let conversationId = jsonField(body, "conversationId")

    if (message.isEmpty()) {
        writeError(ctx.response, 400, 1, "消息不能为空")
        return
    }

    // 模拟回复内容（接 Dify 的那轮会换成真实调用）
    let reply = "你好，我是畅溪AI助手。你刚才说：${message}"

    // 先落库、成功之后再开 SSE 流：
    // 这样数据库出错时还能返回正常的 JSON 错误，不会吐半截流出去
    var convId: Int64 = 0
    if (conversationId.isEmpty()) {
        // 首轮：建会话 + 写两条消息，返回内部自增 id 作为 conversationId
        convId = createConversationWithMessages(userId, message, reply)
    } else {
        let parsed = tryParseId(conversationId)
        if (parsed < 0) {
            writeError(ctx.response, 400, 2, "会话ID不合法")
            return
        }
        // 归属校验在 appendChatMessages 的 SQL 里做，不是自己的会话查不到
        if (!appendChatMessages(parsed, userId, message, reply)) {
            writeError(ctx.response, 404, 3, "会话不存在")
            return
        }
        convId = parsed
    }

    // 模拟流式响应
    ctx.response.contentType = "text/event-stream; charset=utf-8"
    ctx.response.statusCode = 200

    let words = reply.toRuneArray()

    // 分块发送（模拟流式效果）
    var i = 0
    var chunk = ""
    while (i < words.size) {
        chunk += words[i].toString()
        // 每3个字符发一次
        if (chunk.toRuneArray().size >= 3 || i == words.size - 1) {
            let data = JsonObject()
            data.put("type", JsonString("message"))
            data.put("content", JsonString(chunk))
            ctx.response.write("data: ${data.toString()}\n\n")
            chunk = ""
        }
        i++
    }

    // 发送结束信号，带上真实会话ID，前端下一轮原样传回来
    let endData = JsonObject()
    endData.put("type", JsonString("end"))
    endData.put("conversationId", JsonString(convId.toString()))
    endData.put("content", JsonString(""))
    ctx.response.write("data: ${endData.toString()}\n\n")
}
