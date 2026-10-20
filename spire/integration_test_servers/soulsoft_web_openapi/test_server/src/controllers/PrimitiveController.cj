/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_openapi_test_server.controllers

import std.math.numeric.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// ═══════════════════════════════════════════════════════════════════════════════
// DTO 定义 - 用于 OpenAPI responses schema 生成
// ═══════════════════════════════════════════════════════════════════════════════

// 基础类型返回值包装器
@Serialization
public class PrimitiveValueResponse {
    private var _value: Int64 = 0
}

// 字符串类型返回值
@Serialization
public class StringValueResponse {
    private var _value: String = ""
}

// 布尔类型返回值
@Serialization
public class BoolValueResponse {
    private var _value: Bool = false
}

// 浮点数类型返回值
@Serialization
public class FloatValueResponse {
    private var _value: Float64 = 0.0
}

// ═══════════════════════════════════════════════════════════════════════════════
// 基础类型测试控制器
// 验证 OpenAPI 基础类型 schema 生成
// 所有方法返回具体 DTO 类型，使 OpenAPI 能正确推断 responses schema
// ═══════════════════════════════════════════════════════════════════════════════

@Route["api/primitive"]
public class PrimitiveController <: Controller {

    // GET /api/primitive/int64?id=42
    // OpenAPI: query parameter (int64 format), response: PrimitiveValueResponse
    @HttpGet["int64"]
    public func getInt64(@FromQuery id: Int64): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = id
        return resp
    }

    // GET /api/primitive/int32?n=2147483647
    // OpenAPI: query parameter (int32 format), response: PrimitiveValueResponse
    @HttpGet["int32"]
    public func getInt32(@FromQuery n: Int32): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = Int64(n)
        return resp
    }

    // GET /api/primitive/bool?flag=true
    // OpenAPI: query parameter (boolean type), response: BoolValueResponse
    @HttpGet["bool"]
    public func getBool(@FromQuery flag: Bool): BoolValueResponse {
        let resp = BoolValueResponse()
        resp.value = flag
        return resp
    }

    // GET /api/primitive/float64?val=3.14
    // OpenAPI: query parameter (double format), response: FloatValueResponse
    @HttpGet["float64"]
    public func getFloat64(@FromQuery val: Float64): FloatValueResponse {
        let resp = FloatValueResponse()
        resp.value = val
        return resp
    }

    // GET /api/primitive/uint64?n=18446744073709551615
    // OpenAPI: query parameter (uint64 format), response: StringValueResponse (uint64 as string)
    @HttpGet["uint64"]
    public func getUInt64(@FromQuery n: UInt64): StringValueResponse {
        let resp = StringValueResponse()
        resp.value = n.toString()
        return resp
    }

    // GET /api/primitive/int8?n=127
    // OpenAPI: query parameter (int8 format), response: PrimitiveValueResponse
    @HttpGet["int8"]
    public func getInt8(@FromQuery n: Int8): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = Int64(n)
        return resp
    }

    // GET /api/primitive/int16?n=32767
    // OpenAPI: query parameter (int16 format), response: PrimitiveValueResponse
    @HttpGet["int16"]
    public func getInt16(@FromQuery n: Int16): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = Int64(n)
        return resp
    }

    // GET /api/primitive/uint8?n=255
    // OpenAPI: query parameter (uint8 format), response: PrimitiveValueResponse
    @HttpGet["uint8"]
    public func getUInt8(@FromQuery n: UInt8): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = Int64(n)
        return resp
    }

    // GET /api/primitive/uint16?n=65535
    // OpenAPI: query parameter (uint16 format), response: PrimitiveValueResponse
    @HttpGet["uint16"]
    public func getUInt16(@FromQuery n: UInt16): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = Int64(n)
        return resp
    }

    // GET /api/primitive/uint32?n=4294967295
    // OpenAPI: query parameter (uint32 format), response: StringValueResponse
    @HttpGet["uint32"]
    public func getUInt32(@FromQuery n: UInt32): StringValueResponse {
        let resp = StringValueResponse()
        resp.value = n.toString()
        return resp
    }

    // GET /api/primitive/float16?val=3.14
    // OpenAPI: query parameter (float format), response: FloatValueResponse
    @HttpGet["float16"]
    public func getFloat16(@FromQuery val: Float16): FloatValueResponse {
        let resp = FloatValueResponse()
        resp.value = Float64(val)
        return resp
    }

    // GET /api/primitive/float32?val=3.14
    // OpenAPI: query parameter (float format), response: FloatValueResponse
    @HttpGet["float32"]
    public func getFloat32(@FromQuery val: Float32): FloatValueResponse {
        let resp = FloatValueResponse()
        resp.value = Float64(val)
        return resp
    }

    // GET /api/primitive/bigint?n=99999999999999999999
    // OpenAPI: query parameter (BigInt - string representation), response: StringValueResponse
    @HttpGet["bigint"]
    public func getBigInt(@FromQuery n: BigInt): StringValueResponse {
        let resp = StringValueResponse()
        resp.value = n.toString()
        return resp
    }

    // GET /api/primitive/decimal?val=3.141592653589793
    // OpenAPI: query parameter (Decimal - string representation), response: StringValueResponse
    @HttpGet["decimal"]
    public func getDecimal(@FromQuery val: Decimal): StringValueResponse {
        let resp = StringValueResponse()
        resp.value = val.toString()
        return resp
    }

    // POST /api/primitive/body
    // OpenAPI: requestBody with primitive type (int64), response: PrimitiveValueResponse
    @HttpPost["body"]
    public func postBody(@FromBody id: Int64): PrimitiveValueResponse {
        let resp = PrimitiveValueResponse()
        resp.value = id
        return resp
    }
}
