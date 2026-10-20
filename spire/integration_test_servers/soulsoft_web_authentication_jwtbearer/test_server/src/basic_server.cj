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
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_web_authorization.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_extensions_injection.*

// ========== 基础JWT服务器 (portBase + 0) ==========
// 功能：令牌生成、受保护端点、用户信息

public func runBasicJwtServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)
    configureJwtAuthentication(builder)
    let app = builder.build()

    app.useRouting()
    app.useAuthentication()
    app.useAuthorization()

    // 健康检查（匿名）
    app.mapGet("/health") { context =>
        context.response.write("OK")
    }

    // 生成令牌（匿名）
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
        let responseObj = buildTokenResponse(token, 3600)

        context.response.contentType = "application/json"
        context.response.write(responseObj.toString())
    }

    // 受保护端点（需认证）
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

    // 用户信息端点（需认证）
    app.mapGet("/userinfo") { context =>
        let claimsObj = JsonObject()
        for (identity in context.user.identities) {
            for (claim in identity.claims) {
                claimsObj.put(claim.`type`, JsonString(claim.value))
            }
        }
        context.response.contentType = "application/json"
        context.response.write(claimsObj.toString())
    }.requireAuthorization()

    // 验证令牌端点（匿名）
    app.mapPost("/validate") { context =>
        let bodyStr = readRequestBody(context.request)
        let token = parseJsonField(bodyStr, "token")

        let result = validateJwtToken(token)
        let responseObj = JsonObject()

        match (result) {
            case TokenValidationResult.Success(_, _) =>
                responseObj.put("valid", JsonBool(true))
                responseObj.put("message", JsonString("Token is valid"))
            case TokenValidationResult.Failed(exception) =>
                responseObj.put("valid", JsonBool(false))
                responseObj.put("error", JsonString(exception.message))
                context.response.statusCode = 401
        }

        context.response.contentType = "application/json"
        context.response.write(responseObj.toString())
    }

    app.run()
}
