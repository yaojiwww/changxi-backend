package changxi_backend

import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_extensions_injection.*

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    builder.configuration["HTTP_PORTS"] = "8080"
    builder.services.addRouting()

    let app = builder.build()
    app.useRouting()

    // 健康检查：部署后用它确认服务活着
    app.mapGet("/hello") { ctx =>
        ctx.response.contentType = "text/plain; charset=utf-8"
        ctx.response.write("changxi 后端已就绪")
    }

    // 业务路由按接口文档逐域接入：认证域 → 业务域
    // 认证域
    app.mapPost("/api/v1/auth/send-code") { ctx => handleSendCode(ctx) }
    app.mapPost("/api/v1/auth/register") { ctx => handleRegister(ctx) }
    app.mapPost("/api/v1/auth/login") { ctx => handleLogin(ctx) }
    app.mapPost("/api/v1/auth/logout") { ctx => handleLogout(ctx) }
    
    // 业务域
    app.mapPost("/api/v1/chat") { ctx => handleChat(ctx) }

    // 绑定 0.0.0.0：监听所有网卡，局域网/外网设备才能访问（默认的 127.0.0.1 只对本机开放）
    app.run("http://0.0.0.0:8080")
    return 0
}
