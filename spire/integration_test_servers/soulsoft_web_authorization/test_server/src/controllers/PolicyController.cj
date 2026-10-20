/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import stdx.encoding.json.*
import soulsoft_web_mvc.*
import soulsoft_web_authorization.*

// ---- 策略与角色授权控制器（方法级 @Authorize）----
// 覆盖：
//   1. @Authorize["AdminOnly"]  → 命名策略（ClaimsAuthorizationRequirement）
//   2. @Authorize["UserOnly"]   → 命名策略
//   3. @Authorize["AdminRole"]  → 命名策略（RolesAuthorizationRequirement）
//   4. 方法级 @AllowAnonymous   → 单独 action 允许匿名（无类级约束时测试独立匿名）
//   5. 无注解 action             → 无 IAuthorizeData，不触发授权检查

@Route["api/policy"]
public class PolicyController <: Controller {

    // Admin 命名策略（requireClaim("role", ["admin"])）
    // 覆盖：@Authorize["PolicyName"] 形式，查找 IAuthorizationPolicyProvider 命名策略
    @HttpGet["admin"]
    @Authorize["AdminOnly"]
    public func adminOnly(): IActionResult {
        let name = match (context.user.identity) {
            case Some(identity) => getUserName(identity)
            case None => "unknown"
        }
        let obj = JsonObject()
        obj.put("message", JsonString("Admin policy granted for ${name}"))
        obj.put("policy", JsonString("AdminOnly"))
        return content(obj.toString(), "application/json")
    }

    // User 命名策略
    @HttpGet["user"]
    @Authorize["UserOnly"]
    public func userOnly(): IActionResult {
        let name = match (context.user.identity) {
            case Some(identity) => getUserName(identity)
            case None => "unknown"
        }
        let obj = JsonObject()
        obj.put("message", JsonString("User policy granted for ${name}"))
        obj.put("policy", JsonString("UserOnly"))
        return content(obj.toString(), "application/json")
    }

    // 角色策略（RolesAuthorizationRequirement）
    // 覆盖：requireRole 构建的命名策略
    @HttpGet["admin-role"]
    @Authorize["AdminRole"]
    public func adminRole(): IActionResult {
        let role = match (context.user.identity) {
            case Some(identity) => getUserRole(identity)
            case None => "unknown"
        }
        let obj = JsonObject()
        obj.put("message", JsonString("Admin role granted"))
        obj.put("role", JsonString(role))
        return content(obj.toString(), "application/json")
    }

    // 无注解 action（无 IAuthorizeData，不触发授权中间件策略检查）
    // 覆盖：当 endpoint.metadata 中无 IAuthorizeData 时，中间件直接调用 next
    @HttpGet["open"]
    public func open(): IActionResult {
        let obj = JsonObject()
        obj.put("message", JsonString("No authorization annotation on this action"))
        obj.put("note", JsonString("Authorization middleware passes through when no IAuthorizeData present"))
        return content(obj.toString(), "application/json")
    }

    // 方法级 @AllowAnonymous（无类级 @Authorize，独立测试 IAllowAnonymous 元数据）
    @HttpGet["force-anon"]
    @AllowAnonymous
    public func forceAnonymous(): IActionResult {
        let obj = JsonObject()
        obj.put("message", JsonString("@AllowAnonymous on action without class-level @Authorize"))
        obj.put("accessible", JsonBool(true))
        return content(obj.toString(), "application/json")
    }
}
