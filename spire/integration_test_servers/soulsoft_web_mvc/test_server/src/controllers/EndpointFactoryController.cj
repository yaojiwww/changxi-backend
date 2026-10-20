/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import stdx.encoding.json.*
import soulsoft_web_mvc.*

/**
 * ActionEndpointFactory 端点生成集成测试 Controller（带 controller 前缀）。
 *
 * 覆盖场景：
 *   1. [controller] 占位符替换 → 类名去掉 Controller 后缀并转小写作为前缀（epfactory）
 *   2. 相对路径 action 模板 → 与 controller 前缀合并为 /epfactory/{actionTemplate}
 *   3. 绝对路径 action 模板（以 '/' 开头）→ 忽略 controller 前缀，直接使用该路径
 *   4. 同一 action 多个 HTTP 方法注解 → 生成多个独立 Endpoint，各自携带正确的 HttpMethodMetadata
 *   5. [action] 占位符替换 → action 方法名小写作为路由段
 */
@Route["[controller]"]
public class EpFactoryController <: Controller {

    /**
     * 场景 1 & 2：[controller] 替换 + 相对路径合并。
     * 预期路由：GET /epfactory/relative
     */
    @HttpGet["relative"]
    public func relative(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("relative"))
        return content(obj.toString(), "application/json")
    }

    /**
     * 场景 3：action 模板以 '/' 开头 → 绝对路径，完全忽略 controller 前缀。
     * 预期路由：GET /epfactory-abs（而非 /epfactory/epfactory-abs）
     */
    @HttpGet["/epfactory-abs"]
    public func absoluteOverride(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("absolute"))
        return content(obj.toString(), "application/json")
    }

    /**
     * 场景 4：同一 action 两个 HTTP 方法注解 → 两个独立 Endpoint。
     * 预期路由：
     *   GET  /epfactory/multi → HttpMethodMetadata(["GET"])
     *   POST /epfactory/multi → HttpMethodMetadata(["POST"])
     */
    @HttpGet["multi"]
    @HttpPost["multi"]
    public func multi(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("multi"))
        return content(obj.toString(), "application/json")
    }

    /**
     * 场景 5：[action] 占位符替换 → 方法名小写（actionplaceholder）。
     * 预期路由：GET /epfactory/actionplaceholder
     */
    @HttpGet["[action]"]
    public func actionPlaceholder(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("action-placeholder"))
        return content(obj.toString(), "application/json")
    }
}

/**
 * ActionEndpointFactory 端点生成集成测试 Controller（无 controller 前缀）。
 *
 * 覆盖场景：
 *   6. controller 上无 @Route 注解（default = None）→ action 模板直接作为完整路径
 *   7. controller 无前缀 + action 相对路径 → action 模板原值解析为路由
 */
public class EpFactoryNoPrefixController <: Controller {

    /**
     * 场景 6：controller 无前缀，action 为绝对路径 → 直接使用该路径。
     * 预期路由：GET /epfactory-noprefix
     */
    @HttpGet["/epfactory-noprefix"]
    public func noPrefixAbsolute(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("no-prefix-absolute"))
        return content(obj.toString(), "application/json")
    }

    /**
     * 场景 7：controller 无前缀，action 为相对路径 → action 模板原值直接作为路径。
     * 预期路由：GET /epfactory-noprefix-rel
     */
    @HttpGet["epfactory-noprefix-rel"]
    public func noPrefixRelative(): IActionResult {
        let obj = JsonObject()
        obj.put("route", JsonString("no-prefix-relative"))
        return content(obj.toString(), "application/json")
    }
}
