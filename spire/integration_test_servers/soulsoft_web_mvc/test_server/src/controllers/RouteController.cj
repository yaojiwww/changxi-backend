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

// @FromRoute 来源绑定测试
// 覆盖：路由段提取 → PrimitiveModelBinder / StringModelBinder / DateTimeModelBinder / NullableModelBinder
//   - 路由段存在且有效 → 正常绑定
//   - 路由段为空串    → 默认值（Primitive）/ None（Nullable）
//   - 路由段无效      → 400

@Route["api/route"]
public class RouteController <: Controller {

    // GET /api/route/int64/42    → {"value":42}
    // GET /api/route/int64/0     → {"value":0}
    // GET /api/route/int64/abc   → 400
    @HttpGet["int64/{id}"]
    public func routeInt64(@FromRoute id: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(id))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/named-int64/42 → {"value":42}
    @HttpGet["named-int64/{type}"]
    public func routeNamedInt64(@FromRoute[name: "type"] value: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(value))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/int32/2147483647 → {"value":2147483647}
    @HttpGet["int32/{n}"]
    public func routeInt32(@FromRoute n: Int32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/int8/127  → {"value":127}
    // GET /api/route/int8/-128 → {"value":-128}
    @HttpGet["int8/{n}"]
    public func routeInt8(@FromRoute n: Int8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/int16/32767 → {"value":32767}
    @HttpGet["int16/{n}"]
    public func routeInt16(@FromRoute n: Int16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/uint8/255 → {"value":255}
    @HttpGet["uint8/{n}"]
    public func routeUInt8(@FromRoute n: UInt8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/uint16/65535 → {"value":65535}
    @HttpGet["uint16/{n}"]
    public func routeUInt16(@FromRoute n: UInt16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/uint32/4294967295 → {"value":"4294967295"}
    @HttpGet["uint32/{n}"]
    public func routeUInt32(@FromRoute n: UInt32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/uint64/18446744073709551615 → {"value":"18446744073709551615"}
    @HttpGet["uint64/{n}"]
    public func routeUInt64(@FromRoute n: UInt64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/float16/3.14 → {"value":3.140625}
    @HttpGet["float16/{val}"]
    public func routeFloat16(@FromRoute val: Float16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/float32/3.14 → {"value":3.14}
    @HttpGet["float32/{val}"]
    public func routeFloat32(@FromRoute val: Float32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/float64/3.141592653589793 → {"value":3.141592653589793}
    @HttpGet["float64/{val}"]
    public func routeFloat64(@FromRoute val: Float64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(val))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/bigint/99999999999999999999 → {"value":"99999999999999999999"}
    @HttpGet["bigint/{n}"]
    public func routeBigInt(@FromRoute n: BigInt): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/decimal/3.141592653589793 → {"value":"3.141592653589793"}
    @HttpGet["decimal/{val}"]
    public func routeDecimal(@FromRoute val: Decimal): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(val.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/bool/true  → {"value":true}
    // GET /api/route/bool/false → {"value":false}
    // GET /api/route/bool/yes   → 400
    @HttpGet["bool/{flag}"]
    public func routeBool(@FromRoute flag: Bool): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonBool(flag))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/string/hello → {"value":"hello"}
    // GET /api/route/string/      → {"value":""}
    @HttpGet["string/{name}"]
    public func routeString(@FromRoute name: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(name))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/datetime/2025-01-15 → {"value":"...","is_epoch":false}
    // GET /api/route/datetime/not-a-date → 400
    @HttpGet["datetime/{dt}"]
    public func routeDateTime(@FromRoute dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(dt.toString()))
        obj.put("is_epoch", JsonBool(dt == DateTime.UnixEpoch))
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/nullable-int64/42 → {"present":true,"value":42}
    // GET /api/route/nullable-int64/   → {"present":false,"value":null}
    @HttpGet["nullable-int64/{id}"]
    public func routeNullableInt64(@FromRoute id: ?Int64): IActionResult {
        let obj = JsonObject()
        match (id) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/route/nullable-string/hello → {"present":true,"value":"hello"}
    // GET /api/route/nullable-string/      → {"present":false,"value":null}
    @HttpGet["nullable-string/{name}"]
    public func routeNullableString(@FromRoute name: ?String): IActionResult {
        let obj = JsonObject()
        match (name) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /route/camelcaseaction → {"action":"camelCaseAction"}
    @HttpGet["/[controller]/[action]"]
    public func camelCaseAction(): IActionResult {
        let obj = JsonObject()
        obj.put("action", JsonString("camelCaseAction"))
        return content(obj.toString(), "application/json")
    }

    // GET /route/pascalcaseaction → {"action":"PascalCaseAction"}
    @HttpGet["/[controller]/[action]"]
    public func PascalCaseAction(): IActionResult {
        let obj = JsonObject()
        obj.put("action", JsonString("PascalCaseAction"))
        return content(obj.toString(), "application/json")
    }

    // GET /route/getmixedcase → {"action":"getMixedCase"}
    @HttpGet["/[controller]/[action]"]
    public func getMixedCase(): IActionResult {
        let obj = JsonObject()
        obj.put("action", JsonString("getMixedCase"))
        return content(obj.toString(), "application/json")
    }
}
