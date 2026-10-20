/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import stdx.encoding.json.*
import soulsoft_web_mvc.*

// String 类型绑定测试
// 覆盖：StringModelBinder
//   - 键缺失    → 返回空字符串 ""
//   - 值为空串  → 返回空字符串 ""
//   - 有效字符串 → 原样返回
@Route["api/string"]
public class StringController <: Controller {

    // GET /api/string/echo?name=Alice → {"value":"Alice"}
    // GET /api/string/echo            → {"value":""}
    // GET /api/string/echo?name=      → {"value":""}
    @HttpGet["echo"]
    public func echo(@FromQuery name: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(name))
        return content(obj.toString(), "application/json")
    }

    // GET /api/string/length?s=hello → {"value":"hello","length":5}
    @HttpGet["length"]
    public func length(@FromQuery s: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(s))
        obj.put("length", JsonInt(Int64(s.size)))
        return content(obj.toString(), "application/json")
    }
}
