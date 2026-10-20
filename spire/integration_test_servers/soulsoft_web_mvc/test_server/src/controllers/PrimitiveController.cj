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

// 基础可解析类型绑定测试
// 覆盖：PrimitiveModelBinder<T>（全部 14 种 Parsable 类型 + UInt64）
// 另补充：代表性 NullableModelBinder（?Int64 / ?String / ?Bool / ?DateTime）
// 注：框架在 modelState 无效时自动返回 400，控制器无需手动检查
@Route["api/primitive"]
public class PrimitiveController <: Controller {

    // GET /api/primitive/int64?id=42  → {"value":42}
    // GET /api/primitive/int64        → {"value":0}  (缺省返回默认值)
    // GET /api/primitive/int64?id=abc → 400 (无效值，框架自动返回)
    @HttpGet["int64"]
    public func getInt64(@FromQuery id: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(id))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/named-int64?type=42  → {"value":42}
    // GET /api/primitive/named-int64?value=42 → {"value":0}（显式 name 优先）
    @HttpGet["named-int64"]
    public func getNamedInt64(@FromQuery[name: "type"] value: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(value))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/int32?n=2147483647 → {"value":2147483647}
    @HttpGet["int32"]
    public func getInt32(@FromQuery n: Int32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/bool?flag=true  → {"value":true}
    // GET /api/primitive/bool?flag=false → {"value":false}
    // GET /api/primitive/bool?flag=yes   → 400
    @HttpGet["bool"]
    public func getBool(@FromQuery flag: Bool): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonBool(flag))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/float64?val=3.14 → {"value":3.14}
    @HttpGet["float64"]
    public func getFloat64(@FromQuery val: Float64): IActionResult {
        return content("{\"value\":${val}}", "application/json")
    }

    // GET /api/primitive/uint64?n=18446744073709551615 → {"value":"18446744073709551615"}
    // 以字符串返回避免 JSON 精度丢失
    @HttpGet["uint64"]
    public func getUInt64(@FromQuery n: UInt64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/int8?n=127  → {"value":127}
    // GET /api/primitive/int8?n=-128 → {"value":-128}
    // GET /api/primitive/int8        → {"value":0}
    @HttpGet["int8"]
    public func getInt8(@FromQuery n: Int8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/int16?n=32767  → {"value":32767}
    // GET /api/primitive/int16?n=-32768 → {"value":-32768}
    @HttpGet["int16"]
    public func getInt16(@FromQuery n: Int16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/uint8?n=255 → {"value":255}
    // GET /api/primitive/uint8       → {"value":0}
    @HttpGet["uint8"]
    public func getUInt8(@FromQuery n: UInt8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/uint16?n=65535 → {"value":65535}
    @HttpGet["uint16"]
    public func getUInt16(@FromQuery n: UInt16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/uint32?n=4294967295 → {"value":"4294967295"}
    // 以字符串返回，因 UInt32 转换需要运行时检查
    @HttpGet["uint32"]
    public func getUInt32(@FromQuery n: UInt32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/float16?val=3.14 → {"value":3.140625}
    // Float16 精度有限，实际值会近似
    @HttpGet["float16"]
    public func getFloat16(@FromQuery val: Float16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/float32?val=3.14 → {"value":3.14}
    @HttpGet["float32"]
    public func getFloat32(@FromQuery val: Float32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/bigint?n=99999999999999999999 → {"value":"99999999999999999999"}
    // 以字符串返回避免 JSON 精度丢失
    @HttpGet["bigint"]
    public func getBigInt(@FromQuery n: BigInt): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/decimal?val=3.141592653589793 → {"value":"3.141592653589793"}
    // 以字符串返回保证精度
    @HttpGet["decimal"]
    public func getDecimal(@FromQuery val: Decimal): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(val.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/nullable-int64?id=42 → {"present":true,"value":42}
    // GET /api/primitive/nullable-int64       → {"present":false,"value":null}
    @HttpGet["nullable-int64"]
    public func getNullableInt64(@FromQuery id: ?Int64): IActionResult {
        let obj = JsonObject()
        match (id) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/nullable-string?name=Alice → {"present":true,"value":"Alice"}
    // GET /api/primitive/nullable-string            → {"present":false,"value":null}
    @HttpGet["nullable-string"]
    public func getNullableString(@FromQuery name: ?String): IActionResult {
        let obj = JsonObject()
        match (name) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/nullable-bool?flag=true → {"present":true,"value":true}
    // GET /api/primitive/nullable-bool           → {"present":false,"value":null}
    @HttpGet["nullable-bool"]
    public func getNullableBool(@FromQuery flag: ?Bool): IActionResult {
        let obj = JsonObject()
        match (flag) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonBool(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/primitive/nullable-datetime?dt=2025-01-15 → {"present":true,"value":"..."}
    // GET /api/primitive/nullable-datetime               → {"present":false,"value":null}
    @HttpGet["nullable-datetime"]
    public func getNullableDateTime(@FromQuery dt: ?DateTime): IActionResult {
        let obj = JsonObject()
        match (dt) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }
}
