/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.time.*
import std.math.numeric.*
import stdx.encoding.json.*
import soulsoft_serialization.*
import soulsoft_serialization.annotations.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// ─── DTO 定义 ──────────────────────────────────────────────────────────────────
// @Serialization 宏为 _xxx 字段生成 public mut prop xxx，
// ComplexObjectModelBinder 通过 instanceProperties 反射获取属性名并逐一委托绑定

// 基础用户DTO - 包含多种字段类型
@Serialization
public class UserDto {
    private var _name: String = ""
    private var _age: Int64 = 0
    private var _email: String = ""
    private var _score: Float64 = 0.0
    private var _isActive: Bool = false
    private var _balance: ?Decimal = None
}

// 全类型 DTO - 覆盖全部 16 种叶子类型字段 + ?T + Array<T>
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

// JsonPropertyName 映射 DTO - 验证 ComplexObjectModelBinder 使用 JsonPropertyName.name 作为绑定字段名
@Serialization
public class JsonPropertyNameDto {
    @JsonPropertyName["user_name"]
    private var _userName: String = ""
    @JsonPropertyName["page_no"]
    private var _pageNo: Int64 = 0
    private var _keyword: String = ""
}

// 继承场景测试 - 父类
@Serialization
public open class PageModel {
    private var _pageIndex: Int64 = 0
    private var _pageSize: Int64 = 0
}

// 继承场景测试 - 子类（Cangjie反射默认不会反射父类字段，需验证）
@Serialization[superType: PageModel]
public class HelloModel {
    private var _id: Int64 = 10
    private var _age: ?Int64 = None
    private var _name: String = String.empty
}

// 覆盖属性重名场景：用于验证 ComplexObjectModelBinder 收集属性时
// 子类 override 父类同名属性后，不会重复写入 DataModelStruct。
public open class OverrideConflictBaseModel {
    private var _tenantId: String = "tenant-default"
    private var _keywordBase: String = "base-keyword-default"

    public mut prop tenantId: String {
        get() {
            _tenantId
        }
        set(value) {
            _tenantId = value
        }
    }

    public open mut prop keyword: String {
        get() {
            _keywordBase
        }
        set(value) {
            _keywordBase = value
        }
    }
}

public open class OverrideConflictPageModel <: OverrideConflictBaseModel {
    private var _pageIndex: Int64 = 0

    public mut prop pageIndex: Int64 {
        get() {
            _pageIndex
        }
        set(value) {
            _pageIndex = value
        }
    }
}

public class OverrideConflictQueryModel <: OverrideConflictPageModel {
    private var _keyword: String = "child-keyword-default"
    private var _orderBy: String = "createdAt"

    public override mut prop keyword: String {
        get() {
            _keyword
        }
        set(value) {
            _keyword = value
        }
    }

    public mut prop orderBy: String {
        get() {
            _orderBy
        }
        set(value) {
            _orderBy = value
        }
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): OverrideConflictQueryModel {
        match (r.peek()) {
            case Some(BeginObject) => ()
            case _ => throw JsonSerializationException("JSON value is not object.")
        }
        r.startObject()
        let queryModel = OverrideConflictQueryModel()
        var keywordCount = 0
        while (r.peek() != EndObject) {
            let fieldName = r.readName()
            match (fieldName) {
                case "tenantId" =>
                    if (let Some(value) <- tryReadStringField(r, options)) {
                        queryModel.tenantId = value
                    }
                case "pageIndex" =>
                    if (let Some(value) <- tryReadInt64Field(r, options)) {
                        queryModel.pageIndex = value
                    }
                case "orderBy" =>
                    if (let Some(value) <- tryReadStringField(r, options)) {
                        queryModel.orderBy = value
                    }
                case "keyword" =>
                    keywordCount++
                    ensureSingleBoundField(keywordCount, fieldName)
                    if (let Some(value) <- tryReadStringField(r, options)) {
                        queryModel.keyword = value
                    }
                case _ => r.skip()
            }
        }
        r.endObject()
        return queryModel
    }
}

private func ensureSingleBoundField(count: Int64, fieldName: String): Unit {
    if (count > 1) {
        throw JsonSerializationException("Duplicate field '${fieldName}' found in complex object binding payload.")
    }
}

private func tryReadStringField(
    r: JsonReader,
    options: JsonSerializerOptions
): ?String {
    match (r.peek()) {
        case Some(JsonToken.JsonNull) =>
            r.skip()
            return None
        case _ => return String.fromJson(r, options)
    }
}

private func tryReadInt64Field(
    r: JsonReader,
    options: JsonSerializerOptions
): ?Int64 {
    match (r.peek()) {
        case Some(JsonToken.JsonNull) =>
            r.skip()
            return None
        case _ => return Int64.fromJson(r, options)
    }
}

// ─── Controller ───────────────────────────────────────────────────────────────
// 覆盖：ComplexObjectModelBinder（类类型由 ModelBinderFactory 自动选择）
//
// 路由一：@FromQuery → ComplexObjectModelBinder 从 query string 逐属性绑定
//   GET /api/complex/query?name=Alice&age=30 → {"name":"Alice","age":30}
//
// 路由二：无注解 → DefaultActionModelBinder 选择 bindFromBody → JsonInputFormatter
//   POST /api/complex/body (body: {"name":"Alice","age":30}) → {"name":"Alice","age":30}

@Route["api/complex"]
public class ComplexController <: Controller {

    // GET /api/complex/query?name=Alice&age=30&email=test@example.com&score=95.5&isActive=true → 完整对象
    // GET /api/complex/query?name=Alice        → {"name":"Alice","age":0,...}  (其他字段缺省)
    // GET /api/complex/query                   → 全部默认值
    @HttpGet["query"]
    public func fromQuery(@FromQuery user: UserDto): IActionResult {
        let obj = JsonObject()
        obj.put("name", JsonString(user.name))
        obj.put("age", JsonInt(user.age))
        obj.put("email", JsonString(user.email))
        obj.put("score", JsonFloat(user.score))
        obj.put("isActive", JsonBool(user.isActive))
        let balanceVal = match (user.balance) {
            case Some(d) => JsonString(d.toString())
            case None => JsonNull()
        }
        obj.put("balance", balanceVal)
        return content(obj.toString(), "application/json")
    }

    // POST /api/complex/body
    // Body: {"name":"Alice","age":30}  Content-Type: application/json
    // → {"name":"Alice","age":30}
    @HttpPost["body"]
    public func fromBody(user: UserDto): IActionResult {
        let obj = JsonObject()
        obj.put("name", JsonString(user.name))
        obj.put("age", JsonInt(user.age))
        obj.put("email", JsonString(user.email))
        obj.put("score", JsonFloat(user.score))
        obj.put("isActive", JsonBool(user.isActive))
        let balanceVal = match (user.balance) {
            case Some(d) => JsonString(d.toString())
            case None => JsonNull()
        }
        obj.put("balance", balanceVal)
        return content(obj.toString(), "application/json")
    }

    // 继承场景测试 - FromQuery
    // GET /api/complex/inheritance-query?id=100&age=25&name=Test&pageIndex=1&pageSize=20
    // 注意：Cangjie反射默认不会反射父类字段，需验证pageIndex/pageSize是否能绑定
    @HttpGet["inheritance-query"]
    public func inheritanceFromQuery(@FromQuery model: HelloModel): IActionResult {
        let obj = JsonObject()
        obj.put("id", JsonInt(model.id))
        let ageVal = match (model.age) {
            case Some(a) => JsonInt(a)
            case None => JsonNull()
        }
        obj.put("age", ageVal)
        obj.put("name", JsonString(model.name))
        // 父类字段
        obj.put("pageIndex", JsonInt(model.pageIndex))
        obj.put("pageSize", JsonInt(model.pageSize))
        return content(obj.toString(), "application/json")
    }

    // 全类型 DTO 测试 - FromQuery
    // GET /api/complex/full-query?boolVal=true&int8Val=127&int16Val=32767&int32Val=2147483647
    //   &int64Val=9223372036854775807&uint8Val=255&uint16Val=65535&uint32Val=4294967295
    //   &uint64Val=18446744073709551615&float16Val=1.5&float32Val=3.14&float64Val=2.718281828
    //   &bigIntVal=999999999999999999&decimalVal=3.141592653589793&strVal=hello
    //   &dtVal=2025-01-15&optInt64=42&strArr=a&strArr=b&int64Arr=1&int64Arr=2
    @HttpGet["full-query"]
    public func fullTypeFromQuery(@FromQuery dto: FullTypeDto): IActionResult {
        return content(buildFullTypeJson(dto), "application/json")
    }

    // 全类型 DTO 测试 - FromBody
    // POST /api/complex/full-body
    // Body: {"boolVal":true,"int8Val":127,...}
    @HttpPost["full-body"]
    public func fullTypeFromBody(dto: FullTypeDto): IActionResult {
        return content(buildFullTypeJson(dto), "application/json")
    }

    // JsonPropertyName 映射字段测试 - FromQuery
    // GET /api/complex/json-property-name-query?user_name=Alice&page_no=2&keyword=k
    @HttpGet["json-property-name-query"]
    public func jsonPropertyNameFromQuery(@FromQuery dto: JsonPropertyNameDto): IActionResult {
        let responseJson = JsonObject()
        responseJson.put("userName", JsonString(dto.userName))
        responseJson.put("pageNo", JsonInt(dto.pageNo))
        responseJson.put("keyword", JsonString(dto.keyword))
        return content(responseJson.toString(), "application/json")
    }

    private func buildFullTypeJson(dto: FullTypeDto): String {
        let obj = JsonObject()
        obj.put("boolVal", JsonBool(dto.boolVal))
        obj.put("int8Val", JsonInt(Int64(dto.int8Val)))
        obj.put("int16Val", JsonInt(Int64(dto.int16Val)))
        obj.put("int32Val", JsonInt(Int64(dto.int32Val)))
        obj.put("int64Val", JsonInt(dto.int64Val))
        obj.put("uint8Val", JsonInt(Int64(dto.uint8Val)))
        obj.put("uint16Val", JsonInt(Int64(dto.uint16Val)))
        obj.put("uint32Val", JsonString(dto.uint32Val.toString()))
        obj.put("uint64Val", JsonString(dto.uint64Val.toString()))
        obj.put("float16Val", JsonFloat(Float64(dto.float16Val)))
        obj.put("float32Val", JsonFloat(Float64(dto.float32Val)))
        obj.put("float64Val", JsonFloat(dto.float64Val))
        obj.put("bigIntVal", JsonString(dto.bigIntVal.toString()))
        obj.put("decimalVal", JsonString(dto.decimalVal.toString()))
        obj.put("strVal", JsonString(dto.strVal))
        obj.put("dtVal", JsonString(dto.dtVal.toString()))
        match (dto.optInt64) {
            case Some(v) => obj.put("optInt64", JsonInt(v))
            case None => obj.put("optInt64", JsonNull())
        }
        match (dto.optDateTime) {
            case Some(v) => obj.put("optDateTime", JsonString(v.toString()))
            case None => obj.put("optDateTime", JsonNull())
        }
        let strArrJson = JsonArray()
        for (s in dto.strArr) { strArrJson.add(JsonString(s)) }
        obj.put("strArr", strArrJson)
        let int64ArrJson = JsonArray()
        for (n in dto.int64Arr) { int64ArrJson.add(JsonInt(n)) }
        obj.put("int64Arr", int64ArrJson)
        return obj.toString()
    }

    // 继承场景测试 - FromBody
    @HttpPost["inheritance-body"]
    public func inheritanceFromBody(model: HelloModel): IActionResult {
        let obj = JsonObject()
        obj.put("id", JsonInt(model.id))
        let ageVal = match (model.age) {
            case Some(a) => JsonInt(a)
            case None => JsonNull()
        }
        obj.put("age", ageVal)
        obj.put("name", JsonString(model.name))
        obj.put("pageIndex", JsonInt(model.pageIndex))
        obj.put("pageSize", JsonInt(model.pageSize))
        return content(obj.toString(), "application/json")
    }

    // 覆盖属性重名场景 - FromQuery
    // 未修复 ReflectUtilities 时，keyword 可能被重复写入，fromJson 会抛错。
    @HttpGet["override-query"]
    public func overrideFromQuery(@FromQuery model: OverrideConflictQueryModel): IActionResult {
        return content(buildOverrideConflictJson(model), "application/json")
    }

    // 覆盖属性重名场景 - FromBody
    @HttpPost["override-body"]
    public func overrideFromBody(model: OverrideConflictQueryModel): IActionResult {
        return content(buildOverrideConflictJson(model), "application/json")
    }

    private func buildOverrideConflictJson(model: OverrideConflictQueryModel): String {
        let obj = JsonObject()
        obj.put("tenantId", JsonString(model.tenantId))
        obj.put("pageIndex", JsonInt(model.pageIndex))
        obj.put("orderBy", JsonString(model.orderBy))
        obj.put("keyword", JsonString(model.keyword))
        return obj.toString()
    }
}
