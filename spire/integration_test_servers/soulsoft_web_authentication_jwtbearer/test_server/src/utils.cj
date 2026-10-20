/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.time.*
import std.io.*
import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*

// ========== HTTP 请求工具 ==========

/**
 * 读取请求体内容为字符串
 */
public func readRequestBody(request: HttpRequest): String {
    try {
        let buffer = ByteBuffer()
        copy(request.body, to: buffer)
        return buffer |> readString
    } catch (_: Exception) {
        return ""
    }
}

// ========== JSON 解析工具 ==========

/**
 * 从JSON字符串中提取字符串字段值
 */
public func parseJsonField(jsonStr: String, fieldName: String): String {
    try {
        let jv = JsonValue.fromStr(jsonStr)
        let obj = jv.asObject()
        match (obj.get(fieldName)) {
            case Some(v) => match (v.kind()) {
                case JsonKind.JsString => return v.asString().getValue()
                case _ => ()
            }
            case None => ()
        }
    } catch (_: Exception) {
        // 解析失败返回空字符串
    }
    return ""
}

// ========== JWT 令牌工具 ==========

/**
 * 生成JWT令牌
 */
public func generateJwtToken(
    claims!: Collection<Claim> = [],
    expiresInSeconds!: Int64 = 3600
): String {
    let creds = createSigningCredentials()
    let desc = SecurityTokenDescriptor(creds)
    desc.issuer = Some(Issuer)
    desc.audience = Some(Audience)
    desc.issuedAt = Some(DateTime.nowUTC())
    desc.expires = Some(DateTime.nowUTC().addSeconds(expiresInSeconds))
    desc.claims = claims

    let handler = JwtSecurityTokenHandler()
    return handler.createEncodedJwt(desc)
}

/**
 * 验证JWT令牌
 */
public func validateJwtToken(token: String): TokenValidationResult {
    let handler = JwtSecurityTokenHandler()
    let params = createValidationParameters()
    return handler.validateToken(token, params)
}

// ========== Claims 工具 ==========

/**
 * 从ClaimsIdentity中获取用户名
 */
public func getUserName(identity: ClaimsIdentity): String {
    for (claim in identity.claims) {
        if (claim.`type` == ClaimTypes.Name) {
            return claim.value
        }
    }
    return "anonymous"
}

/**
 * 构建令牌响应JSON
 */
public func buildTokenResponse(token: String, expiresIn: Int64): JsonObject {
    let obj = JsonObject()
    obj.put("access_token", JsonString(token))
    obj.put("token_type", JsonString("Bearer"))
    obj.put("expires_in", JsonInt(expiresIn))
    return obj
}

/**
 * 构建错误响应JSON
 */
public func buildErrorResponse(error: String): JsonObject {
    let obj = JsonObject()
    obj.put("valid", JsonBool(false))
    obj.put("error", JsonString(error))
    return obj
}
