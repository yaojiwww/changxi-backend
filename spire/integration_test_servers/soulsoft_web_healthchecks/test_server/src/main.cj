/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * HealthChecks Test Server
 *
 * 默认服务地址：http://0.0.0.0:15090
 *
 * 注册的健康检查：
 *   "healthy"   - tags: []           - 始终返回 Healthy
 *   "unhealthy" - tags: ["critical"] - 始终返回 Unhealthy
 *   "degraded"  - tags: ["slow"]     - 始终返回 Degraded
 *
 * 端点（useHealthChecks 中间件）：
 *   /healthz                  - 全部检查 → 聚合 Unhealthy → 503
 *   /healthz/only-healthy     - 仅 "healthy"   → 200
 *   /healthz/only-unhealthy   - 仅 "unhealthy" → 503
 *   /healthz/only-degraded    - 仅 "degraded"  → 200
 *   /healthz/cache            - allowCachingResponses=true, 仅 "healthy" → 200
 *   /healthz/tag/critical     - 按 tag "critical" 过滤 → 503
 *   /healthz/tag/slow         - 按 tag "slow" 过滤    → 200 Degraded
 *
 * 端点（mapHealthChecks 端点路由）：
 *   /map/healthz              - 全部检查 → 503
 *   /map/healthz/only-healthy - 仅 "healthy" → 200
 */
package test_server

import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_healthchecks.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_healthchecks.*

private const DefaultPortBase: Int64 = 15090

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultPortBase)
    builder.services.addRouting()

    // 注册三个具有不同状态和 tag 的健康检查
    builder.services.addHealthChecks()
        .addCheck("healthy", []) {
            HealthCheckResult.healthy(description: Some("all systems operational"))
        }
        .addCheck("unhealthy", ["critical"]) {
            HealthCheckResult.unhealthy(description: Some("service unavailable"))
        }
        .addCheck("degraded", ["slow"]) {
            HealthCheckResult.degraded(description: Some("slow response time"))
        }

    let app = builder.build()

    // 错误处理：将服务端异常以纯文本写入 500 响应，供 Python 测试客户端可见
    app.use { context, next =>
        try {
            next(context)
        } catch (e: Exception) {
            context.response.statusCode = 500
            context.response.contentType = "text/plain; charset=utf-8"
            context.response.write(e.toString())
        }
    }

    // ── useHealthChecks 端点 ──────────────────────────────────────────

    // 全部检查：聚合状态 Unhealthy → 503
    app.useHealthChecks("/healthz")

    // 名称过滤
    app.useHealthChecks("/healthz/only-healthy") { opts =>
        opts.predicate = { reg => reg.name == "healthy" }
    }
    app.useHealthChecks("/healthz/only-unhealthy") { opts =>
        opts.predicate = { reg => reg.name == "unhealthy" }
    }
    app.useHealthChecks("/healthz/only-degraded") { opts =>
        opts.predicate = { reg => reg.name == "degraded" }
    }

    // allowCachingResponses=true：不注入防缓存响应头
    app.useHealthChecks("/healthz/cache") { opts =>
        opts.predicate = { reg => reg.name == "healthy" }
        opts.allowCachingResponses = true
    }

    // Tag 过滤：按 tags 数组筛选
    app.useHealthChecks("/healthz/tag/critical") { opts =>
        opts.predicate = { reg =>
            var matched = false
            for (t in reg.tags) {
                if (t == "critical") { matched = true }
            }
            matched
        }
    }
    app.useHealthChecks("/healthz/tag/slow") { opts =>
        opts.predicate = { reg =>
            var matched = false
            for (t in reg.tags) {
                if (t == "slow") { matched = true }
            }
            matched
        }
    }

    // ── mapHealthChecks 端点路由 ───────────────────────────────────────

    app.useRouting()

    app.mapHealthChecks("/map/healthz")
    app.mapHealthChecks("/map/healthz/only-healthy") { opts =>
        opts.predicate = { reg => reg.name == "healthy" }
    }

    app.run()
    return 0
}
