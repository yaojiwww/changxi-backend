/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_openapi_test_server.controllers

import std.time.*
import std.collection.*
import stdx.encoding.json.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// ═══════════════════════════════════════════════════════════════════════════════
// DTO 最小化原则：每种结构分类只保留一个代表性类型
// 多个自定义类对 OpenAPI schema 生成器而言均为 ClassTypeInfo，重复定义无测试价值
// ═══════════════════════════════════════════════════════════════════════════════

// 自定义类的唯一代表（覆盖 ClassTypeInfo 路径）
// 同时包含 DateTime 和 HashMap 字段，确保这两种类型在 class 内的 schema 生成被覆盖
@Serialization
public class DataItem {
    private var _id: Int64 = 0
    private var _name: String = ""
    private var _createdAt: DateTime = DateTime.UnixEpoch
    private var _tags: HashMap<String, String> = HashMap<String, String>()
}

// 泛型类的唯一代表（覆盖 Generic ClassTypeInfo 路径）
@Serialization
public class PagedResult<T> where T <: ISerialization<T> {
    private var _items: Array<T> = []
    private var _totalCount: Int64 = 0
    private var _pageIndex: Int64 = 0
    private var _pageSize: Int64 = 0
}

// 空体响应代表（覆盖 empty schema 路径）
@Serialization
public class EmptyResponse {
}

// 可空引用属性代表（覆盖 oneOf[$ref, null] 路径）
@Serialization
public class NullableItemEnvelope {
    private var _item: ?DataItem = None
}

// 结构体 DTO 代表（覆盖 StructTypeInfo 路径）
@Serialization
public struct StructDataItem {
    private var _id: Int64 = 0
    private var _name: String = ""
}

// 枚举返回值代表（覆盖 EnumTypeInfo 路径）
public enum ResponseState <: ToString {
    Ready
    | Failed

    public func toString(): String {
        match (this) {
            case Ready => "Ready"
            case Failed => "Failed"
        }
    }
}

// 顶层可空 ActionResult 代表（覆盖 JsonResult<Option<T>> 路径）
@Serialization
public class NullableJsonItemEnvelope {
    private var _item: ?DataItem = None
}

// ═══════════════════════════════════════════════════════════════════════════════
// 响应类型测试控制器
// 按返回类型的结构分类组织，每个分类只需一个端点覆盖代码路径：
//   [1] 自定义类 (ClassTypeInfo)           → POST  /object
//   [2] 泛型类 (Generic ClassTypeInfo)     → GET   /generic
//   [3] JsonResult<自定义类>               → GET   /json-object
//   [4] JsonResult<Array<自定义类>>        → GET   /json-array-object
//   [5] JsonResult<Array<基本类型>>        → GET   /json-array-primitive
//   [6] JsonResult<泛型类>（嵌套泛型推断） → GET   /json-generic
//   [7] 空体                               → GET   /empty
//   [8] JsonResult<HashMap<K,V>>           → GET   /json-dict        （字典返回类型）
//   [9] JsonResult<DateTime>               → GET   /json-datetime    （DateTime 返回类型）
//   [10] 可空引用属性 DTO                  → GET   /nullable-object  （oneOf[$ref, null]）
//   [11] JsonResult<JsonValue>             → GET   /json-value       （任意 JSON 值）
//   [12] JsonValue request/response        → POST  /json-value-body  （任意 JSON 请求体）
// DataItem 同时包含 DateTime + HashMap 字段，[1] 的 requestBody 覆盖"在 class / model 中"两个维度
// NOTE: 框架当前只生成 200 响应，多状态码支持待 IApiResponseMetadataProvider 实现后补充
// ═══════════════════════════════════════════════════════════════════════════════

@Route["api/response"]
public class ResponseTypeController <: Controller {

    // [1] 自定义类直接返回
    // OpenAPI: responses.200.content schema → $ref DataItem
    @HttpPost["object"]
    public func returnObject(@FromBody item: DataItem): DataItem {
        return item
    }

    // [2] 泛型类直接返回
    // OpenAPI: responses.200.content schema → $ref PagedResult_DataItem_（或等价泛型展开）
    @HttpGet["generic"]
    public func returnGeneric(): PagedResult<DataItem> {
        let item = DataItem()
        item.id = 1
        item.name = "item"
        let result = PagedResult<DataItem>()
        result.items = [item]
        result.totalCount = 1
        result.pageIndex = 0
        result.pageSize = 10
        return result
    }

    // [3] JsonResult<自定义类>
    // OpenAPI: responses.200.content schema → $ref DataItem（JsonResult 透传）
    @HttpGet["json-object"]
    public func returnJsonObject(): JsonResult<DataItem> {
        let item = DataItem()
        item.id = 1
        item.name = "item"
        return json(item)
    }

    // [4] JsonResult<Array<自定义类>>
    // OpenAPI: responses.200.content schema → array, items: $ref DataItem
    @HttpGet["json-array-object"]
    public func returnJsonArrayObject(): JsonResult<Array<DataItem>> {
        let item = DataItem()
        item.id = 1
        item.name = "item"
        return json([item])
    }

    // [5] JsonResult<Array<基本类型>>
    // OpenAPI: responses.200.content schema → array, items: { type: integer, format: int64 }
    @HttpGet["json-array-primitive"]
    public func returnJsonArrayPrimitive(): JsonResult<Array<Int64>> {
        return json([1, 2, 3])
    }

    // [6] JsonResult<泛型类>（嵌套泛型推断）
    // OpenAPI: responses.200.content schema → $ref PagedResult_DataItem_（JsonResult 透传泛型）
    @HttpGet["json-generic"]
    public func returnJsonGeneric(): JsonResult<PagedResult<DataItem>> {
        let item = DataItem()
        item.id = 1
        item.name = "item"
        let result = PagedResult<DataItem>()
        result.items = [item]
        result.totalCount = 1
        result.pageIndex = 0
        result.pageSize = 10
        return json(result)
    }

    // [7] 空体响应
    // OpenAPI: responses.200.content schema → EmptyResponse（空 properties 对象）
    @HttpGet["empty"]
    public func returnEmpty(): EmptyResponse {
        return EmptyResponse()
    }

    // [8] JsonResult<HashMap<String, DataItem>>
    // OpenAPI: responses.200.content schema → {type: object, properties: {key: string, value: $ref DataItem}}
    // 覆盖：字典作为返回类型
    @HttpGet["json-dict"]
    public func returnJsonDict(): JsonResult<HashMap<String, DataItem>> {
        let item = DataItem()
        item.id = 1
        item.name = "item"
        item.createdAt = DateTime.now()
        let map = HashMap<String, DataItem>()
        map.add("key1", item)
        return json(map)
    }

    // [9] JsonResult<DateTime>
    // OpenAPI: responses.200.content schema → {type: string, format: date-time}
    // 覆盖：DateTime 作为返回类型（DateTime 属于 primitiveTypes，直接映射 OpenAPI scalar）
    @HttpGet["json-datetime"]
    public func returnJsonDateTime(): JsonResult<DateTime> {
        return json(DateTime.now())
    }

    // [10] 可空引用属性 DTO
    // OpenAPI: components NullableItemEnvelope.item → { oneOf: [{$ref: DataItem}, {type: null}] }
    @HttpGet["nullable-object"]
    public func returnNullableObject(): NullableItemEnvelope {
        let response = NullableItemEnvelope()
        response.item = Some(DataItem())
        return response
    }

    // [11] JsonResult<JsonValue>
    // OpenAPI: responses.200.content schema → {}（任意 JSON 值）
    @HttpGet["json-value"]
    public func returnJsonValue(): JsonResult<JsonValue> {
        return json(JsonValue.fromStr(#"{"name":"item","count":1,"tags":[true,null]}"#))
    }

    // [12] JsonValue request/response
    // OpenAPI: requestBody / responses.200.content schema → {}（任意 JSON 值）
    @HttpPost["json-value-body"]
    public func roundtripJsonValue(@FromBody payload: JsonValue): JsonValue {
        return payload
    }

    // [13] Struct DTO request/response
    // OpenAPI: requestBody / responses.200.content schema → StructDataItem（StructTypeInfo 展开）
    @HttpPost["struct-object"]
    public func roundtripStructObject(@FromBody payload: StructDataItem): StructDataItem {
        return payload
    }

    // [14] Enum response
    // OpenAPI: responses.200.content schema → { type: string, enum: ["Ready", "Failed"] }
    @HttpGet["enum-value"]
    public func returnEnumValue(): ResponseState {
        return ResponseState.Ready
    }

    // [15] JsonResult<Option<DataItem>>
    // OpenAPI: responses.200.content schema → { oneOf: [{$ref: DataItem}, {type: null}] }
    @HttpGet["json-nullable-object"]
    public func returnJsonNullableObject(): JsonResult<?DataItem> {
        let item: ?DataItem = None
        return json(item)
    }
}
