/**
 * 第八章：DFA 构建行为 DfaMatcherBuilder [P2]
 * 覆盖测试用例：TC188-195
 *
 * 说明：DFA 内部结构（节点共享、自循环）无法直接通过 HTTP 检查，
 * 通过行为验证：注册多个路由后所有路径均能正确响应，
 * 间接验证 DFA 构建正确性。
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 8.1 字面量前缀共享 (TC188-190)
 * 共享 /ch08/api 节点，然后分叉为不同子路径
 */
func registerCh08PrefixShareRoutes(app: EndpointRouteBuilder): Unit {
    // TC188: /api/users + /api/posts → 共享 /api 节点，分叉为 users / posts
    app.mapGet("/ch08/api/users") { ctx => writeMatched(ctx) }
    app.mapGet("/ch08/api/posts") { ctx => writeMatched(ctx) }

    // TC189: /api/v1 + /api/v2 → 共享 /api，分叉 v1 / v2
    app.mapGet("/ch08/api/v1") { ctx => writeMatched(ctx) }
    app.mapGet("/ch08/api/v2") { ctx => writeMatched(ctx) }

    // TC190: /users + /posts → 根节点直接分两路
    app.mapGet("/ch08/users") { ctx => writeMatched(ctx) }
    app.mapGet("/ch08/posts") { ctx => writeMatched(ctx) }
}

/**
 * 8.2 字面量与参数节点共存 (TC191-192)
 */
func registerCh08LiteralParamCoexistRoutes(app: EndpointRouteBuilder): Unit {
    // TC191: /mixed/me（字面量）+ /mixed/{id}（参数）
    // me 走字面量节点，其他走参数节点
    app.mapGet("/ch08/mixed/me") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal_me\"}")
    }
    app.mapGet("/ch08/mixed/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"param\""),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC192: /three/me（字面量）+ /{id:int}（约束参数）+ /{name}（普通参数）
    app.mapGet("/ch08/three/me") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal_me\"}")
    }
    app.mapGet("/ch08/three/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"constrained\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch08/three/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 8.3 Catch-all 自循环节点 (TC193-194)
 * catch-all 节点在 DFA 中指向自身（自循环），支持任意深度匹配
 */
func registerCh08CatchAllRoutes(app: EndpointRouteBuilder): Unit {
    // TC193-194: /{**path} → 任意深度路径均命中（1段、5段、10段）
    app.mapGet("/ch08/catchall/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }
}

/**
 * 8.4 必需值参数转为字面量 (TC195)
 * 默认值参数（default values）在 DFA 构建时路径段可被转换为字面量节点
 */
func registerCh08RequiredValueRoutes(app: EndpointRouteBuilder): Unit {
    // TC195: /{controller=Home}/{action=Index} → 使用默认值时匹配根路径
    app.mapGet("/ch08/mvc/{controller=Home}/{action=Index}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("controller", rv(ctx, "controller")),
            ("action", rv(ctx, "action"))
        ]))
    }
}

/**
 * 注册第八章所有路由
 */
public func registerCh08Routes(app: EndpointRouteBuilder): Unit {
    registerCh08PrefixShareRoutes(app)
    registerCh08LiteralParamCoexistRoutes(app)
    registerCh08CatchAllRoutes(app)
    registerCh08RequiredValueRoutes(app)
}
