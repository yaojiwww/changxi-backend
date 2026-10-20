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

// ─── requireCors 三种重载 ─────────────────────────────────────────────────────

func registerRequireCorsRoutes(app: EndpointRouteBuilder): Unit {
    // 重载 1：requireCors() — 无参，使用全局默认策略（allowed.com, anyMethod, anyHeader）
    app.mapGet("/cors/require/default") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors()

    // 重载 2：requireCors(policyName) — 使用命名策略 "creds"（creds.com + credentials）
    app.mapGet("/cors/require/named") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("creds")

    // 重载 3：requireCors(configurePolicy) — 内联策略（https://inline.com）
    app.mapGet("/cors/require/inline") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors { builder =>
        let _ = builder.withOrigins(["https://inline.com"])
                       .allowAnyMethod()
                       .allowAnyHeader()
    }
}

// ─── Origins：来源匹配各场景 ────────────────────────────────────────────────────

func registerOriginRoutes(app: EndpointRouteBuilder): Unit {
    // 单一来源：默认策略（https://allowed.com）
    app.mapGet("/cors/origins/single") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors()

    // 多来源：multi-origin 策略（https://origin1.com, https://origin2.com）
    app.mapGet("/cors/origins/multi") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("multi-origin")

    // 规范化端口：normalized 策略（http://example.com:80 → http://example.com）
    app.mapGet("/cors/origins/normalized") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("normalized")

    // 任意来源：any-origin 策略（*）
    app.mapGet("/cors/origins/any") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("any-origin")

    // 自定义来源判断函数：custom-fn 策略（*.trusted.io）
    app.mapGet("/cors/origins/custom-fn") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("custom-fn")

    // 通配子域名：wildcard-sub 策略（https://*.example.com）
    app.mapGet("/cors/origins/wildcard-sub") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("wildcard-sub")
}

// ─── Headers：请求头匹配 ────────────────────────────────────────────────────────

func registerHeaderRoutes(app: EndpointRouteBuilder): Unit {
    // 特定请求头：specific-hdrs 策略（X-Custom-Header, Content-Type；GET, POST）
    app.mapGet("/cors/headers/specific") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("specific-hdrs")

    // 任意请求头：默认策略（allowAnyHeader — 反射 ACR-Headers）
    app.mapGet("/cors/headers/any") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors()
}

// ─── Methods：请求方法匹配 ──────────────────────────────────────────────────────

func registerMethodRoutes(app: EndpointRouteBuilder): Unit {
    // 特定方法：get-only 策略（仅 GET）
    app.mapGet("/cors/methods/specific") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("get-only")

    // 任意方法：默认策略（allowAnyMethod — 反射 ACR-Method）
    app.mapGet("/cors/methods/any") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors()
}

// ─── Credentials：凭证支持 ──────────────────────────────────────────────────────

func registerCredentialsRoutes(app: EndpointRouteBuilder): Unit {
    // allowCredentials()：creds 策略（ACAC: true）
    app.mapGet("/cors/creds/enabled") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("creds")

    // 默认无凭证（等同 disallowCredentials）：默认策略（无 ACAC 头）
    app.mapGet("/cors/creds/disabled") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors()
}

// ─── MaxAge：预检缓存 ───────────────────────────────────────────────────────────

func registerMaxAgeRoutes(app: EndpointRouteBuilder): Unit {
    // setPreflightMaxAge(600s)：maxage 策略
    app.mapGet("/cors/maxage/set") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("maxage")
}

// ─── ExposedHeaders：暴露响应头 ─────────────────────────────────────────────────

func registerExposeRoutes(app: EndpointRouteBuilder): Unit {
    // withExposedHeaders(["X-Total-Count", "X-Page"])：expose 策略
    app.mapGet("/cors/expose/set") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("expose")
}

// ─── DisableCors / 无策略路由 ────────────────────────────────────────────────────

func registerDisableRoutes(app: EndpointRouteBuilder): Unit {
    // 无 requireCors：CORS 中间件走全局默认策略
    app.mapGet("/cors/disable/no-policy") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }
}

/**
 * 注册所有 CORS 测试路由
 */
public func registerCorsRoutes(app: EndpointRouteBuilder): Unit {
    registerRequireCorsRoutes(app)
    registerOriginRoutes(app)
    registerHeaderRoutes(app)
    registerMethodRoutes(app)
    registerCredentialsRoutes(app)
    registerMaxAgeRoutes(app)
    registerExposeRoutes(app)
    registerDisableRoutes(app)
}

// ─── DisableCors 元数据显式禁用 CORS ──────────────────────────────────────────

/**
 * Gap 1：DisableCors / IDisableCors
 *
 * 通过 withMetadata([DisableCors()]) 为端点挂载 IDisableCors 元数据。
 * CorsMiddleware 检测到该元数据后：
 *   - 若是 CORS 预检（OPTIONS + Origin + ACR-Method）→ 直接返回 204，不附加任何 CORS 头
 *   - 普通请求 + Origin                             → 传递给 next，不附加 CORS 头
 */
public func registerDisableCorsRoutes(app: EndpointRouteBuilder): Unit {
    // 禁用端点：即使请求携带 Origin，也不附加任何 CORS 响应头
    app.mapGet("/cors/disabled/endpoint") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.withMetadata([DisableCors()])
}

// ─── 非法策略（allowAnyOrigin + credentials）防御性验证 ─────────────────────

/**
 * Gap 2：allowAnyOrigin + allowCredentials 非法组合
 *
 * 使用在 main.cj 中通过 addPolicy(name, policy) 直接注册的非法策略 "any-origin-creds"。
 * 该策略绕过了 CorsPolicyBuilder.build() 的校验，直接存入 policyMap。
 * 当请求携带 Origin 时，CorsService.evaluatePolicy() 在请求阶段执行防御检查并抛出
 * IllegalArgumentException，由错误处理中间件捕获后以 500 响应体返回。
 */
public func registerIllegalPolicyRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/cors/error/any-origin-creds") { ctx =>
        ctx.response.statusCode = 200
        ctx.response.write("ok")
    }.requireCors("any-origin-creds")
}
