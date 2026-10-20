/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_staticfiles.*
import soulsoft_web_staticfiles.fileProviders.*
import soulsoft_extensions_injection.*

private const DefaultPortBase: Int64 = 15140

func resolvePortBase(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    return builder.configuration.getValue<Int64>("portBase") ?? DefaultPortBase
}

func filterPortArgs(args: Array<String>): Array<String> {
    let filtered = ArrayList<String>()
    var index = 0
    while (index < args.size) {
        let current = args[index]
        if (current == "--portBase" || current == "--HTTP_PORTS" || current == "--urls") {
            index += if (index + 1 < args.size) { 2 } else { 1 }
            continue
        }
        filtered.add(current)
        index++
    }
    return filtered.toArray()
}

func createPortBoundBuilder(args: Array<String>, port: Int64): WebHostBuilder {
    let builder = WebHost.createBuilder(filterPortArgs(args))
    builder.configuration["HTTP_PORTS"] = port.toString()
    return builder
}

// ─── 公共构建块 ──────────────────────────────────────────────────────────────

func addErrorHandler(app: WebHost): Unit {
    app.use {
        context, next => try {
            next(context)
        } catch (e: Exception) {
            context.response.statusCode = 500
            context.response.contentType = "text/plain; charset=utf-8"
            context.response.write(e.toString())
        }
    }
}

func addFallbacks(app: WebHost): Unit {
    app.use {
        context, _ =>
            if (context.request.path.value == "/health") {
                context.response.statusCode = 200
                context.response.write("ok")
            } else {
                context.response.statusCode = 404
            }
    }
}

// ─── Server 5001：useStaticFiles，无 requestPath ────────────────────────────
//
// 场景：根路径静态服务，GET/HEAD 文件，条件请求，Range 请求，响应头验证
// 未知类型文件（.xyz）默认不提供 → 404

func runRootServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)
    let app = builder.build()
    addErrorHandler(app)

    app.useStaticFiles {
        options =>
            options.fileProvider = PhysicalFileProvider("wwwroot")
    }

    addFallbacks(app)
    app.run()
}

// ─── Server 5002：useStaticFiles，requestPath = "/s" ────────────────────────
//
// 场景：带前缀的静态服务；serveUnknownFileTypes = true，验证未知类型也可提供
// 测试以 /s/... 发起的请求与以 /other/... 发起时的 404 行为

func runPrefixServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)
    let app = builder.build()
    addErrorHandler(app)

    app.useStaticFiles {
        options =>
            options.requestPath = PathString("/s")
            options.fileProvider = PhysicalFileProvider("wwwroot")
            options.serveUnknownFileTypes = true
    }

    addFallbacks(app)
    app.run()
}

// ─── Server 5003：useDefaultFiles + useStaticFiles，无 requestPath ───────────
//
// 场景：默认文件中间件 + 静态文件中间件
// GET /sub  → 301 重定向到 /sub/
// GET /sub/ → 路径重写为 /sub/index.html → 200
// GET /hello.txt → 200 直接提供

func runDefaultFilesServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)
    let app = builder.build()
    addErrorHandler(app)

    app.useDefaultFiles {
        options =>
            options.fileProvider = PhysicalFileProvider("wwwroot")
    }

    app.useStaticFiles {
        options =>
            options.fileProvider = PhysicalFileProvider("wwwroot")
    }

    addFallbacks(app)
    app.run()
}

// ─── Server 5004：useDefaultFiles + useStaticFiles，fileProvider 指向 approot ──
//
// 场景：根目录本身含默认文件（index.html）+ 多层目录结构
// approot 文件树：
//   index.html        根默认文件
//   about.html        普通页面
//   assets/style.css  子目录文件
// GET /            → 路径重写为 /index.html → 200
// GET /index.html  → 200 直接提供
// GET /about.html  → 200 直接提供
// GET /assets/style.css → 200

func runAppRootServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)
    let app = builder.build()
    addErrorHandler(app)

    app.useDefaultFiles {
        options =>
            options.fileProvider = PhysicalFileProvider("approot")
    }

    app.useStaticFiles {
        options =>
            options.fileProvider = PhysicalFileProvider("approot")
    }

    addFallbacks(app)
    app.run()
}

// ─── 入口 ────────────────────────────────────────────────────────────────────

main(args: Array<String>): Int64 {
    let portBase = resolvePortBase(args)
    let serviceArgs = filterPortArgs(args)
    let f1 = spawn { runRootServer(serviceArgs, portBase + 0) }
    let f2 = spawn { runPrefixServer(serviceArgs, portBase + 1) }
    let f3 = spawn { runDefaultFilesServer(serviceArgs, portBase + 2) }
    let f4 = spawn { runAppRootServer(serviceArgs, portBase + 3) }
    f1.get()
    f2.get()
    f3.get()
    f4.get()
    return 0
}
