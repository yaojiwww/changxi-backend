/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.env.*
import std.sync.*
import soulsoft_web_hosting.*
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_extensions_configuration.*
import soulsoft_extensions_hosting.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_logging_console.*
import soulsoft_extensions_logging_configuration.*
import soulsoft_extensions_options.*
import soulsoft_extensions_options_configuration.*

// ─────────────────────────────────────────────────────────────
// 简易测试输出工具
// ─────────────────────────────────────────────────────────────

var passed = 0
var failed = 0

private const StartupEnvSourceName = "CANGJIE_X_SOURCE"
private const StartupEnvEnvironmentName = "CANGJIE_ENVIRONMENT"
private const StartupEnvSourceValue = "env_val"
private const StartupEnvEnvironmentValue = "Staging"

func ok(name: String, cond: Bool): Unit {
    if (cond) {
        println("  ✅ PASS  ${name}")
        passed++
    } else {
        println("  ❌ FAIL  ${name}")
        failed++
    }
}

func section(title: String): Unit {
    println("\n┌─────────────────────────────────────────────────")
    println("│ ${title}")
    println("└─────────────────────────────────────────────────")
}

func restoreVariable(name: String, value: ?String): Unit {
    match (value) {
        case Some(v) => setVariable(name, v)
        case None => removeVariable(name)
    }
}

public interface IStartupCheck {
    prop title: String
    func run(): Unit
}

class IntegrationTestAppOptions {
    public var name: String = ""
    public var mode: String = ""
}

class IntegrationTestConfigurationOptions {
    public var x_source: String = ""
    public var x_version: String = ""
    public var x_shared: String = ""
    public var x_dev_only: String = ""
    public var app = IntegrationTestAppOptions()
    public var loggingDefault: String = ""
    public var loggingSoulsoft: String = ""
    public var loggingMicrosoft: String = ""
    public var loggingConsoleDefault: String = ""
}

class NoopServer <: IServer {
    public func start(pipeline: RequestDelegate): Unit {
        let _ = pipeline
    }

    public func stop(): Unit {}
}

func buildStartupValidationHost(
    args: Array<String>,
    configure: (WebHostBuilder) -> Unit
): WebHost {
    let builder = WebHost.createBuilder(args)
    builder.services.addSingleton<IHostLifetime>(NoopHostLifetime())
    builder.services.addSingleton<IServer>(NoopServer())
    configure(builder)
    return builder.build()
}

func startupOptionsPass(
    name: String,
    args: Array<String>,
    failureMessage: String,
    validation: (IntegrationTestConfigurationOptions) -> Bool
): Unit {
    let host = buildStartupValidationHost(args, { builder =>
        let _ = builder.services.addOptionsWithValidateOnStart<IntegrationTestConfigurationOptions>()
            .configure { options, services =>
                let configuration = services.getOrThrow<IConfiguration>()
                options.x_source = configuration["x_source"] ?? String.empty
                options.x_version = configuration["x_version"] ?? String.empty
                options.x_shared = configuration["x_shared"] ?? String.empty
                options.x_dev_only = configuration["x_dev_only"] ?? String.empty
                options.app.name = configuration["app:name"] ?? String.empty
                options.app.mode = configuration["app:mode"] ?? String.empty
                options.loggingDefault = configuration["logging:logLevel:default"] ?? String.empty
                options.loggingSoulsoft = configuration["logging:logLevel:soulsoft"] ?? String.empty
                options.loggingMicrosoft = configuration["logging:logLevel:Microsoft"] ?? String.empty
                options.loggingConsoleDefault = configuration["logging:console:logLevel:default"] ?? String.empty
            }
            .validate(failureMessage, validation)
    })
    var started = false
    try {
        host.start()
        started = true
        ok(name, true)
    } catch (_: Exception) {
        ok(name, false)
    } finally {
        if (started) {
            host.stop()
        }
        host.close()
    }
}

class DefaultEnvironmentCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "1. 默认环境"
        }
    }

    public func run(): Unit {
        let host = buildHost([])
        ok("无参数时环境名为 Production",
            host.environment.environmentName == Environments.Production)
        ok("isProduction() == true",
            host.environment.isProduction())
        ok("isDevelopment() == false",
            !host.environment.isDevelopment())
        ok("isStaging() == false",
            !host.environment.isStaging())
        host.close()
    }
}

class CommandLineEnvironmentCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "2. 命令行参数覆盖环境名"
        }
    }

    public func run(): Unit {
        let developmentHost = buildHost(["--environment", "Development"])
        ok("--environment Development → isDevelopment()",
            developmentHost.environment.isDevelopment())
        ok("--environment Development → environmentName == \"Development\"",
            developmentHost.environment.environmentName == Environments.Development)
        developmentHost.close()

        let stagingHost = buildHost(["--environment", "Staging"])
        ok("--environment Staging → isStaging()",
            stagingHost.environment.isStaging())
        stagingHost.close()

        let customHost = buildHost(["--environment", "Custom"])
        ok("--environment Custom → isEnvironment(\"Custom\")",
            customHost.environment.isEnvironment("Custom"))
        ok("--environment Custom → !isProduction()",
            !customHost.environment.isProduction())
        customHost.close()
    }
}

class BaseConfigurationCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "3. appsettings.json 基础配置加载（Production 环境）"
        }
    }

    public func run(): Unit {
        startupOptionsPass("x_source == \"json_base\"",
            [], "x_source must come from appsettings.json") {
            options => options.x_source == "json_base"
        }
        startupOptionsPass("x_version == \"1.0\"",
            [], "x_version must come from appsettings.json") {
            options => options.x_version == "1.0"
        }
        startupOptionsPass("x_shared == \"from_base\"",
            [], "x_shared must come from appsettings.json") {
            options => options.x_shared == "from_base"
        }
        startupOptionsPass("x_dev_only 不存在（Production 不加载 Development 文件）",
            [], "x_dev_only should stay at default value in Production") {
            options => options.x_dev_only.isEmpty()
        }
        startupOptionsPass("app:name == \"integration-test\"",
            [], "app.name must bind from base configuration") {
            options => options.app.name == "integration-test"
        }
        startupOptionsPass("app:mode == \"base\"",
            [], "app.mode must stay at base value in Production") {
            options => options.app.mode == "base"
        }
    }
}

class DevelopmentConfigurationOverrideCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "4. appsettings.Development.json 覆盖 appsettings.json"
        }
    }

    public func run(): Unit {
        startupOptionsPass("x_source 被 Development 文件覆盖为 \"json_dev\"",
            ["--environment", "Development"], "x_source must be overridden by Development json") {
            options => options.x_source == "json_dev"
        }
        startupOptionsPass("x_shared 来自 base 文件（Development 文件未覆盖）",
            ["--environment", "Development"], "x_shared must stay inherited from base json") {
            options => options.x_shared == "from_base"
        }
        startupOptionsPass("x_version 来自 base 文件（Development 文件未覆盖）",
            ["--environment", "Development"], "x_version must stay inherited from base json") {
            options => options.x_version == "1.0"
        }
        startupOptionsPass("x_dev_only 来自 Development 文件",
            ["--environment", "Development"], "x_dev_only must bind from Development json") {
            options => options.x_dev_only == "dev_value"
        }
        startupOptionsPass("app:mode 被 Development 文件覆盖为 \"development\"",
            ["--environment", "Development"], "app.mode must be overridden by Development json") {
            options => options.app.mode == "development"
        }
        startupOptionsPass("app:name 来自 base 文件（Development 文件未覆盖）",
            ["--environment", "Development"], "app.name must stay inherited from base json") {
            options => options.app.name == "integration-test"
        }
    }
}

class CommandLinePriorityCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "5. 命令行参数优先级（高于配置文件）"
        }
    }

    public func run(): Unit {
        startupOptionsPass("命令行 --x_source 覆盖 appsettings.json（Production）",
            ["--x_source", "cmdline_val"], "command line must override base json") {
            options => options.x_source == "cmdline_val"
        }
        startupOptionsPass("命令行 --x_source 覆盖 appsettings.Development.json",
            ["--environment", "Development", "--x_source", "cmdline_val"],
            "command line must override Development json") {
            options => options.x_source == "cmdline_val"
        }
        startupOptionsPass("命令行未覆盖的 x_dev_only 仍从 Development 文件读取",
            ["--environment", "Development", "--x_source", "cmdline_val"],
            "x_dev_only must still bind from Development json when cmdline only overrides x_source") {
            options => options.x_dev_only == "dev_value"
        }
        startupOptionsPass("无命令行覆盖时，x_source 仍为 Development 文件的值",
            ["--environment", "Development"], "x_source must stay on Development json value without cmdline override") {
            options => options.x_source == "json_dev"
        }
    }
}

class EnvironmentVariablePriorityCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "6. 环境变量优先级（cangjie_ 前缀）"
        }
    }

    public func run(): Unit {
        let originalSource = getVariable(StartupEnvSourceName)
        let originalEnvironment = getVariable(StartupEnvEnvironmentName)

        try {
            setVariable(StartupEnvSourceName, StartupEnvSourceValue)
            setVariable(StartupEnvEnvironmentName, StartupEnvEnvironmentValue)

            println("  📌 ${StartupEnvSourceName}    = ${getVariable(StartupEnvSourceName)}")
            println("  📌 ${StartupEnvEnvironmentName} = ${getVariable(StartupEnvEnvironmentName)}")

            startupOptionsPass("CANGJIE_X_SOURCE 覆盖 appsettings.json（Production）",
                [], "CANGJIE_X_SOURCE must override base json") {
                options => options.x_source == StartupEnvSourceValue
            }

            startupOptionsPass("命令行 --x_source 覆盖 CANGJIE_X_SOURCE 环境变量",
                ["--x_source", "cmdline_beats_env"],
                "command line must still override CANGJIE_X_SOURCE") {
                options => options.x_source == "cmdline_beats_env"
            }

            let environmentHost = buildHost([])
            ok("CANGJIE_ENVIRONMENT 覆盖默认环境名 Production",
                environmentHost.environment.environmentName == StartupEnvEnvironmentValue)
            environmentHost.close()

            let environmentOverrideHost = buildHost(["--environment", "Production"])
            ok("命令行 --environment Production 覆盖 CANGJIE_ENVIRONMENT",
                environmentOverrideHost.environment.isProduction())
            environmentOverrideHost.close()
        } finally {
            restoreVariable(StartupEnvSourceName, originalSource)
            restoreVariable(StartupEnvEnvironmentName, originalEnvironment)
        }
    }
}

class LoggingBaseConfigurationCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "7. logging 配置读取（来自 appsettings.json）"
        }
    }

    public func run(): Unit {
        startupOptionsPass("logging:logLevel:default == \"Info\"",
            [], "logging.logLevel.default must come from appsettings.json") {
            options => options.loggingDefault == "Info"
        }
        startupOptionsPass("logging:logLevel:soulsoft == \"Warn\"",
            [], "logging.logLevel.soulsoft must come from appsettings.json") {
            options => options.loggingSoulsoft == "Warn"
        }
        startupOptionsPass("logging:logLevel:Microsoft == \"Error\"",
            [], "logging.logLevel.Microsoft must come from appsettings.json") {
            options => options.loggingMicrosoft == "Error"
        }
        startupOptionsPass("logging:console:logLevel:default == \"Info\"",
            [], "logging.console.logLevel.default must come from appsettings.json") {
            options => options.loggingConsoleDefault == "Info"
        }
    }
}

class LoggingDevelopmentOverrideCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "8. logging 配置读取（Development 文件覆盖）"
        }
    }

    public func run(): Unit {
        startupOptionsPass("Development 环境：logging:logLevel:default == \"Debug\"",
            ["--environment", "Development"], "Development logging default must be Debug") {
            options => options.loggingDefault == "Debug"
        }
        startupOptionsPass("Development 环境：logging:logLevel:soulsoft == \"Debug\"（比 base 更详细）",
            ["--environment", "Development"], "Development logging soulsoft must be Debug") {
            options => options.loggingSoulsoft == "Debug"
        }
        startupOptionsPass("Development 环境：logging:logLevel:Microsoft == \"Warn\"（比 base 更宽松）",
            ["--environment", "Development"], "Development logging Microsoft must be Warn") {
            options => options.loggingMicrosoft == "Warn"
        }
        startupOptionsPass("Development 环境：logging:console:logLevel:default == \"Debug\"",
            ["--environment", "Development"], "Development console logging default must be Debug") {
            options => options.loggingConsoleDefault == "Debug"
        }
    }
}

class LoggingCommandLineOverrideCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "9. logging 配置命令行覆盖"
        }
    }

    public func run(): Unit {
        startupOptionsPass("命令行覆盖 logging:logLevel:default 为 \"Warn\"",
            ["--logging:logLevel:default", "Warn"],
            "command line must override logging.logLevel.default") {
            options => options.loggingDefault == "Warn"
        }
        startupOptionsPass("命令行未覆盖的 logging:logLevel:Microsoft 仍为 \"Error\"",
            ["--logging:logLevel:default", "Warn"],
            "logging.logLevel.Microsoft must remain at base value when not overridden") {
            options => options.loggingMicrosoft == "Error"
        }
    }
}

class PrecedenceSummaryCheck <: IStartupCheck {
    public prop title: String {
        get() {
            "10. 优先级顺序总结（低 → 高）"
        }
    }

    public func run(): Unit {
        println("  appsettings.json                （最低）")
        println("       ↓ 被覆盖")
        println("  appsettings.{Environment}.json")
        println("       ↓ 被覆盖")
        println("  环境变量（cangjie_ 前缀）")
        println("       ↓ 被覆盖")
        println("  命令行参数                       （最高）")
    }
}

func runStartupChecks(checks: Array<IStartupCheck>): Unit {
    for (check in checks) {
        section(check.title)
        check.run()
    }
}

// ─────────────────────────────────────────────────────────────
// 创建测试用 WebHost（NoopHostLifetime 避免阻塞）
// ─────────────────────────────────────────────────────────────

func buildHost(args: Array<String>): WebHost {
    let builder = WebHost.createBuilder(args)
    builder.services.addSingleton<IHostLifetime>(NoopHostLifetime())
    return builder.build()
}

// ─────────────────────────────────────────────────────────────
// HTTP 集成测试服务器（默认端口 15100）
// 配置测试跑完后启动，供 Python pytest 使用
// ─────────────────────────────────────────────────────────────

private const DefaultHttpServerPort: Int64 = 15100

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

// OnCompleted 测试：跨请求可观测计数器
var completedCount = AtomicInt64(0)

func startHttpServer(args: Array<String>): Unit {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultHttpServerPort)
    builder.services.addRouting()
    let app = builder.build()

    // 健康检查（conftest _wait 探活）
    app.mapGet("health") {
        context => context.response.write("ok")
    }

    // 基本文本响应（无显式 Content-Type）
    app.mapGet("text") {
        context => context.response.write("hello world")
    }

    // JSON 响应
    app.mapGet("json") {
        context =>
            context.response.contentType = "application/json; charset=utf-8"
            context.response.write("{\"key\":\"value\"}")
    }

    // 自定义状态码 — 201 无 body
    app.mapGet("status/201") {
        context => context.response.statusCode = 201
    }

    // 204/304 属于无 body 响应，不能携带 Transfer-Encoding。
    app.mapGet("status/204") {
        context => context.response.statusCode = 204
    }

    app.mapGet("status/205") {
        context => context.response.statusCode = 205
    }

    app.mapGet("status/304") {
        context => context.response.statusCode = 304
    }

    // 模拟上游错误设置 transfer-encoding，宿主层应在 OnStarting 里清理掉。
    app.mapGet("status/204-manual-chunked") {
        context =>
            context.response.statusCode = 204
            context.response.headers.transferEncoding = ["chunked"]
    }

    app.mapGet("status/205-manual-chunked") {
        context =>
            context.response.statusCode = 205
            context.response.headers.transferEncoding = ["chunked"]
    }

    app.mapGet("status/304-manual-chunked") {
        context =>
            context.response.statusCode = 304
            context.response.headers.transferEncoding = ["chunked"]
    }

    // 204/304 下写 body 应被宿主层拦截，避免继续生成非法响应。
    app.mapGet("status/204-write-body") {
        context =>
            context.response.statusCode = 204
            context.response.write("should-fail")
    }

    app.mapGet("status/205-write-body") {
        context =>
            context.response.statusCode = 205
            context.response.write("should-fail")
    }

    app.mapGet("status/304-write-body") {
        context =>
            context.response.statusCode = 304
            context.response.write("should-fail")
    }

    // 自定义状态码 — 404
    app.mapGet("status/404") {
        context =>
            context.response.statusCode = 404
            context.response.write("not found")
    }

    // 多次 write → Transfer-Encoding: chunked
    app.mapGet("chunked") {
        context =>
            context.response.write("part1")
            context.response.write("part2")
            context.response.write("part3")
    }

    // 显式 Content-Length（框架不追加 chunked）
    app.mapGet("content-len") {
        context =>
            context.response.contentLength = 5
            context.response.write("hello")
    }

    // OnStarting 回调：headers 发送前注入自定义 header
    app.mapGet("on-starting") {
        context =>
            context.response.onStarting {
                context.response.headers.add("x-custom", "from-callback")
            }
            context.response.write("ok")
    }

    // OnCompleted 触发：响应完毕后递增计数器
    app.mapGet("on-completed/trigger") {
        context =>
            context.response.onCompleted {
                completedCount.fetchAdd(1)
            }
            context.response.write("ok")
    }

    // OnCompleted 查询：返回当前计数值
    app.mapGet("on-completed/count") {
        context => context.response.write(completedCount.load().toString())
    }

    // 异常前注册 OnStarting；500 响应仍应带上回调注入的 header
    app.mapGet("error/on-starting-header") {
        context =>
            context.response.onStarting {
                context.response.headers.add("x-error-callback", "applied")
            }
            throw Exception("deliberate test error with on-starting header")
    }

    // 异常前写入 cookie；500 响应仍应保留已设置的 Set-Cookie
    app.mapGet("error/cookie-before-start") {
        context =>
            context.response.cookies.append("failure", "1")
            throw Exception("deliberate test error with cookie")
    }

    // 异常前预设 framing 相关 header；500 兜底响应应清理旧值并保留合法 transfer-encoding
    app.mapGet("error/framing-headers") {
        context =>
            context.response.contentLength = 123
            context.response.headers.transferEncoding = ["chunked"]
            context.response.headers.add("Trailer", "x-error-trailer")
            throw Exception("deliberate test error with framing headers")
    }

    // 未处理异常 → hasStarted=false → 框架返回 500
    app.mapGet("error") {
        _context => throw Exception("deliberate test error")
    }

    // 先写部分 body 再抛异常 → hasStarted=true → 框架不覆盖响应
    app.mapGet("error-started") {
        context =>
            context.response.write("partial")
            throw Exception("error after partial write")
    }

    // 响应开始后再改状态码应抛错，框架保留已写出的响应
    app.mapGet("started/status-mutation") {
        context =>
            context.response.write("partial")
            context.response.statusCode = 418
    }

    // 响应开始后再改 header 应抛错，框架保留已写出的响应
    app.mapGet("started/header-mutation") {
        context =>
            context.response.write("partial")
            context.response.headers.add("x-too-late", "nope")
    }

    // 302 重定向至 /text
    app.mapGet("redirect") {
        context => context.response.redirect("/text")
    }

    // Server-Sent Events（3 个事件后关闭连接）
    app.mapGet("sse") {
        context =>
            context.response.contentType = "text/event-stream"
            context.response.headers.add("cache-control", "no-cache")
            context.response.write("data: event1\n\n")
            context.response.write("data: event2\n\n")
            context.response.write("data: event3\n\n")
    }

    app.run()
}

// ─────────────────────────────────────────────────────────────
// main
//
// 项目目录下已有两个固定配置文件：
//   appsettings.json              → x_source="json_base", x_version="1.0",
//                                   x_shared="from_base", app.name/mode
//   appsettings.Development.json  → x_source="json_dev",  x_dev_only="dev_value",
//                                   app.mode="development"
// ─────────────────────────────────────────────────────────────

main(args: Array<String>): Int64 {
    println("╔══════════════════════════════════════════════════════")
    println("║  soulsoft_web_hosting  配置加载优先级集成测试")
    println("╚══════════════════════════════════════════════════════")
    println("  工作目录：${getWorkingDirectory()}")
    println("  固定配置：appsettings.json + appsettings.Development.json")

    let originalSource = getVariable(StartupEnvSourceName)
    let originalEnvironment = getVariable(StartupEnvEnvironmentName)

    try {
        removeVariable(StartupEnvSourceName)
        removeVariable(StartupEnvEnvironmentName)

        let checks: Array<IStartupCheck> = [
            DefaultEnvironmentCheck(),
            CommandLineEnvironmentCheck(),
            BaseConfigurationCheck(),
            DevelopmentConfigurationOverrideCheck(),
            CommandLinePriorityCheck(),
            EnvironmentVariablePriorityCheck(),
            LoggingBaseConfigurationCheck(),
            LoggingDevelopmentOverrideCheck(),
            LoggingCommandLineOverrideCheck(),
            PrecedenceSummaryCheck()
        ]
        runStartupChecks(checks)
    } finally {
        restoreVariable(StartupEnvSourceName, originalSource)
        restoreVariable(StartupEnvEnvironmentName, originalEnvironment)
    }

    // ──────────────────────────────────────────────
    // 汇总
    // ──────────────────────────────────────────────
    println("\n══════════════════════════════════════════════════════")
    println("  配置测试：${passed} PASSED  /  ${failed} FAILED")
    println("══════════════════════════════════════════════════════")

    // 配置测试完成后启动 HTTP 集成测试服务器（阻塞，直到进程终止）
    println("\n── HTTP 响应集成测试服务器 :15100（默认） ───────────────")
    println("  运行 Python 测试：cd tests && python -m pytest -v")
    println("  停止服务器：Ctrl+C")
    startHttpServer(args)

    return if (failed == 0) { 0 } else { 1 }
}
