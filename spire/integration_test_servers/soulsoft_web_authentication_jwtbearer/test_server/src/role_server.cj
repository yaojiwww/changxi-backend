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

// ========== 角色授权服务器 (portBase + 1) ==========
// 功能：基于角色的策略授权

public func runRoleBasedServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)

    builder.services.addRouting()

    // 配置JWT认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme).addJwtBearer(JwtBearerDefaults.Scheme) {
        options => options.tokenValidationParameters = createValidationParameters()
    }

    // 配置授权策略
    builder.services.addAuthorization() {
        options =>
            options.addPolicy("AdminOnly") {
                policy => policy.requireClaim("role", "admin")
            }
            options.addPolicy("UserOnly") {
                policy => policy.requireClaim("role", "user")
            }
    }

    let app = builder.build()

    app.useRouting()
    app.useAuthentication()
    app.useAuthorization()

    // 健康检查（匿名）
    app.mapGet("/health") {
        context => context.response.write("OK")
    }

    // 生成角色令牌（匿名）
    app.mapPost("/api/token") {
        context =>
            let bodyStr = readRequestBody(context.request)
            var username = parseJsonField(bodyStr, "username")
            var role = parseJsonField(bodyStr, "role")
            if (username.isEmpty()) {
                username = "test-user"
            }
            if (role.isEmpty()) {
                role = "user"
            }

            let claims = ArrayList<Claim>()
            claims.add(Claim(ClaimTypes.Name, username))
            claims.add(Claim("role", role))

            let token = generateJwtToken(claims: claims)

            let obj = JsonObject()
            obj.put("access_token", JsonString(token))
            obj.put("role", JsonString(role))

            context.response.contentType = "application/json"
            context.response.write(obj.toString())
    }

    // 管理员端点（需 AdminOnly 策略）
    app.mapGet("/api/admin") {
        context =>
            let obj = JsonObject()
            obj.put("message", JsonString("Admin access granted"))
            obj.put("role", JsonString("admin"))
            context.response.contentType = "application/json"
            context.response.write(obj.toString())
    }.requireAuthorization(["AdminOnly"])

    // 普通用户端点（需 UserOnly 策略）
    app.mapGet("/api/user") {
        context =>
            let obj = JsonObject()
            obj.put("message", JsonString("User access granted"))
            obj.put("role", JsonString("user"))
            context.response.contentType = "application/json"
            context.response.write(obj.toString())
    }.requireAuthorization(["UserOnly"])

    app.run()
}
