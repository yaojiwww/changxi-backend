/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * test_server 主入口
 * 按章节注册所有路由，覆盖 TEST_PLAN.md 中的 264 条测试用例
 *
 * 默认服务地址：http://0.0.0.0:15130
 *
 * 路由前缀约定：
 *   /meta/...   - 元数据内省（Ch1/Ch2/Ch3/Ch9）
 *   /ch01/...   - 第一章 路由模式解析 [P1]
 *   /ch04/...   - 第四章 DFA 匹配器核心 [P0]
 *   /ch05/...   - 第五章 复合段匹配 [P1]
 *   /ch06/...   - 第六章 HTTP 方法匹配 [P0]
 *   /ch07/...   - 第七章 端点选择与歧义处理 [P0]
 *   /ch08/...   - 第八章 DFA 构建行为 [P2]
 *   /ch10/...   - 第十章 约束类边界 [P1]
 *   /ch11/...   - 第十一章 端到端集成 [P1]
 *   /ch12/...   - 第十二章 ASP.NET Core 对齐 [P0]
 *   /ch13/...   - 第十三章 约束优化 [P2]
 *   /ch14/...   - 第十四章 OutboundPrecedence [P2]
 */
package test

import soulsoft_web_http.*
import soulsoft_web_cors.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_extensions_injection.*

private const DefaultPortBase: Int64 = 15130

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultPortBase)
    builder.services.addRouting()
    // 注册 CORS 服务，配置与 test_server/aspnet_verify/Program.cs 一致：
    //   默认策略：仅允许 https://allowed.com，AllowAnyMethod，AllowAnyHeader
    //   命名策略 "strict"：仅允许 https://strict.com，AllowAnyMethod，AllowAnyHeader
    builder.services.addCors { options =>
        options.addDefaultPolicy { policy =>
            policy.withOrigins(["https://allowed.com"]).allowAnyMethod().allowAnyHeader()
        }
        options.addPolicy("strict") { policy =>
            policy.withOrigins(["https://strict.com"]).allowAnyMethod().allowAnyHeader()
        }
    }

    let app = builder.build()
    // 错误处理中间件：捕获所有未处理异常，将错误信息以纯文本写入 500 响应体，
    // 供 Python 测试客户端拦截器读取，实现服务端异常的端到端可见性。
    app.use { context, next =>
        try {
            next(context)
        } catch (e: Exception) {
            context.response.statusCode = 500
            context.response.contentType = "text/plain; charset=utf-8"
            // toString() 返回 "ClassName: message"，printStackTrace() 仅打印到 stderr
            context.response.write(e.toString())
        }
    }
    app.useRouting()
    app.useCors()
    // 健康检查端点
    app.mapGet("/health") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }

    // 元数据内省（供 Ch1/Ch2/Ch3/Ch9 测试使用）
    registerMetaRoutes(app)

    // 按章节注册路由
    registerCh01Routes(app)      // 第一章 P1: 路由模式解析
    registerCh04Routes(app)      // 第四章 P0: DFA 匹配器核心
    registerCh05Routes(app)      // 第五章 P1: 复合段匹配
    registerCh06Routes(app)      // 第六章 P0: HTTP 方法匹配
    registerCh07Routes(app)      // 第七章 P0: 端点选择与歧义处理
    registerCh08Routes(app)      // 第八章 P2: DFA 构建行为
    registerCh10Routes(app)      // 第十章 P1: 约束类边界
    registerCh11Ch12Routes(app)  // 第十一/十二章 P1/P0: 集成 + 对齐
    registerCh13Ch14Routes(app)  // 第十三/十四章 P2: 优化 + OutboundPrecedence
    registerGroupRoutes(app)     // MapGroup: 路由分组功能

    app.run()
    return 0
}
