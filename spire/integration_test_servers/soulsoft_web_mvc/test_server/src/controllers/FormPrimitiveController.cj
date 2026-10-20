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

// @FromForm 基础类型绑定测试
// 覆盖：表单字段提取 → PrimitiveModelBinder / StringModelBinder / DateTimeModelBinder
//         / NullableModelBinder / ArrayModelBinder
// 全部使用 Content-Type: application/x-www-form-urlencoded 或 multipart/form-data
//   - 字段存在且有效 → 正常绑定
//   - 字段缺失       → 默认值（Primitive）/ None（Nullable）/ 空数组（Array）
//   - 字段值无效     → 400

@Route["api/form"]
public class FormPrimitiveController <: Controller {

    // POST /api/form/string  body: s=hello → {"value":"hello"}
    // POST /api/form/string  body: (空)    → {"value":""}
    @HttpPost["string"]
    public func formString(@FromForm s: String): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(s))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/int64  body: n=42 → {"value":42}
    // POST /api/form/int64  body: (空) → {"value":0}
    // POST /api/form/int64  body: n=abc → 400
    @HttpPost["int64"]
    public func formInt64(@FromForm n: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(n))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/named-int64  body: type=42  → {"value":42}
    // POST /api/form/named-int64  body: value=42 → {"value":0}（显式 name 优先）
    @HttpPost["named-int64"]
    public func formNamedInt64(@FromForm[name: "type"] value: Int64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(value))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/int32  body: n=2147483647 → {"value":2147483647}
    @HttpPost["int32"]
    public func formInt32(@FromForm n: Int32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/int8  body: n=127 → {"value":127}
    @HttpPost["int8"]
    public func formInt8(@FromForm n: Int8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/int16  body: n=32767 → {"value":32767}
    @HttpPost["int16"]
    public func formInt16(@FromForm n: Int16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/uint8  body: n=255 → {"value":255}
    @HttpPost["uint8"]
    public func formUInt8(@FromForm n: UInt8): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/uint16  body: n=65535 → {"value":65535}
    @HttpPost["uint16"]
    public func formUInt16(@FromForm n: UInt16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonInt(Int64(n)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/uint32  body: n=4294967295 → {"value":"4294967295"}
    @HttpPost["uint32"]
    public func formUInt32(@FromForm n: UInt32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/uint64  body: n=18446744073709551615
    // → {"value":"18446744073709551615"}
    @HttpPost["uint64"]
    public func formUInt64(@FromForm n: UInt64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/float16  body: val=3.14 → {"value":3.140625}
    @HttpPost["float16"]
    public func formFloat16(@FromForm val: Float16): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/float32  body: val=3.14 → {"value":3.14}
    @HttpPost["float32"]
    public func formFloat32(@FromForm val: Float32): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(Float64(val)))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/float64  body: val=3.141592653589793 → {"value":3.141592653589793}
    @HttpPost["float64"]
    public func formFloat64(@FromForm val: Float64): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonFloat(val))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/bigint  body: n=99999999999999999999
    // → {"value":"99999999999999999999"}
    @HttpPost["bigint"]
    public func formBigInt(@FromForm n: BigInt): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(n.toString()))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/decimal  body: val=3.141592653589793
    // → {"value":"3.141592653589793"}
    @HttpPost["decimal"]
    public func formDecimal(@FromForm val: Decimal): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(val.toString()))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/bool  body: flag=true  → {"value":true}
    // POST /api/form/bool  body: flag=false → {"value":false}
    // POST /api/form/bool  body: (空)       → {"value":false}
    @HttpPost["bool"]
    public func formBool(@FromForm flag: Bool): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonBool(flag))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/datetime  body: dt=2025-01-15T10:30:00Z → {"value":"...","is_epoch":false}
    // POST /api/form/datetime  body: (空)                     → {"value":"...","is_epoch":true}
    @HttpPost["datetime"]
    public func formDateTime(@FromForm dt: DateTime): IActionResult {
        let obj = JsonObject()
        obj.put("value", JsonString(dt.toString()))
        obj.put("is_epoch", JsonBool(dt == DateTime.UnixEpoch))
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/nullable-int64  body: n=42 → {"present":true,"value":42}
    // POST /api/form/nullable-int64  body: (空) → {"present":false,"value":null}
    @HttpPost["nullable-int64"]
    public func formNullableInt64(@FromForm n: ?Int64): IActionResult {
        let obj = JsonObject()
        match (n) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonInt(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/nullable-string  body: s=hello → {"present":true,"value":"hello"}
    // POST /api/form/nullable-string  body: (空)     → {"present":false,"value":null}
    @HttpPost["nullable-string"]
    public func formNullableString(@FromForm s: ?String): IActionResult {
        let obj = JsonObject()
        match (s) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/nullable-bool  body: flag=true → {"present":true,"value":true}
    // POST /api/form/nullable-bool  body: (空)       → {"present":false,"value":null}
    @HttpPost["nullable-bool"]
    public func formNullableBool(@FromForm flag: ?Bool): IActionResult {
        let obj = JsonObject()
        match (flag) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonBool(v))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/nullable-datetime  body: dt=2025-01-15 → {"present":true,"value":"..."}
    // POST /api/form/nullable-datetime  body: (空)           → {"present":false,"value":null}
    @HttpPost["nullable-datetime"]
    public func formNullableDateTime(@FromForm dt: ?DateTime): IActionResult {
        let obj = JsonObject()
        match (dt) {
            case Some(v) => obj.put("present", JsonBool(true)); obj.put("value", JsonString(v.toString()))
            case None => obj.put("present", JsonBool(false)); obj.put("value", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/array-string  body: tags=a&tags=b → {"count":2,"values":["a","b"]}
    // POST /api/form/array-string  body: (空)           → {"count":0,"values":[]}
    @HttpPost["array-string"]
    public func formArrayString(@FromForm tags: Array<String>): IActionResult {
        let arr = JsonArray()
        for (v in tags) { arr.add(JsonString(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(tags.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/array-int64  body: ids=1&ids=2&ids=3 → {"count":3,"values":[1,2,3]}
    @HttpPost["array-int64"]
    public func formArrayInt64(@FromForm ids: Array<Int64>): IActionResult {
        let arr = JsonArray()
        for (v in ids) { arr.add(JsonInt(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(ids.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/array-bool  body: flags=true&flags=false → {"count":2,"values":[true,false]}
    @HttpPost["array-bool"]
    public func formArrayBool(@FromForm flags: Array<Bool>): IActionResult {
        let arr = JsonArray()
        for (v in flags) { arr.add(JsonBool(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(flags.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/array-float64  body: vals=1.5&vals=2.5 → {"count":2,"values":[1.5,2.5]}
    @HttpPost["array-float64"]
    public func formArrayFloat64(@FromForm vals: Array<Float64>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonFloat(v)) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // POST /api/form/multi  body: name=Alice&age=30&score=95.5&active=true
    // → {"name":"Alice","age":30,"score":95.5,"active":true,"optRank":null}
    @HttpPost["multi"]
    public func formMulti(
        @FromForm name: String,
        @FromForm age: Int64,
        @FromForm score: Float64,
        @FromForm active: Bool,
        @FromForm optRank: ?Int64
    ): IActionResult {
        let obj = JsonObject()
        obj.put("name", JsonString(name))
        obj.put("age", JsonInt(age))
        obj.put("score", JsonFloat(score))
        obj.put("active", JsonBool(active))
        match (optRank) {
            case Some(v) => obj.put("optRank", JsonInt(v))
            case None => obj.put("optRank", JsonNull())
        }
        return content(obj.toString(), "application/json")
    }
}
