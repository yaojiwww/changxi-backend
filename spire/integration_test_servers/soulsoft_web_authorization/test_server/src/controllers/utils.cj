/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.time.*
import std.io.*
import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*

// ========== JWT 配置常量 ==========

const ControllerIssuer = "soulsoft-auth-test-server"
const ControllerAudience = "soulsoft-auth-test-client"
const ControllerSecretKey = "authorization_test_secret_key_for_jwt_testing_12345"

// ========== HTTP 请求工具 ==========

func readRequestBody(request: HttpRequest): String {
    try {
        let buffer = ByteBuffer()
        copy(request.body, to: buffer)
        return buffer |> readString
    } catch (_: Exception) {
        return ""
    }
}

func parseJsonField(jsonStr: String, fieldName: String): String {
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
    } catch (_: Exception) {}
    return ""
}

// ========== JWT 工具 ==========

func generateJwtToken(
    claims!: Collection<Claim> = [],
    expiresInSeconds!: Int64 = 3600
): String {
    let key = SymmetricSecurityKey(ControllerSecretKey.toArray())
    let creds = SigningCredentials(key, SecurityAlgorithms.HmacSha256)
    let desc = SecurityTokenDescriptor(creds)
    desc.issuer = Some(ControllerIssuer)
    desc.audience = Some(ControllerAudience)
    desc.issuedAt = Some(DateTime.nowUTC())
    desc.expires = Some(DateTime.nowUTC().addSeconds(expiresInSeconds))
    desc.claims = claims
    let handler = JwtSecurityTokenHandler()
    return handler.createEncodedJwt(desc)
}

func buildTokenResponse(token: String, expiresIn: Int64): JsonObject {
    let obj = JsonObject()
    obj.put("access_token", JsonString(token))
    obj.put("token_type", JsonString("Bearer"))
    obj.put("expires_in", JsonInt(expiresIn))
    return obj
}

// ========== Claims 工具 ==========

func getUserName(identity: ClaimsIdentity): String {
    for (claim in identity.claims) {
        if (claim.`type` == ClaimTypes.Name) {
            return claim.value
        }
    }
    return "anonymous"
}

func getUserRole(identity: ClaimsIdentity): String {
    for (claim in identity.claims) {
        if (claim.`type` == "role") {
            return claim.value
        }
    }
    return ""
}

func buildClaimsObject(user: ClaimsPrincipal): JsonObject {
    let obj = JsonObject()
    obj.put("isAuthenticated", JsonBool(user.identity?.isAuthenticated ?? false))
    let claimsArr = JsonArray()
    for (identity in user.identities) {
        for (claim in identity.claims) {
            let c = JsonObject()
            c.put("type", JsonString(claim.`type`))
            c.put("value", JsonString(claim.value))
            claimsArr.add(c)
        }
    }
    obj.put("claims", claimsArr)
    return obj
}
