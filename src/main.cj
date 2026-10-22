package changxi_backend

import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_extensions_injection.*

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    // 注册路由中间件服务
    builder.services.addRouting()

    // 把配置读到强类型对象里。注意这行必须在 build() 之前：
    // build() 之后 builder 就成了"半冻结"状态，再改服务注册不会生效。
    let config = loadAppConfig(builder.configuration)
    printStartupBanner(config)

    // 建数据访问对象。构造 Database 只是把连接池准备好，不会真的连数据库，
    // 所以即使数据库没起来这里也不会炸——真正的探活在下面 ping。
    let services = AppServices(config)

    // 构建主机
    let host = builder.build()
    // 信封中间件必须第一个注册（最先注册 = 最外层），才能兜住里面所有的
    // 异常和"没人处理的 404"。详见 src/api_response.cj 里的说明。
    host.use(apiEnvelopeMiddleware)
    // 启用路由中间件
    host.useRouting()

    // 旧的最小验证接口：故意直接写纯文本，用来验证「端点自己写过 body 时中间件不插手」
    host.mapGet("hello") {
        context => context.response.write("hello cangjie.")
    }
    // 健康检查：前端联调时先打这个，确认服务活着、并且是新的那版代码
    host.mapGet("/api/v1/ping") {
        context => writeApiOk(context.response, JsonNull())
    }
    // 【临时接口，上线前删掉】故意抛异常，方便前端测 500 分支
    host.mapGet("/api/v1/dev/boom") {
        context => throw Exception("故意炸一个")
    }

    // ---- 认证接口 ----
    host.mapPost("/api/v1/auth/send-code") {
        context => handleSendCode(context, services)
    }
    host.mapPost("/api/v1/auth/register") {
        context => handleRegister(context, services)
    }
    host.mapPost("/api/v1/auth/login") {
        context => handleLogin(context, services)
    }
    host.mapPost("/api/v1/auth/logout") {
        context => handleLogout(context, services)
    }
    host.mapPost("/api/v1/account/delete") {
        context => handleDeleteAccount(context, services)
    }

    // ---- 练习接口 ----
    host.mapGet("/api/v1/practice/knowledge-points") {
        context => handleKnowledgePoints(context, services)
    }
    host.mapGet("/api/v1/practice/questions") {
        context => handlePracticeQuestions(context, services)
    }
    host.mapGet("/api/v1/practice/daily") {
        context => handleDailyPractice(context, services)
    }

    // ---- AI 伴学 ----
    host.mapPost("/api/v1/ai/chat") {
        context => handleAiChat(context, services)
    }

    // 数据库探活：在启动横幅之后打一行结论，省得"服务起来了但一调接口就 500"
    // 还要去猜是不是数据库的事。
    probeDatabase(services)

    // 运行主机
    host.run()
    return 0
}

// 启动横幅：把关键配置打出来，避免"配置到底生效没有"靠猜。
// 密钥一律打码，日志可能被贴到 issue 里。
// 用 serverLog 而不是 println：容器里 stdout 有缓冲，println 的内容可能迟迟不出现。
func printStartupBanner(config: AppConfig) {
    serverLog("========================================")
    serverLog("  保育通后端 (changxi-backend)")
    serverLog("  数据库  : ${config.database.serverUrl()}/${config.database.name}  用户 ${config.database.user}")
    serverLog("  JWT     : iss=${config.jwt.issuer} aud=${config.jwt.audience} 有效期 ${config.jwt.expiresHours}h")
    serverLog("  JWT密钥 : ${maskSecret(config.jwt.secret)}")
    serverLog("  验证码  : ${config.smsCodeExpireSeconds} 秒有效")
    // AI 伴学的密钥来自环境变量（不是 appsettings.json，那个文件要提交），
    // 所以"到底读到没有"只能靠开机打一行确认
    logDifyConfig()
    serverLog("========================================")
}

// 探一次数据库，把结果明明白白打出来。失败也不阻止启动：
// 前端此时收到的会是信封化的 500（不是连接被拒），反而更好排查。
func probeDatabase(services: AppServices): Unit {
    try {
        services.database.ping()
        let userCount = services.database.scalarInt64("select count(*) from `user`")
        serverLog("数据库连接正常，user 表当前 ${userCount} 行")
    } catch (e: Exception) {
        serverLog("！！数据库连不上：${e.toString()}")
        serverLog("！！请检查 docker compose 里的 cangjie_Database__* 环境变量、以及 sql/schema.sql 是否执行过")
    }
}
