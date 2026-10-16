package changxi_backend

import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_extensions_injection.*

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    // 注册路由中间件服务
    builder.services.addRouting()
    // 构建主机
    let host = builder.build()
    // 启用路由中间件
    host.useRouting()
    // 注册/hello终结点
    host.mapGet("hello") {
        context => context.response.write("hello cangjie.")
    }
    // 运行主机
    host.run()
    return 0
}
