/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * MapGroup 功能测试：路由分组前缀
 *
 * 测试场景：
 *   TC-GROUP-01: 基础分组 - 分组前缀自动附加到子路由
 *   TC-GROUP-02: 多方法分组 - 同一组内注册 GET/POST/PUT/DELETE
 *   TC-GROUP-03: 分组内参数路由 - 前缀 + 路由参数
 *   TC-GROUP-04: 嵌套分组 - 多层前缀递归合并
 *   TC-GROUP-05: 带约定的分组 - add() 为组内所有端点添加元数据
 *   TC-GROUP-06: 与非分组路由共存 - 分组路由和普通路由在同一 builder 中注册
 */
package test

import soulsoft_web_routing.*
import soulsoft_web_http.*

/**
 * TC-GROUP-01/02/03: 基础分组测试
 * 注册前缀为 /group/api 的分组，验证子路由路径自动加前缀
 */
func registerGroupBasicRoutes(app: EndpointRouteBuilder): Unit {
    let api = app.mapGroup("/group/api")

    // TC-GROUP-01: GET /group/api/hello → 200 {"matched": true, "group": "api"}
    api.mapGet("/hello") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"group\": \"api\"}")
    }

    // TC-GROUP-02a: POST /group/api/items → 200
    api.mapPost("/items") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"POST\"}")
    }

    // TC-GROUP-02b: PUT /group/api/items → 200
    api.mapPut("/items") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"PUT\"}")
    }

    // TC-GROUP-02c: DELETE /group/api/items → 200
    api.mapDelete("/items") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"method\": \"DELETE\"}")
    }

    // TC-GROUP-03: GET /group/api/users/{id} → 200 {"id": "<id>"}
    api.mapGet("/users/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }
}

/**
 * TC-GROUP-04: 嵌套分组测试
 * 多层前缀递归合并：/group/v1 → /group/v1/items → /group/v1/items/{id}
 */
func registerGroupNestedRoutes(app: EndpointRouteBuilder): Unit {
    let v1 = app.mapGroup("/group/v1")
    let items = v1.mapGroup("/items")

    // TC-GROUP-04a: GET /group/v1/items → 200
    items.mapGet("") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"path\": \"/group/v1/items\"}")
    }

    // TC-GROUP-04b: GET /group/v1/items/{id} → 200 {"id": "<id>"}
    items.mapGet("/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("path", "\"/group/v1/items/{id}\""),
            ("id", rv(ctx, "id"))
        ]))
    }
}

/**
 * TC-GROUP-04c: 链式调用嵌套分组
 * mapGroup("f").mapGroup("a") 直接链式，不保留中间变量
 * 验证与分变量写法行为一致
 */
func registerGroupChainedNestRoutes(app: EndpointRouteBuilder): Unit {
    // GET /group/chain/x/y/detail → 200
    app.mapGroup("/group/chain/x").mapGroup("/y").mapGet("/detail") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"path\": \"/group/chain/x/y/detail\"}")
    }

    // GET /group/chain/x/y/items/{id} → 200 {"id": "<id>"}
    app.mapGroup("/group/chain/x").mapGroup("/y").mapGet("/items/{id}") { ctx =>
        writeJson(ctx, buildJson([
            ("matched", "true"),
            ("id", rv(ctx, "id"))
        ]))
    }
}

/**
 * TC-GROUP-05: 分组约定测试
 * add() 为组内所有端点的 metadata 添加自定义标记，通过响应头暴露验证
 */
func registerGroupConventionRoutes(app: EndpointRouteBuilder): Unit {
    let admin = app.mapGroup("/group/admin")
    // 为组内所有端点添加约定：在 metadata 中插入自定义标记字符串
    admin.add { b =>
        b.metadata.add("group-convention-applied")
    }

    // TC-GROUP-05a: GET /group/admin/dashboard → 200，端点 metadata 含约定标记
    admin.mapGet("/dashboard") { ctx =>
        // 通过检查 endpoint metadata 验证约定已被应用
        let ep = ctx.getEndpoint()
        var conventionApplied = false
        if (let Some(endpoint) <- ep) {
            for (m in endpoint.metadata) {
                if (let s: String <- m) {
                    if (s == "group-convention-applied") {
                        conventionApplied = true
                    }
                }
            }
        }
        writeJson(ctx, "{\"matched\": true, \"convention\": ${conventionApplied}}")
    }

    // TC-GROUP-05b: POST /group/admin/users → 200，同样应用约定
    admin.mapPost("/users") { ctx =>
        let ep = ctx.getEndpoint()
        var conventionApplied = false
        if (let Some(endpoint) <- ep) {
            for (m in endpoint.metadata) {
                if (let s: String <- m) {
                    if (s == "group-convention-applied") {
                        conventionApplied = true
                    }
                }
            }
        }
        writeJson(ctx, "{\"matched\": true, \"convention\": ${conventionApplied}}")
    }
}

/**
 * TC-GROUP-06: 分组路由与普通路由共存
 * 验证 GroupEndpointDataSource 和 RouteEndpointDataSource 在同一 dataSources 中正常工作
 */
func registerGroupCoexistRoutes(app: EndpointRouteBuilder): Unit {
    // 普通路由（非分组）
    app.mapGet("/group/standalone") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"type\": \"standalone\"}")
    }

    // 同一 builder 中再添加分组
    let grp = app.mapGroup("/group/coexist")
    grp.mapGet("/a") { ctx =>
        writeJson(ctx, "{\"matched\": true, \"type\": \"grouped\"}")
    }
}

/**
 * 注册 MapGroup 相关的所有测试路由
 */
public func registerGroupRoutes(app: EndpointRouteBuilder): Unit {
    registerGroupBasicRoutes(app)
    registerGroupNestedRoutes(app)
    registerGroupChainedNestRoutes(app)
    registerGroupConventionRoutes(app)
    registerGroupCoexistRoutes(app)
}
