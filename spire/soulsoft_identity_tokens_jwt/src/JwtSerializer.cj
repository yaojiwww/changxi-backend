// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import std.time.*
import std.collection.*
import std.math.numeric.*
import stdx.encoding.json.*
import stdx.serialization.serialization.*

/**
 * @brief 提供 JWT 内容与 JSON 字符串之间的序列化和反序列化能力。
 */
public class JwtSerializer {

    /**
     * @brief 将 JSON 字符串反序列化为键值映射。
     * @param str 要解析的 JSON 字符串。
     * @return 解析得到的 JWT 内容键值映射。
     * @throws IllegalArgumentException 当 JSON 字符串无法反序列化时抛出。
     */
    public static func deserialize(str: String): HashMap<String, Any> {
        try {
            let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
            return toHashMap(dataModel)
        } catch (e: Exception) {
            throw IllegalArgumentException("Failed to deserialize JSON: ${e.message}")
        }
    }

    /**
     * @brief 将键值映射序列化为 JSON 字符串。
     * @param hashMap 要序列化的键值映射。
     * @return 序列化后的 JSON 字符串。
     */
    public static func serialize(hashMap: HashMap<String, Any>): String {
        let dataModelStruct = DataModelStruct()
        for ((key, value) in hashMap) {
            if (let data: ArrayList<Any> <- value) {
                let sequence = DataModelSeq()
                for (item in data) {
                    if (let Some(dataModel) <- toDataModel(item)) {
                        sequence.add(dataModel)
                    }
                }
                dataModelStruct.add(Field(key, sequence))
            } else {
                if (let Some(dataModel) <- toDataModel(value)) {
                    dataModelStruct.add(Field(key, dataModel))
                }
            }
        }
        return dataModelStruct.toJson().toJsonString()
    }

    /**
     * 将任意类型的值转换为 DataModel。
     *
     * 支持的类型见类文档注释。不支持的类型返回 None。
     *
     * @param value 待转换的值
     * @return DataModel 或 None（不支持的类型）
     */
    private static func toDataModel(value: Any): ?DataModel {
        if (let data: String <- value) {
            return data.serialize()
        } else if (let data: Bool <- value) {
            return data.serialize()
        } else if (let data: Int8 <- value) {
            return data.serialize()
        } else if (let data: Int16 <- value) {
            return data.serialize()
        } else if (let data: Int32 <- value) {
            return data.serialize()
        } else if (let data: Int64 <- value) {
            return data.serialize()
        } else if (let data: UInt8 <- value) {
            return data.serialize()
        } else if (let data: UInt16 <- value) {
            return data.serialize()
        } else if (let data: UInt32 <- value) {
            return data.serialize()
        } else if (let data: UInt64 <- value) {
            return data.serialize()
        } else if (let data: Float16 <- value) {
            return data.serialize()
        } else if (let data: Float32 <- value) {
            return data.serialize()
        } else if (let data: Float64 <- value) {
            return data.serialize()
        } else if (let data: BigInt <- value) {
            return data.toString().serialize()
        } else if (let data: Decimal <- value) {
            return data.toString().serialize()
        } else if (let data: DateTime <- value) {
            return data.toString().serialize()
        }
        // 不支持的类型返回 None
        return None
    }

    /**
     * 将 DataModel 转换为 HashMap。
     *
     * @param dataModel 待转换的 DataModel
     * @return 转换后的 HashMap
     */
    private static func toHashMap(dataModel: DataModel): HashMap<String, Any> {
        let data = HashMap<String, Any>()
        match (dataModel) {
            case dataModelStruct: DataModelStruct => 
            for (field in dataModelStruct.getFields()) {
                match (field.getData()) {
                    case sequence: DataModelSeq =>
                        let values = ArrayList<Any>(sequence.getItems().size)
                        for (item in sequence.getItems()) {
                            if (let Some(value) <- parseDataModel(item)) {
                                values.add(value)
                            }
                        }
                        data.add(field.getName(), values)
                    case fieldData =>
                        if (let Some(value) <- parseDataModel(fieldData)) {
                            data.add(field.getName(), value)
                        }
                }
            }
            case _ => ()
        }
        return data
    }

    /**
     * 解析 DataModel 为具体的值类型。
     *
     * @param dataModel 待解析的 DataModel
     * @return 解析后的值或 None
     */
    private static func parseDataModel(dataModel: DataModel): ?Any {
        match (dataModel) {
            case data: DataModelInt => data.getValue()
            case data: DataModelBool => data.getValue()
            case data: DataModelString => data.getValue()
            case data: DataModelFloat => data.getValue()
            case _ => None
        }
    }
}
