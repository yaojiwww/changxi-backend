/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import stdx.encoding.json.*
import soulsoft_web_mvc.*
import soulsoft_web_authorization.*

// ---- 公开控制器（类级 @AllowAnonymous，覆盖：整个 Controller 允许匿名访问）----
// 无论是否携带有效 Token，均可访问所有 action

@Route["api/public"]
@AllowAnonymous
public class PublicController <: Controller {

    // 健康检查
    @HttpGet["/health"]
    public func health(): IActionResult {
        return content("OK")
    }

    // 公开信息（匿名可读）
    @HttpGet["info"]
    public func info(): IActionResult {
        let obj = JsonObject()
        obj.put("message", JsonString("This controller allows anonymous access"))
        obj.put("controller", JsonString("PublicController"))
        return content(obj.toString(), "application/json")
    }
}
