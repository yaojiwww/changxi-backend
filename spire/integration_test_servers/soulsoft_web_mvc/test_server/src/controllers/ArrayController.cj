/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.time.*
import std.collection.*
import std.math.numeric.*
import stdx.encoding.json.*
import soulsoft_web_mvc.*

// Array<T> 多值绑定测试
// 覆盖：ArrayModelBinder<T>（由 ModelBinderFactory 自动组装）全部 16 种 + Array<?T> 代表性
//   - 无值          → 空数组
//   - 单值          → 单元素数组
//   - 多值          → 多元素数组（空字符串元素自动跳过）
//   HTTP 重复参数：?ids=1&ids=2&ids=3
@Route["api/array"]
public class ArrayController <: Controller {

    // GET /api/array/int64?ids=1&ids=2&ids=3 → {"count":3,"values":[1,2,3]}
    // GET /api/array/int64                   → {"count":0,"values":[]}
    @HttpGet["int64"]
    public func intArray(@FromQuery ids: Array<Int64>): IActionResult {
        let arr = JsonArray()
        for (v in ids) {
            arr.add(JsonInt(v))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(ids.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/string?tags=a&tags=b → {"count":2,"values":["a","b"]}
    @HttpGet["string"]
    public func stringArray(@FromQuery tags: Array<String>): IActionResult {
        let arr = JsonArray()
        for (v in tags) {
            arr.add(JsonString(v))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(tags.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/bool?flags=true&flags=false → {"count":2,"values":[true,false]}
    @HttpGet["bool"]
    public func boolArray(@FromQuery flags: Array<Bool>): IActionResult {
        let arr = JsonArray()
        for (v in flags) {
            arr.add(JsonBool(v))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(flags.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/float64?vals=1.5&vals=2.5&vals=3.5 → {"count":3,"values":[1.5,2.5,3.5]}
    @HttpGet["float64"]
    public func float64Array(@FromQuery vals: Array<Float64>): IActionResult {
        let arr = JsonArray()
        for (v in vals) {
            arr.add(JsonFloat(v))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/int32?vals=100&vals=200 → {"count":2,"values":[100,200]}
    @HttpGet["int32"]
    public func int32Array(@FromQuery vals: Array<Int32>): IActionResult {
        let arr = JsonArray()
        for (v in vals) {
            arr.add(JsonInt(Int64(v)))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/uint64?vals=18446744073709551615&vals=0 → {"count":2,"values":["18446744073709551615","0"]}
    @HttpGet["uint64"]
    public func uint64Array(@FromQuery vals: Array<UInt64>): IActionResult {
        let arr = JsonArray()
        for (v in vals) {
            arr.add(JsonString(v.toString()))
        }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/int8?vals=127&vals=-128&vals=0 → {"count":3,"values":[127,-128,0]}
    @HttpGet["int8"]
    public func int8Array(@FromQuery vals: Array<Int8>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonInt(Int64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/int16?vals=32767&vals=-32768 → {"count":2,"values":[32767,-32768]}
    @HttpGet["int16"]
    public func int16Array(@FromQuery vals: Array<Int16>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonInt(Int64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/uint8?vals=0&vals=128&vals=255 → {"count":3,"values":[0,128,255]}
    @HttpGet["uint8"]
    public func uint8Array(@FromQuery vals: Array<UInt8>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonInt(Int64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/uint16?vals=0&vals=65535 → {"count":2,"values":[0,65535]}
    @HttpGet["uint16"]
    public func uint16Array(@FromQuery vals: Array<UInt16>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonInt(Int64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/uint32?vals=0&vals=4294967295 → {"count":2,"values":["0","4294967295"]}
    @HttpGet["uint32"]
    public func uint32Array(@FromQuery vals: Array<UInt32>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonString(v.toString())) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/float16?vals=1.0&vals=2.0 → {"count":2,"values":[1.0,2.0]}
    @HttpGet["float16"]
    public func float16Array(@FromQuery vals: Array<Float16>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonFloat(Float64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/float32?vals=1.5&vals=2.5 → {"count":2,"values":[1.5,2.5]}
    @HttpGet["float32"]
    public func float32Array(@FromQuery vals: Array<Float32>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonFloat(Float64(v))) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/bigint?vals=999999999999&vals=0 → {"count":2,"values":["999999999999","0"]}
    @HttpGet["bigint"]
    public func bigIntArray(@FromQuery vals: Array<BigInt>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonString(v.toString())) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/decimal?vals=3.14&vals=2.71 → {"count":2,"values":["3.14","2.71"]}
    @HttpGet["decimal"]
    public func decimalArray(@FromQuery vals: Array<Decimal>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonString(v.toString())) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

    // GET /api/array/datetime?vals=2025-01-01&vals=2025-06-15 → {"count":2,"values":["...","..."]}
    @HttpGet["datetime"]
    public func dateTimeArray(@FromQuery vals: Array<DateTime>): IActionResult {
        let arr = JsonArray()
        for (v in vals) { arr.add(JsonString(v.toString())) }
        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(vals.size)))
        obj.put("values", arr)
        return content(obj.toString(), "application/json")
    }

}
