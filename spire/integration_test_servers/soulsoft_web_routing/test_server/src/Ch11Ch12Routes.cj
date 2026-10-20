/**
 * 第十一章：端到端路由管道集成 [P1]
 * 第十二章：ASP.NET Core 对齐行为 [P0]
 * 覆盖测试用例：TC234-266
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 11.1 完整请求路由 (TC234-243)
 */
func registerCh11FullPipelineRoutes(app: EndpointRouteBuilder): Unit {
    // TC234: mapGet("/users", h)
    app.mapGet("/ch11/users") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"handler\": \"h\"}")
    }

    // TC235: mapGet("/users/{id:int}", h) → handler 执行，路由值可获取
    app.mapGet("/ch11/users/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC237-238: GET /a + POST /a 同路径不同方法
    app.mapGet("/ch11/dual") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"handler\": \"h1\", \"method\": \"GET\"}")
    }
    app.mapPost("/ch11/dual") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"handler\": \"h2\", \"method\": \"POST\"}")
    }

    // TC239-240: /me（字面量）vs /{id}（参数）
    app.mapGet("/ch11/me") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"handler\": \"h1\", \"route\": \"literal_me\"}")
    }
    app.mapGet("/ch11/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("handler", "\"h2\""),
            ("route", "\"param_id\""),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC241: map("/{**path}", h) → catch-all
    app.map("/ch11/catchall/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }

    // TC242: /{ctrl}/{action} → 参数值保留原始大小写？
    app.mapGet("/ch11/mvc/{ctrl}/{action}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("ctrl", rv(ctx, "ctrl")),
            ("action", rv(ctx, "action"))
        ]))
    }
}

/**
 * 12. ASP.NET Core 对齐行为 (TC250-260)
 * 多数场景已在前面章节覆盖，此处补充独立验证端点
 */
func registerCh12AlignmentRoutes(app: EndpointRouteBuilder): Unit {
    // TC250: 字面量大小写不敏感
    app.mapGet("/ch12/align/users") { ctx =>
        writeMatched(ctx)
    }

    // TC251: 参数值原样保留
    app.mapGet("/ch12/align/greet/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC252: 优先级顺序（字面量 > 约束参数 > 无约束参数 > catch-all）
    app.mapGet("/ch12/align/priority/literal") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"literal\"}")
    }
    app.mapGet("/ch12/align/priority/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"constrained\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch12/align/priority/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }
    app.mapGet("/ch12/align/priority/{**rest}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"catchall\""),
            ("rest", rv(ctx, "rest"))
        ]))
    }

    // TC253: catch-all 可为空 /files + /files/{**path}
    app.mapGet("/ch12/align/files/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }

    // TC255: 约束失败回退
    app.mapGet("/ch12/align/fallback/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"constrained\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch12/align/fallback/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }

    // TC257-258: ** catch-all vs * catch-all
    app.mapGet("/ch12/align/dstar/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("encodeSlashes", "false"),
            ("path", rv(ctx, "path"))
        ]))
    }
    app.mapGet("/ch12/align/sstar/{*path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("encodeSlashes", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }

    // TC259: 连续斜杠视为单斜杠（//a/b → /a/b）
    app.mapGet("/ch12/align/slash/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC260: 尾随斜杠处理
    app.mapGet("/ch12/align/trailing") { ctx =>
        writeMatched(ctx)
    }

    // ── TC261-266：路由模板本身含大写/混合大小写字面量时的匹配行为 ──

    // TC261-262: 模板含纯大写字面量段 /ch12/UPPER/literal/{id}
    //   TC261: 请求小写路径 /ch12/upper/literal/42   → 命中，id='42'
    //   TC262: 请求大写路径 /ch12/UPPER/LITERAL/42   → 命中，id='42'
    app.mapGet("/ch12/UPPER/literal/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC263-264: 模板含混合大小写字面量段 /ch12/MixedCase/{id}
    //   TC263: 请求小写 /ch12/mixedcase/hello        → 命中，id='hello'
    //   TC264: 请求大写 /ch12/MIXEDCASE/HELLO        → 命中，id='HELLO'（参数值保留大小写）
    app.mapGet("/ch12/MixedCase/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC265-266: 大写模板字面量 + inline default，验证默认值大小写不被模板小写化影响
    //   TC265: 省略参数 /ch12/upperdefault           → 命中，ctrl='HomeValue'（非 'homevalue'）
    //   TC266: 提供参数 /ch12/UPPERDEFAULT/Custom    → 命中，ctrl='Custom'（URL 原始大小写）
    app.mapGet("/ch12/UpperDefault/{ctrl=HomeValue}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("ctrl", rv(ctx, "ctrl"))
        ]))
    }
}

/**
 * 注册第十一、十二章所有路由
 */
public func registerCh11Ch12Routes(app: EndpointRouteBuilder): Unit {
    registerCh11FullPipelineRoutes(app)
    registerCh12AlignmentRoutes(app)
}
