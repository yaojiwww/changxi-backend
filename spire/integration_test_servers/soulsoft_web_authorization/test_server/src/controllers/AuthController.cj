/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import stdx.encoding.json.*
import soulsoft_web_mvc.*
import soulsoft_web_authorization.*

// ---- 认证控制器（类级 @Authorize）----
// 覆盖：
//   1. 类级 @Authorize → 所有 action 默认需要已认证用户
//   2. 方法级 @AllowAnonymous → 覆盖类级 @Authorize，允许匿名访问
//   3. 已认证用户可读取 context.user 中的 Claims 信息

@Route["api/auth"]
@Authorize
public class AuthController <: Controller {

    // 受保护 action（继承类级 @Authorize）
    // 未携带有效 Token 时返回 401
    @HttpGet["me"]
    public func me(): IActionResult {
        let obj = buildClaimsObject(context.user)
        obj.put("controller", JsonString("AuthController"))
        return content(obj.toString(), "application/json")
    }

    // 受保护 action：返回简单的已认证消息
    @HttpGet["protected"]
    public func protectedAction(): IActionResult {
        let name = match (context.user.identity) {
            case Some(identity) => getUserName(identity)
            case None => "unknown"
        }
        let obj = JsonObject()
        obj.put("message", JsonString("Hello, ${name}! You are authenticated."))
        obj.put("authenticated", JsonBool(true))
        return content(obj.toString(), "application/json")
    }

    // 匿名 action（方法级 @AllowAnonymous 覆盖类级 @Authorize）
    // 无 Token 时也可访问
    @HttpGet["anon"]
    @AllowAnonymous
    public func anonymousAction(): IActionResult {
        let obj = JsonObject()
        obj.put("message", JsonString("This action overrides class-level @Authorize with @AllowAnonymous"))
        obj.put("accessible", JsonBool(true))
        return content(obj.toString(), "application/json")
    }
}
