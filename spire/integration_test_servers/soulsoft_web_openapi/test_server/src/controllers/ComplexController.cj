/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_openapi_test_server.controllers

import std.time.*
import std.math.numeric.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// ═══════════════════════════════════════════════════════════════════════════════
// DTO 定义 - 用于验证 OpenAPI components/schemas 生成
// ═══════════════════════════════════════════════════════════════════════════════

// 基础用户DTO - 包含多种字段类型
// OpenAPI 应生成 components/schemas/UserDto
@Serialization
public class UserDto {
    private var _name: String = ""
    private var _age: Int64 = 0
    private var _email: String = ""
    private var _score: Float64 = 0.0
    private var _isActive: Bool = false
    private var _balance: ?Decimal = None
}

// 用户查询响应 DTO
@Serialization
public class UserQueryResponse {
    private var _name: String = ""
    private var _age: Int64 = 0
    private var _email: String = ""
    private var _score: Float64 = 0.0
    private var _isActive: Bool = false
    private var _balance: String = ""
}

// 全类型 DTO - 覆盖全部 16 种叶子类型字段 + ?T + Array<T>
// OpenAPI 应生成包含各种 format 的 schema
@Serialization
public class FullTypeDto {
    private var _boolVal: Bool = false
    private var _int8Val: Int8 = 0
    private var _int16Val: Int16 = 0
    private var _int32Val: Int32 = 0
    private var _int64Val: Int64 = 0
    private var _uint8Val: UInt8 = 0
    private var _uint16Val: UInt16 = 0
    private var _uint32Val: UInt32 = 0
    private var _uint64Val: UInt64 = 0
    private var _float16Val: Float16 = 0.0
    private var _float32Val: Float32 = 0.0
    private var _float64Val: Float64 = 0.0
    private var _bigIntVal: BigInt = BigInt(0)
    private var _decimalVal: Decimal = Decimal(0)
    private var _strVal: String = ""
    private var _dtVal: DateTime = DateTime.UnixEpoch
    private var _optInt64: ?Int64 = None
    private var _optDateTime: ?DateTime = None
    private var _strArr: Array<String> = Array<String>()
    private var _int64Arr: Array<Int64> = Array<Int64>()
}

// 全类型响应 DTO - 所有值转为字符串便于序列化
@Serialization
public class FullTypeResponse {
    private var _boolVal: Bool = false
    private var _int8Val: Int64 = 0
    private var _int16Val: Int64 = 0
    private var _int32Val: Int64 = 0
    private var _int64Val: Int64 = 0
    private var _uint8Val: Int64 = 0
    private var _uint16Val: Int64 = 0
    private var _uint32Val: String = ""
    private var _uint64Val: String = ""
    private var _float16Val: Float64 = 0.0
    private var _float32Val: Float64 = 0.0
    private var _float64Val: Float64 = 0.0
    private var _bigIntVal: String = ""
    private var _decimalVal: String = ""
    private var _strVal: String = ""
    private var _dtVal: String = ""
    private var _optInt64: ?Int64 = None
    private var _optDateTime: String = ""
    private var _strArr: Array<String> = Array<String>()
    private var _int64Arr: Array<Int64> = Array<Int64>()
}

// 继承场景测试 - 父类
// OpenAPI 应正确识别继承关系
@Serialization
public open class PageModel {
    private var _pageIndex: Int64 = 0
    private var _pageSize: Int64 = 0
}

// 继承场景测试 - 子类（验证父类字段是否包含在 schema 中）
@Serialization[superType: PageModel]
public class HelloModel {
    private var _id: Int64 = 10
    private var _age: ?Int64 = None
    private var _name: String = String.empty
}

// 继承响应 DTO
@Serialization[superType: PageModel]
public class HelloResponse {
    private var _id: Int64 = 0
    private var _age: ?Int64 = None
    private var _name: String = ""
}

// ═══════════════════════════════════════════════════════════════════════════════
// 复杂对象测试控制器
// 验证 OpenAPI schema 生成：
// - components/schemas 中的 DTO 定义
// - requestBody 中的 $ref 引用
// - 复杂类型的 properties 定义
// 所有方法返回具体 DTO 类型，使 OpenAPI 能正确推断 responses schema
// ═══════════════════════════════════════════════════════════════════════════════

@Route["api/complex"]
public class ComplexController <: Controller {

    // GET /api/complex/query?name=Alice&age=30
    // OpenAPI: query parameters (string, int64), response: UserQueryResponse
    @HttpGet["query"]
    public func fromQuery(@FromQuery user: UserDto): UserQueryResponse {
        let resp = UserQueryResponse()
        resp.name = user.name
        resp.age = user.age
        resp.email = user.email
        resp.score = user.score
        resp.isActive = user.isActive
        resp.balance = match (user.balance) {
            case Some(d) => d.toString()
            case None => ""
        }
        return resp
    }

    // POST /api/complex/body
    // OpenAPI: requestBody with $ref to UserDto schema, response: UserQueryResponse
    @HttpPost["body"]
    public func fromBody(user: UserDto): UserQueryResponse {
        let resp = UserQueryResponse()
        resp.name = user.name
        resp.age = user.age
        resp.email = user.email
        resp.score = user.score
        resp.isActive = user.isActive
        resp.balance = match (user.balance) {
            case Some(d) => d.toString()
            case None => ""
        }
        return resp
    }

    // GET /api/complex/full-query?boolVal=true&int8Val=127...
    // OpenAPI: query parameters with various formats, response: FullTypeResponse
    @HttpGet["full-query"]
    public func fullTypeFromQuery(@FromQuery dto: FullTypeDto): FullTypeResponse {
        return buildFullTypeResponse(dto)
    }

    // POST /api/complex/full-body
    // OpenAPI: requestBody with $ref to FullTypeDto schema, response: FullTypeResponse
    @HttpPost["full-body"]
    public func fullTypeFromBody(dto: FullTypeDto): FullTypeResponse {
        return buildFullTypeResponse(dto)
    }

    // GET /api/complex/inheritance-query?id=100&age=25&name=Test&pageIndex=1&pageSize=20
    // OpenAPI: schema with parent class properties, response: HelloResponse
    @HttpGet["inheritance-query"]
    public func inheritanceFromQuery(@FromQuery model: HelloModel): HelloResponse {
        let resp = HelloResponse()
        resp.id = model.id
        resp.age = model.age
        resp.name = model.name
        resp.pageIndex = model.pageIndex
        resp.pageSize = model.pageSize
        return resp
    }

    // POST /api/complex/inheritance-body
    // OpenAPI: requestBody with inherited model, response: HelloResponse
    @HttpPost["inheritance-body"]
    public func inheritanceFromBody(model: HelloModel): HelloResponse {
        let resp = HelloResponse()
        resp.id = model.id
        resp.age = model.age
        resp.name = model.name
        resp.pageIndex = model.pageIndex
        resp.pageSize = model.pageSize
        return resp
    }

    private func buildFullTypeResponse(dto: FullTypeDto): FullTypeResponse {
        let resp = FullTypeResponse()
        resp.boolVal = dto.boolVal
        resp.int8Val = Int64(dto.int8Val)
        resp.int16Val = Int64(dto.int16Val)
        resp.int32Val = Int64(dto.int32Val)
        resp.int64Val = dto.int64Val
        resp.uint8Val = Int64(dto.uint8Val)
        resp.uint16Val = Int64(dto.uint16Val)
        resp.uint32Val = dto.uint32Val.toString()
        resp.uint64Val = dto.uint64Val.toString()
        resp.float16Val = Float64(dto.float16Val)
        resp.float32Val = Float64(dto.float32Val)
        resp.float64Val = dto.float64Val
        resp.bigIntVal = dto.bigIntVal.toString()
        resp.decimalVal = dto.decimalVal.toString()
        resp.strVal = dto.strVal
        resp.dtVal = dto.dtVal.toString()
        resp.optInt64 = dto.optInt64
        resp.optDateTime = match (dto.optDateTime) {
            case Some(v) => v.toString()
            case None => ""
        }
        resp.strArr = dto.strArr
        resp.int64Arr = dto.int64Arr
        return resp
    }
}
