/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import soulsoft_web_mvc.*

// 健康检查 — conftest.py 等待此端点就绪后才运行测试
@Route["health"]
public class HealthController <: Controller {

    @HttpGet
    public func check(): IActionResult {
        return content("OK")
    }
}
