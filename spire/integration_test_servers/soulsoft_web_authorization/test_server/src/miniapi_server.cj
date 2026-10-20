/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_identity_claims.*
import soulsoft_web_authorization.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_extensions_injection.*

// ========== MiniAPI 基础授权服务器 (portBase + 0) ==========
// 覆盖：匿名端点、requireAuthorization()、allowAnonymous()、用户信息返回

public func runMiniApiBasicServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)

    builder.services.addRouting()

    // 配置 JWT 认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.tokenValidationParameters = createValidationParameters()
            options.includeErrorDetails = true
        }

    // 基础授权（默认策略：需要已认证用户）
    builder.services.addAuthorization()

    let app = builder.build()

    app.useRouting()
    app.useAuthentication()
    app.useAuthorization()

    // ---- 令牌生成端点（匿名）----
    // 覆盖：无授权限制，任何请求均可访问
    app.mapPost("/token") { context =>
        let bodyStr = readRequestBody(context.request)
        var username = parseJsonField(bodyStr, "username")
        var role = parseJsonField(bodyStr, "role")
        if (username.isEmpty()) { username = "test-user" }
        if (role.isEmpty()) { role = "user" }

        let claims = ArrayList<Claim>()
        claims.add(Claim(ClaimTypes.Name, username))
        claims.add(Claim("role", role))

        let token = generateJwtToken(claims: claims, expiresInSeconds: 3600)
        let resp = buildTokenResponse(token, 3600)

        context.response.contentType = "application/json"
        context.response.write(resp.toString())
    }

    // ---- 健康检查（无授权约束）----
    // 覆盖：未挂载任何 IAuthorizeData，走 FallbackPolicy（默认为 None，即直通）
    app.mapGet("/health") { context =>
        context.response.write("OK")
    }

    // ---- 显式允许匿名 (.allowAnonymous()) ----
    // 覆盖：端点挂载 IAllowAnonymous，AuthorizationMiddleware 跳过授权检查
    app.mapGet("/public") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("This endpoint allows anonymous access"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.allowAnonymous()

    // ---- 需要认证（.requireAuthorization()）----
    // 覆盖：挂载默认 Authorize()，未携带有效 Token 返回 401
    app.mapGet("/protected") { context =>
        let user = context.user
        let name = match (user.identity) {
            case Some(identity) => getUserName(identity)
            case None => "anonymous"
        }
        let obj = JsonObject()
        obj.put("message", JsonString("Hello, ${name}!"))
        obj.put("authenticated", JsonBool(true))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization()

    // ---- 用户信息端点（需认证，返回全部 Claims）----
    // 覆盖：认证通过后可读取 context.user.identities 中的全部声明
    app.mapGet("/userinfo") { context =>
        let obj = buildClaimsObject(context.user)
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization()

    app.run()
}

// ========== MiniAPI 策略授权服务器 (portBase + 1) ==========
// 覆盖：命名策略、内联策略、直接策略对象、Assertion、多要求策略

public func runMiniApiPolicyServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)

    builder.services.addRouting()

    // 配置 JWT 认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.tokenValidationParameters = createValidationParameters()
        }

    // ---- 策略定义 ----
    // 覆盖：addPolicy(name, configure) 及各类 requirement 构建
    builder.services.addAuthorization() { options =>
        // 基于 Claim 的命名策略
        options.addPolicy("AdminOnly") { policy =>
            policy.requireClaim("role", ["admin"])
        }
        // 基于 Claim 的命名策略
        options.addPolicy("UserOnly") { policy =>
            policy.requireClaim("role", ["user"])
        }
        // 基于 requireRole 的命名策略
        options.addPolicy("AdminRole") { policy =>
            policy.requireRole(["admin"])
        }
        // 多要求策略（AND 语义：既需要 admin role，又需要 department claim）
        options.addPolicy("MultiReq") { policy =>
            policy.requireClaim("role", ["admin"])
            policy.requireClaim("department", ["engineering"])
        }
        // Assertion 策略（自定义断言）
        options.addPolicy("SeniorOnly") { policy =>
            policy.requireAssertion { ctx =>
                var hasRole = false
                var hasDept = false
                for (identity in ctx.user.identities) {
                    for (claim in identity.claims) {
                        if (claim.`type` == "role" && claim.value == "admin") {
                            hasRole = true
                        }
                        if (claim.`type` == "seniority" && claim.value == "senior") {
                            hasDept = true
                        }
                    }
                }
                hasRole && hasDept
            }
        }
    }

    let app = builder.build()

    app.useRouting()
    app.useAuthentication()
    app.useAuthorization()

    // ---- 令牌生成端点（匿名，支持额外 claims）----
    app.mapPost("/token") { context =>
        let bodyStr = readRequestBody(context.request)
        var username = parseJsonField(bodyStr, "username")
        var role = parseJsonField(bodyStr, "role")
        var department = parseJsonField(bodyStr, "department")
        var seniority = parseJsonField(bodyStr, "seniority")
        if (username.isEmpty()) { username = "test-user" }
        if (role.isEmpty()) { role = "user" }

        let claims = ArrayList<Claim>()
        claims.add(Claim(ClaimTypes.Name, username))
        claims.add(Claim("role", role))
        if (!department.isEmpty()) {
            claims.add(Claim("department", department))
        }
        if (!seniority.isEmpty()) {
            claims.add(Claim("seniority", seniority))
        }

        let token = generateJwtToken(claims: claims, expiresInSeconds: 3600)
        let resp = buildTokenResponse(token, 3600)
        context.response.contentType = "application/json"
        context.response.write(resp.toString())
    }

    // ---- 健康检查（匿名）----
    app.mapGet("/health") { context =>
        context.response.write("OK")
    }

    // ---- 命名策略：requireAuthorization(["AdminOnly"]) ----
    // 覆盖：从 IAuthorizationPolicyProvider 按名称查找策略，ClaimsAuthorizationRequirement
    app.mapGet("/admin") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Admin access granted"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(["AdminOnly"])

    // ---- 命名策略：UserOnly ----
    app.mapGet("/user") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("User access granted"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(["UserOnly"])

    // ---- 基于 requireRole 的命名策略 ----
    // 覆盖：RolesAuthorizationRequirement
    app.mapGet("/admin-role") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Admin role granted"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(["AdminRole"])

    // ---- 内联策略：requireAuthorization { configure } ----
    // 覆盖：EndpointConventionBuilder.requireAuthorization(configurePolicy) 重载
    app.mapGet("/inline-claim") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Inline claim policy passed"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization { policy =>
        policy.requireClaim("role", ["admin"])
    }

    // ---- 直接策略对象：requireAuthorization(policy) ----
    // 覆盖：EndpointConventionBuilder.requireAuthorization(policy: AuthorizationPolicy) 重载
    let directPolicy = AuthorizationPolicyBuilder()
        .requireClaim("role", ["admin"])
        .build()
    app.mapGet("/direct-policy") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Direct policy object passed"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(directPolicy)

    // ---- Assertion 策略 ----
    // 覆盖：AssertionRequirement 及自定义断言逻辑
    app.mapGet("/senior-only") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Senior assertion passed"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(["SeniorOnly"])

    // ---- 多要求策略（AND 语义）----
    // 覆盖：多个 IAuthorizationRequirement 同时满足才通过
    app.mapGet("/multi-req") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Multi-requirement policy passed"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization(["MultiReq"])

    app.run()
}
