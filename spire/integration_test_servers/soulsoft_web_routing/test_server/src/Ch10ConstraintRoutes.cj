/**
 * 第十章：约束类详细边界 [P1]
 * 覆盖测试用例：TC205-233
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 10.1 IntRouteConstraint (TC205-212)
 */
func registerCh10IntRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/ch10/int/{v:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("v", rv(ctx, "v"))
        ]))
    }
}

/**
 * 10.2 BoolRouteConstraint (TC213-219)
 */
func registerCh10BoolRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/ch10/bool/{v:bool}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("v", rv(ctx, "v"))
        ]))
    }
}

/**
 * 10.3 FloatRouteConstraint (TC220-225)
 */
func registerCh10FloatRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/ch10/float/{v:float}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("v", rv(ctx, "v"))
        ]))
    }
}

/**
 * 10.4 RegexRouteConstraint (TC226-233)
 * TC226-228: pattern=[a-z]+（IgnoreCase）
 * TC229-232: pattern=^\d+$（全匹配语义）
 */
func registerCh10RegexRoutes(app: EndpointRouteBuilder): Unit {
    // [a-z]+ 不区分大小写
    app.mapGet("/ch10/regex/alpha/{s:regex([a-z]+)}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("s", rv(ctx, "s"))
        ]))
    }

    // ^\d+$ 数字全匹配
    app.mapGet("/ch10/regex/digits/{s:regex(^\\d+$)}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("s", rv(ctx, "s"))
        ]))
    }
}

/**
 * 注册第十章所有路由
 */
public func registerCh10Routes(app: EndpointRouteBuilder): Unit {
    registerCh10IntRoutes(app)
    registerCh10BoolRoutes(app)
    registerCh10FloatRoutes(app)
    registerCh10RegexRoutes(app)
}
