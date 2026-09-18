package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*

// 聊天接口（mock 版本，后续接入 Dify）
public func handleChat(ctx: HttpContext): Unit {
    let body = readRequestBody(ctx.request)
    let message = jsonField(body, "message")
    let conversationId = jsonField(body, "conversationId")
    
    if (message.isEmpty()) {
        writeError(ctx.response, 400, 1, "消息不能为空")
        return
    }
    
    // 模拟流式响应
    ctx.response.contentType = "text/event-stream; charset=utf-8"
    ctx.response.statusCode = 200
    
    // 模拟回复内容
    let reply = "你好，我是畅溪AI助手。你刚才说：${message}"
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
    
    // 发送结束信号
    let endData = JsonObject()
    endData.put("type", JsonString("end"))
    let convId = if (conversationId.isEmpty()) { "mock_conv_001" } else { conversationId }
    endData.put("conversationId", JsonString(convId))
    endData.put("content", JsonString(""))
    ctx.response.write("data: ${endData.toString()}\n\n")
}
