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

// @FromHeader 来源绑定测试
// 覆盖：请求头提取 → PrimitiveModelBinder / StringModelBinder / DateTimeModelBinder
//         / NullableModelBinder / ArrayModelBinder
// 说明：参数名即为 Header 名（不区分大小写），例如参数 name → Header: name: Alice
//   - 请求头存在且有效 → 正常绑定
//   - 请求头缺失       → 默认值（Primitive）/ None（Nullable）/ 空数组（Array）
//   - 请求头值无效     → 400

@Route["api/header"]
public class HeaderController <: Controller {

    // GET /api/header/string  Header: name: Alice → {"value":"Alice"}
    // GET /api/header/string  (无 name)            → {"value":""}
    @HttpGet["string"]
    public func headerString(@FromHeader name: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(name))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/string-named  Header: X-Display-Name: Alice → {"value":"Alice"}
    // 显式指定 Header 名称，覆盖 FromHeader(name!: ?String) 构造函数路径。
    @HttpGet["string-named"]
    public func headerStringNamed(@FromHeader[name: "X-Display-Name"] value: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(value))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/int64  Header: id: 42 → {"value":42}
    // GET /api/header/int64  (无 id)          → {"value":0}
    @HttpGet["int64"]
    public func headerInt64(@FromHeader id: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(id))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/int32  Header: n: 2147483647 → {"value":2147483647}
    @HttpGet["int32"]
    public func headerInt32(@FromHeader n: Int32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/int8  Header: n: 127 → {"value":127}
    @HttpGet["int8"]
    public func headerInt8(@FromHeader n: Int8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/int16  Header: n: 32767 → {"value":32767}
    @HttpGet["int16"]
    public func headerInt16(@FromHeader n: Int16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/uint8  Header: n: 255 → {"value":255}
    @HttpGet["uint8"]
    public func headerUInt8(@FromHeader n: UInt8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/uint16  Header: n: 65535 → {"value":65535}
    @HttpGet["uint16"]
    public func headerUInt16(@FromHeader n: UInt16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/uint32  Header: n: 4294967295 → {"value":"4294967295"}
    @HttpGet["uint32"]
    public func headerUInt32(@FromHeader n: UInt32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/uint64  Header: n: 18446744073709551615
    // → {"value":"18446744073709551615"}
    @HttpGet["uint64"]
    public func headerUInt64(@FromHeader n: UInt64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/float16  Header: val: 3.14 → {"value":3.140625}
    @HttpGet["float16"]
    public func headerFloat16(@FromHeader val: Float16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/float32  Header: val: 3.14 → {"value":3.14}
    @HttpGet["float32"]
    public func headerFloat32(@FromHeader val: Float32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/float64  Header: val: 3.141592653589793 → {"value":3.141592653589793}
    @HttpGet["float64"]
    public func headerFloat64(@FromHeader val: Float64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(val))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/bigint  Header: n: 99999999999999999999
    // → {"value":"99999999999999999999"}
    @HttpGet["bigint"]
    public func headerBigInt(@FromHeader n: BigInt): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/decimal  Header: val: 3.141592653589793
    // → {"value":"3.141592653589793"}
    @HttpGet["decimal"]
    public func headerDecimal(@FromHeader val: Decimal): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(val.toString()))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/bool  Header: flag: true  → {"value":true}
    // GET /api/header/bool  Header: flag: false → {"value":false}
    // GET /api/header/bool  (无 flag)            → {"value":false}
    @HttpGet["bool"]
    public func headerBool(@FromHeader flag: Bool): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonBool(flag))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/datetime  Header: dt: 2025-01-15T10:30:00Z
    // → {"value":"...","is_epoch":false}
    @HttpGet["datetime"]
    public func headerDateTime(@FromHeader dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(dt.toString()))
        obj.put("is_epoch", JsonBool(dt == DateTime.UnixEpoch))
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/nullable-int64  Header: id: 42 → {"present":true,"value":42}
    // GET /api/header/nullable-int64  (无 id)          → {"present":false,"value":null}
    @HttpGet["nullable-int64"]
    public func headerNullableInt64(@FromHeader id: ?Int64): IActionResult {
        let obj = JsonObject()
        match (id) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/nullable-string  Header: name: Alice → {"present":true,"value":"Alice"}
    // GET /api/header/nullable-string  (无 name)            → {"present":false,"value":null}
    @HttpGet["nullable-string"]
    public func headerNullableString(@FromHeader name: ?String): IActionResult {
        let obj = JsonObject()
        match (name) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/nullable-bool  Header: flag: true → {"present":true,"value":true}
    // GET /api/header/nullable-bool  (无 flag)           → {"present":false,"value":null}
    @HttpGet["nullable-bool"]
    public func headerNullableBool(@FromHeader flag: ?Bool): IActionResult {
        let obj = JsonObject()
        match (flag) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonBool(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/nullable-datetime  Header: dt: 2025-01-15 → {"present":true,"value":"..."}
    // GET /api/header/nullable-datetime  (无 dt)                  → {"present":false,"value":null}
    @HttpGet["nullable-datetime"]
    public func headerNullableDateTime(@FromHeader dt: ?DateTime): IActionResult {
        let obj = JsonObject()
        match (dt) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/array-string  Header: tags: a（多次发送同名 Header）
    // → {"count":1,"values":["a"]}
    @HttpGet["array-string"]
    public func headerArrayString(@FromHeader tags: Array<String>): IActionResult {
        let arr = JsonArray()
        for (v in tags) { arr.add(JsonString(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(tags.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/header/array-int64  Header: ids: 1（多次发送同名 Header）
    // → {"count":1,"values":[1]}
    @HttpGet["array-int64"]
    public func headerArrayInt64(@FromHeader ids: Array<Int64>): IActionResult {
        let arr = JsonArray()
        for (v in ids) { arr.add(JsonInt(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(ids.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }
}
