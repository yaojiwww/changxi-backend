/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.time.*
import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_mvc.*

// DateTime 多格式绑定测试
// 覆盖：DateTimeModelBinder + ?DateTime（NullableModelBinder）+ Array<DateTime>
//   支持格式：ISO 8601 / yyyy-MM-dd HH:mm:ss / yyyy-MM-dd / RFC822/850/1123/3339
//   - 键缺失或空串 → DateTime.UnixEpoch → {"value":"...epoch...","is_epoch":true}
//   - 有效格式     → 解析后原样返回 ISO 字符串
//   - 无效格式     → 400
@Route["api/datetime"]
public class DateTimeController <: Controller {

    // GET /api/datetime/echo?dt=2025-01-15T10:30:00Z → {"value":"...","is_epoch":false}
    // GET /api/datetime/echo                         → {"value":"...","is_epoch":true}
    // GET /api/datetime/echo?dt=not-a-date           → 400
    @HttpGet["echo"]
    public func echo(@FromQuery dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(dt.toString()))
        obj.put("is_epoch", JsonBool(dt == DateTime.UnixEpoch))
        return content(obj.toString(), "application/json")
    }

    // GET /api/datetime/year?dt=2025-06-15 → {"year":2025,"month":6,"day":15}
    // 便于测试精确日期字段
    @HttpGet["year"]
    public func year(@FromQuery dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("year",  JsonInt(Int64(dt.year)))
        let monthNum = match (dt.month) {
            case Month.January => 1
            case Month.February => 2
            case Month.March => 3
            case Month.April => 4
            case Month.May => 5
            case Month.June => 6
            case Month.July => 7
            case Month.August => 8
            case Month.September => 9
            case Month.October => 10
            case Month.November => 11
            case Month.December => 12
        }
        obj.put("month", JsonInt(Int64(monthNum)))
        obj.put("day",   JsonInt(Int64(dt.dayOfMonth)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/datetime/nullable?dt=2025-01-15T10:30:00Z → {"present":true,"value":"..."}
    // GET /api/datetime/nullable                          → {"present":false,"value":null}
    @HttpGet["nullable"]
    public func optDateTime(@FromQuery dt: ?DateTime): IActionResult {
        let obj = JsonObject()
        match (dt) {
            case Some(v) =>
                obj.put("present", JsonBool(true))
                obj.put("value", JsonString(v.toString()))
            case None =>
                obj.put("present", JsonBool(false))
                obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/datetime/array?vals=2025-01-01&vals=2025-06-15T10:30:00Z
    // → {"count":2,"values":["...","..."]}
    @HttpGet["array"]
    public func dateTimeArray(@FromQuery vals: Array<DateTime>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonString(v.toString())) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/datetime/formats?dt=2025-01-15
    // GET /api/datetime/formats?dt=2025-01-15%2010:30:00
    // GET /api/datetime/formats?dt=2025-01-15T10:30:00Z
    // 验证 DateTimeModelBinder 多格式支持，响应统一返回解析结果的 ISO 字符串
    @HttpGet["formats"]
    public func formats(@FromQuery dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("parsed", JsonString(dt.toString()))
        obj.put("year", JsonInt(Int64(dt.year)))
        obj.put("is_epoch", JsonBool(dt == DateTime.UnixEpoch))
        return content(obj.toString(), "application/json")
    }
}
