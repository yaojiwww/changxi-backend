/**
 * 第七章：端点选择与歧义处理 DefaultEndpointSelector [P0]
 * 覆盖测试用例：TC174-187
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 7.1 优先级选择（score 低者优先）(TC174-178)
 * 字面量 > 约束参数 > 无约束参数 > catch-all
 */
func registerCh07PriorityRoutes(app: EndpointRouteBuilder): Unit {
    // TC174: /users/me（字面量）vs /users/{id}（参数）
    app.mapGet("/ch07/priority/users/me") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal_me\"}")
    }
    app.mapGet("/ch07/priority/users/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"param_id\""),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC175: /users/{id:int} vs /users/{name}
    app.mapGet("/ch07/priority/typed/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"constrained_int\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch07/priority/typed/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }

    // TC176: /api/users（字面量）vs /{**rest}（catch-all）
    app.mapGet("/ch07/priority/api/users") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal_api_users\"}")
    }
    app.mapGet("/ch07/priority/{**rest}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"catchall\""),
            ("rest", rv(ctx, "rest"))
        ]))
    }

    // TC177: /a/b/c vs /a/{x}/c vs /{**rest}
    app.mapGet("/ch07/priority/abc/a/b/c") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"abc_literal\"}")
    }
    app.mapGet("/ch07/priority/abc/a/{x}/c") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"abc_param\""),
            ("x", rv(ctx, "x"))
        ]))
    }
    app.mapGet("/ch07/priority/abc/{**rest}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"abc_catchall\""),
            ("rest", rv(ctx, "rest"))
        ]))
    }

    // TC178: /a/{id:int}/b vs /a/{name}/b
    app.mapGet("/ch07/priority/mid/{id:int}/b") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"mid_int\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch07/priority/mid/{name}/b") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"mid_name\""),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 7.2 歧义匹配异常 (TC179-181)
 * 注册同优先级路由（参数名不同但结构相同），请求时框架抛 AmbiguousMatchException → 500
 */
func registerCh07AmbiguousRoutes(app: EndpointRouteBuilder): Unit {
    // TC179: /users/{id} + /users/{name} → AmbiguousMatchException
    app.mapGet("/ch07/ambig/tc179/{id}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"id\"}")
    }
    app.mapGet("/ch07/ambig/tc179/{name}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"name\"}")
    }

    // TC180: /a/{x} + /a/{y} → AmbiguousMatchException
    app.mapGet("/ch07/ambig/tc180/{x}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"x\"}")
    }
    app.mapGet("/ch07/ambig/tc180/{y}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"y\"}")
    }

    // TC181: 3 个相同结构路由
    app.mapGet("/ch07/ambig/tc181/{x}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"x\"}")
    }
    app.mapGet("/ch07/ambig/tc181/{y}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"y\"}")
    }
    app.mapGet("/ch07/ambig/tc181/{z}") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"z\"}")
    }

    // TC188: {id:int} + {name} 同路径前缀 → 约束消除歧义，不再抛异常
    app.mapGet("/ch07/ambig/resolved/{id:int}") { ctx =>
        let id = ctx.request.routeValues["id"]
        writeJson(ctx, "{\"route\": \"int\", \"id\": \"${id}\"}")
    }
    app.mapGet("/ch07/ambig/resolved/{name}") { ctx =>
        let name = ctx.request.routeValues["name"]
        writeJson(ctx, "{\"route\": \"name\", \"name\": \"${name}\"}")
    }
}

/**
 * 7.3 无匹配 (TC182-185)
 * Python 测试向不存在的路径发请求，期望 404
 */
func registerCh07NoMatchRoutes(app: EndpointRouteBuilder): Unit {
    // TC182: 仅注册 /users
    app.mapGet("/ch07/nomatch/users") { ctx =>
        writeMatched(ctx)
    }

    // TC183: /users/{id:int} - 约束失败时 404
    app.mapGet("/ch07/nomatch/constrained/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC184: GET /users - DELETE 发送时应 405
    app.mapGet("/ch07/nomatch/method") { ctx =>
        writeMatched(ctx)
    }

    // TC185: /users/{id} - 必须提供参数
    app.mapGet("/ch07/nomatch/required/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }
}

/**
 * 7.4 单候选优化路径 (TC186-187)
 * 系统只有 1 条路由时走快速路径
 */
func registerCh07SingleCandidateRoutes(app: EndpointRouteBuilder): Unit {
    // TC186: 匹配成功
    app.mapGet("/ch07/single/match") { ctx =>
        writeMatched(ctx)
    }

    // TC187: 约束失败 → 无端点设置
    app.mapGet("/ch07/single/constrained/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }
}

/**
 * 注册第七章所有路由
 */
public func registerCh07Routes(app: EndpointRouteBuilder): Unit {
    registerCh07PriorityRoutes(app)
    registerCh07AmbiguousRoutes(app)
    registerCh07NoMatchRoutes(app)
    registerCh07SingleCandidateRoutes(app)
}
