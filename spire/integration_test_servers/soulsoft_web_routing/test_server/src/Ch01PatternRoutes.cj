/**
 * 第一章：路由模式解析 RoutePatternParser [P1] — 可注册路由部分
 * 覆盖测试用例：TC1-47
 *
 * 说明：
 *  - 需要触发 RoutePatternException 的用例（TC4,16,17,32,34,35,37,38,40-47 等）
 *    通过 GET /meta/parse?pattern=<pattern> 端点验证
 *  - 此文件只注册"有效模式"路由，用于验证解析后的匹配行为（TC1-3,5-15,18-31,33,36,39）
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 1.1 前缀修剪 (TC1-5) — 有效模式
 *   TC1: /users         → 正常路径
 *   TC2: users          → 等价于 /users（meta 验证 segments=1）
 *   TC3: ~/users        → 移除 ~/（meta 验证 segments=1）
 *   TC4: ~users         → RoutePatternException（meta 验证 ok=false）
 *   TC5: ~/             → 根路径（meta 验证 segments=0）
 */
func registerCh01PrefixRoutes(app: EndpointRouteBuilder): Unit {
    // TC1: 标准斜杠前缀
    app.mapGet("/ch01/prefix/users") { ctx => writeMatched(ctx) }
    // TC5: 根路径模式等价路由（注册 /ch01/prefix/root 以区分）
    app.mapGet("/ch01/prefix/root") { ctx => writeMatched(ctx) }
}

/**
 * 1.2 字面量路由 (TC6-9)
 *   TC6: /               → 0 段（meta 验证）
 *   TC7: /users          → 1 段
 *   TC8: /api/v1/users   → 3 段
 *   TC9: /a/b/c/d/e      → 5 段
 */
func registerCh01LiteralRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/ch01/literal/users") { ctx => writeMatched(ctx) }
    app.mapGet("/ch01/literal/api/v1/users") { ctx => writeMatched(ctx) }
    app.mapGet("/ch01/literal/a/b/c/d/e") { ctx => writeMatched(ctx) }
}

/**
 * 1.3 参数路由 (TC10-15) — 有效模式（TC16/17 via meta）
 */
func registerCh01ParamRoutes(app: EndpointRouteBuilder): Unit {
    // TC10: /{id}
    app.mapGet("/ch01/param/{id}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
    // TC11: /{ctrl}/{action}
    app.mapGet("/ch01/param/{ctrl}/{action}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"), ("ctrl", rv(ctx, "ctrl")), ("action", rv(ctx, "action"))
        ]))
    }
    // TC12: /{id=42} — 独立前缀避免与 TC10 /{id} 歧义
    app.mapGet("/ch01/default/{id=42}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
    // TC13: /{id?}
    app.mapGet("/ch01/param/opt/{id?}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
    // TC14: /{**path} — 双星 catch-all
    app.mapGet("/ch01/param/dstar/{**path}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("path", rv(ctx, "path"))]))
    }
    // TC15: /{*path} — 单星 catch-all
    app.mapGet("/ch01/param/sstar/{*path}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("path", rv(ctx, "path"))]))
    }
}

/**
 * 1.4 内联约束 (TC18-25) — 有效模式
 */
func registerCh01ConstraintRoutes(app: EndpointRouteBuilder): Unit {
    // TC18: /{id:int}
    app.mapGet("/ch01/constraint/int/{id:int}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
    // TC19: /{flag:bool}
    app.mapGet("/ch01/constraint/bool/{flag:bool}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("flag", rv(ctx, "flag"))]))
    }
    // TC20: /{v:float}
    app.mapGet("/ch01/constraint/float/{v:float}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("v", rv(ctx, "v"))]))
    }
    // TC21: /{s:regex([a-z]+)}
    app.mapGet("/ch01/constraint/regex/{s:regex([a-z]+)}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("s", rv(ctx, "s"))]))
    }
    // TC23: /{id:int=5}
    app.mapGet("/ch01/constraint/intdef/{id:int=5}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
    // TC25: /{id:unknown} — RoutePatternFactory.parse() 不验证约束名，但 DFA 构建时会报错
    // 该行为通过 /meta/parse 端点验证（parse 层成功），不在此注册实际路由
}

/**
 * 1.5 复合段 (TC26-30)
 */
func registerCh01ComplexSegRoutes(app: EndpointRouteBuilder): Unit {
    // TC26: /v{version}
    app.mapGet("/ch01/complex/v{version}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("version", rv(ctx, "version"))]))
    }
    // TC27: /{name}.html — 独立前缀避免与 TC29 /{file}.{ext} 歧义
    app.mapGet("/ch01/suffix/{name}.html") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("name", rv(ctx, "name"))]))
    }
    // TC28: /{a}-{b}
    app.mapGet("/ch01/complex/{a}-{b}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("a", rv(ctx, "a")), ("b", rv(ctx, "b"))]))
    }
    // TC29: /{file}.{ext}
    app.mapGet("/ch01/complex/{file}.{ext}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("file", rv(ctx, "file")), ("ext", rv(ctx, "ext"))]))
    }
    // TC30: /prefix-{id}-suffix — 独立前缀避免与 TC28 /{a}-{b} 歧义
    app.mapGet("/ch01/wrap/prefix-{id}-suffix") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("id", rv(ctx, "id"))]))
    }
}

/**
 * 1.6 可选参数位置约束 (TC31 有效；TC32,33,34,35 via meta)
 * TC33: /path.{ext?} 在 ASP.NET Core 中为非法模式（前缀 'path.' ≠ '.'），由 /meta/parse 验证返回错误
 */
func registerCh01OptionalPosRoutes(app: EndpointRouteBuilder): Unit {
    // TC31: /{controller}/{action?} — 合法
    app.mapGet("/ch01/optpos/{controller}/{action?}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("controller", rv(ctx, "controller")),
            ("action", rv(ctx, "action"))
        ]))
    }
}

/**
 * 1.7 catch-all 位置约束 (TC36,39 有效；TC37,38 via meta)
 */
func registerCh01CatchAllPosRoutes(app: EndpointRouteBuilder): Unit {
    // TC36: /files/{**rest} — 合法
    app.mapGet("/ch01/capos/files/{**rest}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("rest", rv(ctx, "rest"))]))
    }
    // TC39: /{**rest} — 根级 catch-all
    app.mapGet("/ch01/capos/{**rest}") { ctx =>
        writeJson(ctx, buildJson([("matched", "true"), ("rest", rv(ctx, "rest"))]))
    }
}

/**
 * 1.9 花括号转义 (TC43,44 有效；TC45-47 via meta)
 * TC43: /{{literal}} → 字面量 {literal}
 * TC44: /{{id}}      → 字面量 {id}（非参数）
 */
func registerCh01EscapeRoutes(app: EndpointRouteBuilder): Unit {
    // {{literal}} 解析为字面量，注册为固定路径
    app.mapGet("/ch01/escape/{literal}") { ctx => writeMatched(ctx) }
    // 用 meta/parse 验证转义结果，此处补充一个字面量路由占位
    app.mapGet("/ch01/escape/literal-segment") { ctx => writeMatched(ctx) }
}

/**
 * 注册第一章所有路由
 */
public func registerCh01Routes(app: EndpointRouteBuilder): Unit {
    registerCh01PrefixRoutes(app)
    registerCh01LiteralRoutes(app)
    registerCh01ParamRoutes(app)
    registerCh01ConstraintRoutes(app)
    registerCh01ComplexSegRoutes(app)
    registerCh01OptionalPosRoutes(app)
    registerCh01CatchAllPosRoutes(app)
    registerCh01EscapeRoutes(app)
}
