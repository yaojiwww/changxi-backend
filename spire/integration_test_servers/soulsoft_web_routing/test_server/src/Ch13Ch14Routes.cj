/**
 * 第十三章：IParameterLiteralNodeMatchingPolicy 约束优化 [P2]
 * 第十四章：OutboundPrecedence（URL 生成优先级）[P2]
 * 覆盖测试用例：TC261-264
 *
 * 说明：
 *   - TC261-262 通过 DFA 匹配行为间接验证约束优化
 *   - TC263-264 通过 /meta/parse 的 outbound 字段验证，无需单独注册路由
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 13. IParameterLiteralNodeMatchingPolicy 行为验证 (TC261-262)
 * int 约束与字面量节点共存时的匹配优先级
 */
func registerCh13OptimizationRoutes(app: EndpointRouteBuilder): Unit {
    // TC261: 字面量 /123 优先于约束参数 /{id:int}
    app.mapGet("/ch13/literal/123") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal_123\"}")
    }
    app.mapGet("/ch13/int/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"int_constrained\""),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC262: 普通参数路由，int 约束排除字母输入
    app.mapGet("/ch13/str/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 14. OutboundPrecedence 路由占位 (TC263-264)
 * outbound 优先级通过 /meta/parse?pattern=... 的 outbound 字段验证
 */
func registerCh14OutboundRoutes(app: EndpointRouteBuilder): Unit {
    // 占位路由，实际验证通过 /meta/parse 进行
    app.mapGet("/ch14/placeholder") { ctx => writeMatched(ctx) }
}

/**
 * 注册第十三、十四章所有路由
 */
public func registerCh13Ch14Routes(app: EndpointRouteBuilder): Unit {
    registerCh13OptimizationRoutes(app)
    registerCh14OutboundRoutes(app)
}
