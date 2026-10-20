/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.time.*
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

// ========== 错误处理测试服务器 (portBase + 2) ==========
// 功能：过期令牌、无效签名、详细验证

public func runErrorHandlingServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)

    builder.services.addRouting()

    // 配置JWT认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.tokenValidationParameters = createValidationParameters()
            options.includeErrorDetails = true
        }

    builder.services.addAuthorization()

    let app = builder.build()

    app.useRouting()
    app.useAuthentication()
    app.useAuthorization()

    // 健康检查（匿名）
    app.mapGet("/health") { context =>
        context.response.write("OK")
    }

    // 生成过期令牌（匿名，测试用）
    app.mapGet("/test/expired") { context =>
        let creds = createSigningCredentials()
        let desc = SecurityTokenDescriptor(creds)
        desc.issuer = Some(Issuer)
        desc.audience = Some(Audience)
        desc.issuedAt = Some(DateTime.nowUTC().addSeconds(-7200))
        desc.expires = Some(DateTime.nowUTC().addSeconds(-3600))

        let handler = JwtSecurityTokenHandler()
        let token = handler.createEncodedJwt(desc)

        let obj = JsonObject()
        obj.put("expired_token", JsonString(token))
        obj.put("note", JsonString("This token is expired"))

        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }

    // 生成无效签名令牌（匿名，测试用）
    app.mapGet("/test/invalid") { context =>
        let wrongKey = SymmetricSecurityKey("wrong-key-123456789012345678901234567890".toArray())
        let wrongCreds = SigningCredentials(wrongKey, SecurityAlgorithms.HmacSha256)
        let desc = SecurityTokenDescriptor(wrongCreds)
        desc.issuer = Some(Issuer)
        desc.audience = Some(Audience)
        desc.expires = Some(DateTime.nowUTC().addSeconds(3600))

        let handler = JwtSecurityTokenHandler()
        let token = handler.createEncodedJwt(desc)

        let obj = JsonObject()
        obj.put("invalid_token", JsonString(token))
        obj.put("note", JsonString("This token has wrong signature"))

        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }

    // 详细令牌验证（匿名）
    app.mapPost("/verify") { context =>
        let bodyStr = readRequestBody(context.request)
        let token = parseJsonField(bodyStr, "token")

        let handler = JwtSecurityTokenHandler()
        let params = createValidationParameters()
        let result = handler.validateToken(token, params)

        let responseObj = JsonObject()
        match (result) {
            case TokenValidationResult.Success(identity, securityToken) =>
                let jwtToken = (securityToken as JwtSecurityToken).getOrThrow()

                responseObj.put("valid", JsonBool(true))
                responseObj.put("issuer", JsonString(jwtToken.payload.iss ?? ""))

                // 受众数组
                let audArray = JsonArray()
                for (aud in jwtToken.payload.aud) {
                    audArray.add(JsonString(aud))
                }
                responseObj.put("audience", audArray)

                // 声明对象
                let claimsObj = JsonObject()
                for (claim in identity.claims) {
                    claimsObj.put(claim.`type`, JsonString(claim.value))
                }
                responseObj.put("claims", claimsObj)
            case TokenValidationResult.Failed(exception) =>
                responseObj.put("valid", JsonBool(false))
                responseObj.put("error", JsonString(exception.message))
                context.response.statusCode = 401
        }

        context.response.contentType = "application/json"
        context.response.write(responseObj.toString())
    }

    // 受保护端点（需认证）
    app.mapGet("/protected") { context =>
        let obj = JsonObject()
        obj.put("message", JsonString("Access granted"))
        context.response.contentType = "application/json"
        context.response.write(obj.toString())
    }.requireAuthorization()

    app.run()
}
