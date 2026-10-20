// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.core

import std.collection.*
import soulsoft_serialization.*
import soulsoft_web_mvc.formatters.*
import soulsoft_web_mvc.modelBindings.*

/**
 * @brief 定义 MVC 运行时选项。
 */
public class MvcOptions  {
    /**
     * @brief 表示 JSON 序列化选项。
     */
    public var _jsonSerializerOptions = JsonSerializerOptions()
    /**
     * @brief 表示输入格式化器集合。
     */
    public var _inputFormatters: List<IInputFormatter> = ArrayList<IInputFormatter>()
    /**
     * @brief 表示输出格式化器集合。
     */
    public var _outputFormatters: List<IOutputFormatter> = ArrayList<IOutputFormatter>()
    /**
     * @brief 表示是否在没有可接受输出格式时返回 406。
     */
    public var _returnHttpNotAcceptable = false
    /**
     * @brief 表示是否尊重浏览器发送的 Accept 请求头。
     */
    public var _respectBrowserAcceptHeader = false
    /**
     * @brief 表示模型绑定器集合。
     */
    public var _modelBinders: ModelBinderCollection = ModelBinderCollection()

    /**
     * @brief 获取或修改是否尊重浏览器发送的 Accept 请求头。
     * @return 当前是否尊重浏览器 Accept 请求头。
     */
    public mut prop respectBrowserAcceptHeader: Bool {
        get() {
            _respectBrowserAcceptHeader
        }
        set(value) {
            _respectBrowserAcceptHeader = value
        }
    }

    /**
     * @brief 获取或修改是否在没有可接受输出格式时返回 406。
     * @return 当前是否返回 406 状态码。
     */
    public mut prop returnHttpNotAcceptable: Bool {
        get() {
            _returnHttpNotAcceptable
        }
        set(value) {
            _returnHttpNotAcceptable = value
        }
    }

    /**
     * @brief 获取或修改输入格式化器集合。
     * @return 当前输入格式化器集合。
     */
    public mut prop inputFormatters: List<IInputFormatter> {
        get() {
            _inputFormatters
        }
        set(value) {
            _inputFormatters = value
        }
    }

    /**
     * @brief 获取或修改输出格式化器集合。
     * @return 当前输出格式化器集合。
     */
    public mut prop outputFormatters: List<IOutputFormatter> {
        get() {
            _outputFormatters
        }
        set(value) {
            _outputFormatters = value
        }
    }

    /**
     * @brief 获取或修改 JSON 序列化选项。
     * @return 当前 JSON 序列化选项。
     */
    public mut prop jsonSerializerOptions: JsonSerializerOptions {
        get() {
            _jsonSerializerOptions
        }
        set(value) {
            _jsonSerializerOptions = value
        }
    }

    /**
     * @brief 获取或修改模型绑定器集合。
     * @return 当前模型绑定器集合。
     */
    public mut prop modelBinders: ModelBinderCollection {
        get() {
            _modelBinders
        }
        set(value) {
            _modelBinders = value
        }
    }
}
