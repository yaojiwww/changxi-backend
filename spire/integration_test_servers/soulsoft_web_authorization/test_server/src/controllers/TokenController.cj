/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.collection.*
import stdx.encoding.json.*
import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_mvc.*
import soulsoft_web_authorization.*
import soulsoft_identity_claims.*

// ---- 令牌生成控制器（完全匿名，覆盖：无 @Authorize 注解时的直通行为）----

@Route["api/token"]
public class TokenController <: Controller {

    // 生成用于测试的 JWT 令牌
    // 接受 JSON body: { "username": "...", "role": "...", "department": "...", "seniority": "..." }
    @HttpPost[""]
    public func generateToken(): IActionResult {
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

        return content(resp.toString(), "application/json")
    }
}
