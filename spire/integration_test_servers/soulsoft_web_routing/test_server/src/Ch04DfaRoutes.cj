/**
 * 第四章：DFA 匹配器核心 [P0]
 * 覆盖测试用例：TC76-127
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 4.1 字面量精确匹配 (TC76-82)
 * TC76-78: 大小写不敏感（路由以小写匹配，参数值保留原始大小写）
 * TC79:    无匹配路径
 * TC80:    多段字面量
 * TC81:    多段无匹配
 * TC82:    尾随斜杠行为（由 Python 客户端验证实际行为）
 */
func registerCh04LiteralRoutes(app: EndpointRouteBuilder): Unit {
    // TC76-79: /ch04/literal/users
    app.mapGet("/ch04/literal/users") { ctx =>
        writeMatched(ctx)
    }

    // TC80: /ch04/literal/api/v1/users
    app.mapGet("/ch04/literal/api/v1/users") { ctx =>
        writeMatched(ctx)
    }
}

/**
 * 4.2 路由参数值大小写保留 (TC83-85)
 * 路径被小写化用于 DFA 匹配，但参数值从原始路径提取
 */
func registerCh04ParamCaseRoutes(app: EndpointRouteBuilder): Unit {
    // TC83-84: /{id} -> 参数值保留原始大小写
    app.mapGet("/ch04/paramcase/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC85: /{ctrl}/{action}
    app.mapGet("/ch04/paramcase/{ctrl}/{action}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("ctrl", rv(ctx, "ctrl")),
            ("action", rv(ctx, "action"))
        ]))
    }
}

/**
 * 4.3 普通参数捕获 (TC86-93)
 * 含复合段匹配（v{version}, {name}.html, {a}-{b}）
 */
func registerCh04ParamCaptureRoutes(app: EndpointRouteBuilder): Unit {
    // TC86: /users/{id}
    app.mapGet("/ch04/param/users/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC88: /{a}/{b}/{c}
    app.mapGet("/ch04/param/{a}/{b}/{c}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("a", rv(ctx, "a")),
            ("b", rv(ctx, "b")),
            ("c", rv(ctx, "c"))
        ]))
    }

    // TC89: /v{version}/api -> 复合段
    app.mapGet("/ch04/complex/v{version}/api") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("version", rv(ctx, "version"))
        ]))
    }

    // TC90: /{file}.html — 独立前缀避免与 TC93 /{file}.{ext} 歧义
    app.mapGet("/ch04/suffix/{file}.html") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("file", rv(ctx, "file"))
        ]))
    }

    // TC91: /{a}-{b} -> 复合段
    app.mapGet("/ch04/complex/{a}-{b}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("a", rv(ctx, "a")),
            ("b", rv(ctx, "b"))
        ]))
    }

    // TC92: /prefix-{id}-suffix — 独立前缀避免与 TC91 /{a}-{b} 歧义
    app.mapGet("/ch04/wrap/prefix-{id}-suffix") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC93: /{file}.{ext} -> 复合段
    app.mapGet("/ch04/complex/{file}.{ext}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("file", rv(ctx, "file")),
            ("ext", rv(ctx, "ext"))
        ]))
    }
}

/**
 * 4.4 默认值行为 (TC94-97)
 * 注意：TC94-95 与 TC96-97 使用独立前缀，避免默认值路由间的歧义匹配
 */
func registerCh04DefaultRoutes(app: EndpointRouteBuilder): Unit {
    // TC94-95: /ch04/default1/{id=1}
    app.mapGet("/ch04/default1/{id=1}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC96-97: /ch04/default2/{ctrl=Home}/{action=Index}
    app.mapGet("/ch04/default2/{ctrl=Home}/{action=Index}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("ctrl", rv(ctx, "ctrl")),
            ("action", rv(ctx, "action"))
        ]))
    }
}

/**
 * 4.5 可选参数行为 (TC98-103)
 */
func registerCh04OptionalRoutes(app: EndpointRouteBuilder): Unit {
    // TC98-99: /users/{id?}
    app.mapGet("/ch04/optional/users/{id?}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC100-101: /{ctrl}/{action?}
    app.mapGet("/ch04/optional/{ctrl}/{action?}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("ctrl", rv(ctx, "ctrl")),
            ("action", rv(ctx, "action"))
        ]))
    }

    // TC102-103: /doc/{name}.{ext?}
    app.mapGet("/ch04/optional/doc/{name}.{ext?}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("name", rv(ctx, "name")),
            ("ext", rv(ctx, "ext"))
        ]))
    }
}

/**
 * 4.6 Catch-all 参数 (TC104-110)
 */
func registerCh04CatchAllRoutes(app: EndpointRouteBuilder): Unit {
    // TC104-106: /files/{**path}
    app.mapGet("/ch04/catchall/files/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }

    // TC107-108: /{**path}（根级 catch-all，需要区分前缀）
    app.mapGet("/ch04/catchall/{**path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }

    // TC109: /files/{*path} 单星 catch-all（encodeSlashes=true）
    app.mapGet("/ch04/catchall/star/files/{*path}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", rv(ctx, "path"))
        ]))
    }
}

/**
 * 4.7 约束验证与候选排除 (TC111-127)
 * TC126-127: 约束参数与无约束参数共存，验证回退
 */
func registerCh04ConstraintRoutes(app: EndpointRouteBuilder): Unit {
    // TC111-114: /users/{id:int}
    app.mapGet("/ch04/constraint/users/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }

    // TC115-118: /{flag:bool}
    app.mapGet("/ch04/constraint/bool/{flag:bool}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("flag", rv(ctx, "flag"))
        ]))
    }

    // TC119-121: /rate/{v:float}
    app.mapGet("/ch04/constraint/rate/{v:float}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("v", rv(ctx, "v"))
        ]))
    }

    // TC122-125: /slug/{s:regex([a-z]+)}
    app.mapGet("/ch04/constraint/slug/{s:regex([a-z]+)}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("s", rv(ctx, "s"))
        ]))
    }

    // TC124: /slug/{s:regex(^\d+$)}（数字正则）
    app.mapGet("/ch04/constraint/digits/{s:regex(^\\d+$)}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("s", rv(ctx, "s"))
        ]))
    }

    // TC126-127: 有约束参数 + 无约束参数共存，验证优先级回退
    // 有约束的优先，约束失败时回退到无约束
    app.mapGet("/ch04/fallback/{id:int}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"constrained\""),
            ("id", rv(ctx, "id"))
        ]))
    }
    app.mapGet("/ch04/fallback/{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"unconstrained\""),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 注册第四章所有路由
 */
public func registerCh04Routes(app: EndpointRouteBuilder): Unit {
    registerCh04LiteralRoutes(app)
    registerCh04ParamCaseRoutes(app)
    registerCh04ParamCaptureRoutes(app)
    registerCh04DefaultRoutes(app)
    registerCh04OptionalRoutes(app)
    registerCh04CatchAllRoutes(app)
    registerCh04ConstraintRoutes(app)
}
