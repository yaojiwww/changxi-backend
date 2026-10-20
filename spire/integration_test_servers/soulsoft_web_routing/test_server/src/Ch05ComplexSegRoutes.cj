/**
 * 第五章：复合段匹配 RoutePatternMatcher.matchComplexSegment [P1]
 * 覆盖测试用例：TC128-145
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * 5.1 前缀字面量 + 参数 (TC128-132)
 */
func registerCh05PrefixRoutes(app: EndpointRouteBuilder): Unit {
    // TC128-131: v{version}
    app.mapGet("/ch05/prefix/v{version}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("version", rv(ctx, "version"))
        ]))
    }

    // TC132: api-{name}
    app.mapGet("/ch05/prefix/api-{name}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 5.2 参数 + 后缀字面量 (TC133-136)
 */
func registerCh05SuffixRoutes(app: EndpointRouteBuilder): Unit {
    // TC133-136: {name}.html
    app.mapGet("/ch05/suffix/{name}.html") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("name", rv(ctx, "name"))
        ]))
    }
}

/**
 * 5.3 参数-分隔符-参数 (TC137-142)
 */
func registerCh05SeparatorRoutes(app: EndpointRouteBuilder): Unit {
    // TC137-141: {a}-{b}
    app.mapGet("/ch05/sep/dash/{a}-{b}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("a", rv(ctx, "a")),
            ("b", rv(ctx, "b"))
        ]))
    }

    // TC142: {a}.{b}
    app.mapGet("/ch05/sep/dot/{a}.{b}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("a", rv(ctx, "a")),
            ("b", rv(ctx, "b"))
        ]))
    }
}

/**
 * 5.4 末尾 optional 参数 (TC143-145)
 */
func registerCh05OptionalSuffixRoutes(app: EndpointRouteBuilder): Unit {
    // TC143-145: {name}.{ext?}
    app.mapGet("/ch05/optSuffix/{name}.{ext?}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("name", rv(ctx, "name")),
            ("ext", rv(ctx, "ext"))
        ]))
    }
}

/**
 * 注册第五章所有路由
 */
public func registerCh05Routes(app: EndpointRouteBuilder): Unit {
    registerCh05PrefixRoutes(app)
    registerCh05SuffixRoutes(app)
    registerCh05SeparatorRoutes(app)
    registerCh05OptionalSuffixRoutes(app)
}
