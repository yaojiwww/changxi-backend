/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.time.*
import std.math.numeric.*
import stdx.encoding.json.*
import soulsoft_web_mvc.*

// Option<T> 绑定测试
// 覆盖：NullableModelBinder（由 ModelBinderFactory 自动组装）全部 16 种 ?T
//   - 键缺失或值为空串 → None → {"present":false,"value":null}
//   - 有效值           → Some(T) → {"present":true,"value":<T>}
//   - 无效值           → 400（内层绑定器写入 modelState 错误）
@Route["api/nullable"]
public class NullableController <: Controller {

    // GET /api/nullable/int64?id=42 → {"present":true,"value":42}
    // GET /api/nullable/int64       → {"present":false,"value":null}
    @HttpGet["int64"]
    public func optInt64(@FromQuery id: ?Int64): IActionResult {
        match (id) {
            case Some(v) =>
                return content("{\"present\":true,\"value\":${v}}", "application/json")
            case None =>
                return content("{\"present\":false,\"value\":null}", "application/json")
        }
    }

    // GET /api/nullable/bool?flag=true → {"present":true,"value":true}
    // GET /api/nullable/bool           → {"present":false,"value":null}
    @HttpGet["bool"]
    public func optBool(@FromQuery flag: ?Bool): IActionResult {
        match (flag) {
            case Some(v) =>
                let boolStr = if (v) { "true" } else { "false" }
                return content("{\"present\":true,\"value\":${boolStr}}", "application/json")
            case None =>
                return content("{\"present\":false,\"value\":null}", "application/json")
        }
    }

    // GET /api/nullable/string?name=Alice → {"present":true,"value":"Alice"}
    // GET /api/nullable/string            → {"present":false,"value":null}
    @HttpGet["string"]
    public func optString(@FromQuery name: ?String): IActionResult {
        let obj = JsonObject()
        match (name) {
            case Some(v) =>
                obj.put("present", JsonBool(true))
                obj.put("value", JsonString(v))
            case None =>
                obj.put("present", JsonBool(false))
                obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/int8?n=127 → {"present":true,"value":127}
    // GET /api/nullable/int8       → {"present":false,"value":null}
    @HttpGet["int8"]
    public func optInt8(@FromQuery n: ?Int8): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(Int64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/int16?n=32767 → {"present":true,"value":32767}
    @HttpGet["int16"]
    public func optInt16(@FromQuery n: ?Int16): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(Int64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/int32?n=2147483647 → {"present":true,"value":2147483647}
    @HttpGet["int32"]
    public func optInt32(@FromQuery n: ?Int32): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(Int64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/uint8?n=255 → {"present":true,"value":255}
    @HttpGet["uint8"]
    public func optUInt8(@FromQuery n: ?UInt8): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(Int64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/uint16?n=65535 → {"present":true,"value":65535}
    @HttpGet["uint16"]
    public func optUInt16(@FromQuery n: ?UInt16): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(Int64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/uint32?n=4294967295 → {"present":true,"value":"4294967295"}
    @HttpGet["uint32"]
    public func optUInt32(@FromQuery n: ?UInt32): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/uint64?n=18446744073709551615 → {"present":true,"value":"18446744073709551615"}
    @HttpGet["uint64"]
    public func optUInt64(@FromQuery n: ?UInt64): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/float16?val=3.14 → {"present":true,"value":3.140625}
    @HttpGet["float16"]
    public func optFloat16(@FromQuery val: ?Float16): IActionResult {
        let obj = JsonObject()
        match (val) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonFloat(Float64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/float32?val=3.14 → {"present":true,"value":3.14}
    @HttpGet["float32"]
    public func optFloat32(@FromQuery val: ?Float32): IActionResult {
        let obj = JsonObject()
        match (val) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonFloat(Float64(v)))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/float64?val=3.14 → {"present":true,"value":3.14}
    @HttpGet["float64"]
    public func optFloat64(@FromQuery val: ?Float64): IActionResult {
        let obj = JsonObject()
        match (val) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonFloat(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/bigint?n=99999999999999999999 → {"present":true,"value":"99999999999999999999"}
    @HttpGet["bigint"]
    public func optBigInt(@FromQuery n: ?BigInt): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/decimal?val=3.141592653589793 → {"present":true,"value":"3.141592653589793"}
    @HttpGet["decimal"]
    public func optDecimal(@FromQuery val: ?Decimal): IActionResult {
        let obj = JsonObject()
        match (val) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/nullable/datetime?dt=2025-01-15T10:30:00Z → {"present":true,"value":"..."}
    // GET /api/nullable/datetime                          → {"present":false,"value":null}
    @HttpGet["datetime"]
    public func optDateTime(@FromQuery dt: ?DateTime): IActionResult {
        let obj = JsonObject()
        match (dt) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }
}
