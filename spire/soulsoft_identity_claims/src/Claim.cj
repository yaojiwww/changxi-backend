// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_claims

import stdx.serialization.serialization.*

/**
 * @brief 表示单条声明信息。
 */
public class Claim <: Serializable<Claim> & ToString {
    private let _type: String
    private let _value: String
    private let _valueType: String

    /**
     * @brief 创建字符串值类型的声明。
     * @param type 声明类型。
     * @param value 声明值。
     */
    public init(`type`: String, value: String) {
        this(`type`, value, ClaimValueTypes.String)
    }

    /**
     * @brief 创建指定值类型的声明。
     * @param type 声明类型。
     * @param value 声明值。
     * @param valueType 声明值类型。
     */
    public init(`type`: String, value: String, valueType: String) {
        _type = `type`
        _value = value
        _valueType = valueType
    }

    /**
     * @brief 返回声明类型。
     * @return 返回声明类型。
     */
    public prop `type`: String {
        get() {
            _type
        }
    }

    /**
     * @brief 返回声明值。
     * @return 返回声明值。
     */
    public prop value: String {
        get() {
            _value
        }
    }

    /**
     * @brief 返回声明值类型。
     * @return 返回声明值类型。
     */
    public prop valueType: String {
        get() {
            _valueType
        }
    }

    /**
     * @brief 将当前声明序列化为数据模型。
     * @return 返回声明对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("type", _type))
        dms.add(field("value", _value))
        dms.add(field("valueType", _valueType))
        return dms
    }

    /**
     * @brief 从数据模型反序列化声明。
     * @param dm 声明对应的数据模型。
     * @return 返回反序列化后的声明。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): Claim {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("The data is not DataModelStruct.")
        }
        let `type` = String.deserialize(dms.get("type"))
        let value = String.deserialize(dms.get("value"))
        let valueType = String.deserialize(dms.get("valueType"))
        return Claim(`type`, value, valueType)
    }

    /**
     * @brief 返回声明的字符串表示。
     * @return 返回格式化后的声明字符串。
     */
    public func toString(): String {
        '${`type`} = ${value} [${valueType}]'
    }
}
