/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */


package test_server

import soulsoft_web_http.*
import soulsoft_web_cors.*
import soulsoft_web_cors.abstractions.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_extensions_injection.*

private const DefaultPortBase: Int64 = 15080

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultPortBase)
    builder.services.addRouting()
    builder.services.addCors { options =>
        // 默认策略：允许 https://allowed.com，任意方法，任意请求头
        options.addDefaultPolicy { policy =>
            let _ = policy.withOrigins(["https://allowed.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
        }

        // credentials：允许携带凭证
        options.addPolicy("creds") { policy =>
            let _ = policy.withOrigins(["https://creds.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
                          .allowCredentials()
        }

        // specific-hdrs：限制请求头和方法
        options.addPolicy("specific-hdrs") { policy =>
            let _ = policy.withOrigins(["https://allowed.com"])
                          .withHeaders(["X-Custom-Header", "Content-Type"])
                          .withMethods(["GET", "POST"])
        }

        // expose：暴露响应头
        options.addPolicy("expose") { policy =>
            let _ = policy.withOrigins(["https://allowed.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
                          .withExposedHeaders(["X-Total-Count", "X-Page"])
        }

        // maxage：设置预检缓存时长
        options.addPolicy("maxage") { policy =>
            let _ = policy.withOrigins(["https://allowed.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
                          .setPreflightMaxAge(Duration.second * 600)
        }

        // any-origin：允许任意来源（不可与 credentials 同时使用）
        options.addPolicy("any-origin") { policy =>
            let _ = policy.allowAnyOrigin()
                          .allowAnyMethod()
                          .allowAnyHeader()
        }

        // get-only：只允许 GET 方法
        options.addPolicy("get-only") { policy =>
            let _ = policy.withOrigins(["https://allowed.com"])
                          .withMethods(["GET"])
                          .allowAnyHeader()
        }

        // wildcard-sub：允许 *.example.com 子域名
        options.addPolicy("wildcard-sub") { policy =>
            let _ = policy.withOrigins(["https://*.example.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
                          .setIsOriginAllowedToAllowWildcardSubdomains()
        }

        // inline：由 requireCors(configurePolicy) 直接内联，此处占位确保 "inline" key 不存在
        // （inline 策略通过 requireCors { builder => ... } 注册在端点元数据中）

        // multi-origin：允许多个来源
        options.addPolicy("multi-origin") { policy =>
            let _ = policy.withOrigins(["https://origin1.com", "https://origin2.com"])
                          .allowAnyMethod()
                          .allowAnyHeader()
        }

        // normalized：验证端口规范化（http:80 → http, https:443 → https）
        options.addPolicy("normalized") { policy =>
            let _ = policy.withOrigins(["http://example.com:80", "https://secure.com:443"])
                          .allowAnyMethod()
                          .allowAnyHeader()
        }

        // custom-fn：使用 setIsOriginAllowed 自定义来源判断函数（*.trusted.io）
        options.addPolicy("custom-fn") { policy =>
            let _ = policy.setIsOriginAllowed { origin => origin.endsWith(".trusted.io") }
                          .allowAnyMethod()
                          .allowAnyHeader()
        }

        // any-origin-creds：故意绕过 CorsPolicyBuilder.build() 的校验，
        // 直接注册 allowAnyOrigin + supportsCredentials 的非法组合策略，
        // 用于验证 CorsService.evaluatePolicy() 在请求阶段的防御性检查。
        let illegalPolicy = CorsPolicy()
        illegalPolicy.origins.add("*")  // 设置 allowAnyOrigin = true
        illegalPolicy.supportsCredentials = true
        options.addPolicy("any-origin-creds", illegalPolicy)
    }

    let app = builder.build()

    // 错误处理中间件：服务端异常以纯文本写入 500 响应体
    app.use { context, next =>
        try {
            next(context)
        } catch (e: Exception) {
            context.response.statusCode = 500
            context.response.contentType = "text/plain; charset=utf-8"
            context.response.write(e.toString())
        }
    }

    app.useRouting()
    app.useCors()

    // 健康检查
    app.mapGet("/health") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }

    registerCorsRoutes(app)
    registerDisableCorsRoutes(app)
    registerIllegalPolicyRoutes(app)

    app.run()
    return 0
}
