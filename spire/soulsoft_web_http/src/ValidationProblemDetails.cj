// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*
import stdx.serialization.serialization.*

/**
 * @brief 表示请求验证失败的详细信息。
 */
public open class ValidationProblemDetails <: Serializable<ValidationProblemDetails> {
    private var _type: ?String = None
    private var _title: ?String = None
    private var _status: ?UInt16 = None
    private var _detail: ?String = None
    private var _instance: ?String = None
    private var _errors = HashMap<String, Array<String>>()

    /**
     * @brief 创建一个空的验证问题详情实例。
     */
    public init() {}

    /**
     * @brief 获取或修改问题类型标识。
     * @return 当前问题类型标识；未设置时返回空。
     */
    public mut prop `type`: ?String {
        get() {
            _type
        }
        set(value) {
            _type = value
        }
    }

    /**
     * @brief 获取或修改问题标题。
     * @return 当前问题标题；未设置时返回空。
     */
    public mut prop title: ?String {
        get() {
            _title
        }
        set(value) {
            _title = value
        }
    }

    /**
     * @brief 获取或修改问题状态码。
     * @return 当前问题状态码；未设置时返回空。
     */
    public mut prop status: ?UInt16 {
        get() {
            _status
        }
        set(value) {
            _status = value
        }
    }

    /**
     * @brief 获取或修改问题详细描述。
     * @return 当前问题详细描述；未设置时返回空。
     */
    public mut prop detail: ?String {
        get() {
            _detail
        }
        set(value) {
            _detail = value
        }
    }

    /**
     * @brief 获取或修改问题实例标识。
     * @return 当前问题实例标识；未设置时返回空。
     */
    public mut prop instance: ?String {
        get() {
            _instance
        }
        set(value) {
            _instance = value
        }
    }

    /**
     * @brief 获取或修改字段验证错误集合。
     * @return 当前字段验证错误集合。
     */
    public mut prop errors: HashMap<String, Array<String>> {
        get() {
            _errors
        }
        set(value) {
            _errors = value
        }
    }

    /**
     * @brief 将当前验证问题详情序列化为数据模型。
     * @return 序列化后的数据模型。
     */
    public open func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        if (let Some(value) <- `type`) {
            dms.add(Field("type", value.serialize()))
        } else {
            dms.add(Field("type", DataModelNull()))
        }

        if (let Some(value) <- title) {
            dms.add(Field("title", value.serialize()))
        }

        if (let Some(value) <- status) {
            dms.add(Field("status", value.serialize()))
        }

        if (let Some(value) <- detail) {
            dms.add(Field("detail", value.serialize()))
        }

        if (let Some(value) <- instance) {
            dms.add(Field("instance", value.serialize()))
        }

        if (_errors.size > 0) {
            dms.add(Field("errors", _errors.serialize()))
        }
        return dms
    }

    /**
     * @brief 从数据模型反序列化验证问题详情。
     * @param dm 要反序列化的数据模型。
     * @return 反序列化后的验证问题详情实例。
     * @throws DataModelException 当数据模型不是结构体时抛出。
     */
    public static func deserialize(dm: DataModel): ValidationProblemDetails {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelStruct.")
        }

        let data = ValidationProblemDetails()

        if (let value: DataModelString <- dms.get("type")) {
            data.`type` = String.deserialize(value)
        }

        if (let value: DataModelString <- dms.get("title")) {
            data.title = String.deserialize(value)
        }

        if (let value: DataModelInt <- dms.get("status")) {
            data.status = UInt16.deserialize(value)
        }

        if (let value: DataModelString <- dms.get("detail")) {
            data.detail = String.deserialize(value)
        }

        if (let value: DataModelString <- dms.get("instance")) {
            data.instance = String.deserialize(value)
        }

        if (let value: DataModelStruct <- dms.get("errors")) {
            data.errors = HashMap<String, Array<String>>.deserialize(value)
        }
        return data
    }
}
