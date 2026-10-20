/**
 * 第六章：HTTP 方法匹配 HttpMethodMatcherPolicy [P0]
 * 覆盖测试用例：TC146-173
 */
package test

import soulsoft_web_http.*
import soulsoft_web_cors.*
import soulsoft_web_routing.*
import soulsoft_web_routing.http.*

/**
 * 6.1 精确方法匹配 (TC146-152)
 * 6.2 方法大小写不敏感 (TC153-155) - 由框架层自动处理，Python 发送小写方法验证
 */
func registerCh06ExactMethodRoutes(app: EndpointRouteBuilder): Unit {
    // TC146: mapGet
    app.mapGet("/ch06/exact/get") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }

    // TC147: mapPost
    app.mapPost("/ch06/exact/post") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"POST\"}")
    }

    // TC148: mapPut
    app.mapPut("/ch06/exact/put") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"PUT\"}")
    }

    // TC149: mapPatch
    app.mapPatch("/ch06/exact/patch") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"PATCH\"}")
    }

    // TC150: mapDelete
    app.mapDelete("/ch06/exact/delete") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"DELETE\"}")
    }

    // TC151: GET 路由发送 POST → 405（由框架返回）
    // TC152: POST 路由发送 GET → 405（由框架返回）
    // Python 测试：对 /ch06/exact/get 发送 POST，期望 405
    // Python 测试：对 /ch06/exact/post 发送 GET，期望 405
}

/**
 * 6.3 通配方法 map (TC156-160)
 * map 注册的路由可匹配任意 HTTP 方法
 */
func registerCh06WildcardMethodRoutes(app: EndpointRouteBuilder): Unit {
    app.map("/ch06/wildcard/any") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("method", "\"${ctx.request.method}\"")
        ]))
    }
}

/**
 * 6.4 同路径多方法 (TC161-165)
 */
func registerCh06MultiMethodRoutes(app: EndpointRouteBuilder): Unit {
    // TC161-163: /items 注册 GET + POST
    app.mapGet("/ch06/items") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }
    app.mapPost("/ch06/items") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"POST\"}")
    }

    // TC165: GET + POST + map 同路径
    app.mapGet("/ch06/mixed") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"GET\"}")
    }
    app.mapPost("/ch06/mixed") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"route\": \"POST\"}")
    }
    app.map("/ch06/mixed") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("route", "\"map\""),
            ("method", "\"${ctx.request.method}\"")
        ]))
    }
}

/**
 * 6.5 CORS 预检 OPTIONS (TC166-173)
 *
 * 路由设计与 test_server/aspnet_verify/Program.cs 完全对齐：
 *   /ch06/cors/default → GET + requireCors()          使用默认策略（allowed.com AllowAnyMethod）
 *   /ch06/cors/strict  → GET + requireCors("strict")  使用命名策略（strict.com AllowAnyMethod）
 *   /ch06/cors/none    → GET（无 requireCors）         无端点策略，走中间件默认策略
 *   /ch06/cors/multi   → GET + POST，均 requireCors() 使用默认策略
 *
 * CORS 中间件行为真相（来自 C# 实测，见 aspnet_verify/Program.cs）：
 *   OPTIONS + Origin + ACR-Method（预检）→ 永远 204，ACAO 头存在与否由策略决定
 *   OPTIONS + Origin（无 ACR-Method）    → 405（不是预检，路由决定）
 *   OPTIONS 无 Origin                   → 405（CORS 中间件不拦截）
 *   普通请求带 Origin                   → 路由决定状态码，命中则加 ACAO 头
 */
func registerCh06CorsRoutes(app: EndpointRouteBuilder): Unit {
    // 场景 A：默认策略（allowed.com AllowAnyMethod AllowAnyHeader）
    app.mapGet("/ch06/cors/default") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }.requireCors()

    // 场景 B：命名策略 strict（strict.com AllowAnyMethod AllowAnyHeader）
    app.mapGet("/ch06/cors/strict") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }.requireCors("strict")

    // 场景 C：无 requireCors，CORS 中间件用全局默认策略
    app.mapGet("/ch06/cors/none") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }

    // 场景 D：同路径 GET + POST，均使用默认策略
    app.mapGet("/ch06/cors/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }.requireCors()
    app.mapPost("/ch06/cors/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"POST\"}")
    }.requireCors()
}

/**
 * 6.6 自定义 HTTP 方法 (TC172-173)
 */
func registerCh06CustomMethodRoutes(app: EndpointRouteBuilder): Unit {
    // 注册自定义方法 REPORT
    app.map("/ch06/custom/report") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("method", "\"${ctx.request.method}\"")
        ]))
    }
}

/**
 * 6.7 HttpMethodDictionaryPolicyJumpTable 大小写不敏感 + 自定义方法 (TC180-190)
 *
 * /ch06/dict/multi  → GET+POST+PUT+PATCH+DELETE，覆盖 DictionaryPolicyJumpTable 各 p-前缀分支
 * /ch06/dict/report → map + withMetadata 限制 REPORT 方法，覆盖 extraDestinations 路径
 */
func registerCh06DictLookupRoutes(app: EndpointRouteBuilder): Unit {
    app.mapGet("/ch06/dict/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"GET\"}")
    }
    app.mapPost("/ch06/dict/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"POST\"}")
    }
    app.mapPut("/ch06/dict/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"PUT\"}")
    }
    app.mapPatch("/ch06/dict/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"PATCH\"}")
    }
    app.mapDelete("/ch06/dict/multi") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"DELETE\"}")
    }

    // 通过 withMetadata 限制方法为自定义的 REPORT，验证 extraDestinations 路径
    app.map("/ch06/dict/report") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("method", "\"${ctx.request.method}\"")
        ]))
    }.withMetadata([HttpMethodMetadata(["REPORT"])])
}

/**
 * 注册第六章所有路由
 */
public func registerCh06Routes(app: EndpointRouteBuilder): Unit {
    registerCh06ExactMethodRoutes(app)
    registerCh06WildcardMethodRoutes(app)
    registerCh06MultiMethodRoutes(app)
    registerCh06CorsRoutes(app)
    registerCh06CustomMethodRoutes(app)
    registerCh06DictLookupRoutes(app)
}
