// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.formatters

import std.reflect.*
import soulsoft_web_http.*
import soulsoft_web_mvc.abstractions.*

/**
 * @brief 表示输入格式化上下文。
 */
public class InputFormatterContext {
    private let _modelName: String
    private let _modelType: TypeInfo
    private let _httpContext: HttpContext
    private let _modelState: ModelStateDictionary

    /**
     * @brief 创建输入格式化上下文实例。
     * @param modelName 当前要绑定的模型名称。
     * @param modelType 当前要绑定的模型类型。
     * @param modelState 当前请求的模型状态字典。
     * @param httpContext 当前请求的 HTTP 上下文。
     */
    public init(modelName: String, modelType: TypeInfo, modelState: ModelStateDictionary, httpContext: HttpContext) {
        _modelName = modelName
        _modelType = modelType
        _modelState = modelState
        _httpContext = httpContext
    }

    /**
     * @brief 返回当前要绑定的模型名称。
     * @return 当前模型名称。
     */
    public prop modelName: String {
        get() {
            _modelName
        }
    }

    /**
     * @brief 返回当前要绑定的模型类型。
     * @return 当前模型类型信息。
     */
    public prop modelType: TypeInfo {
        get() {
            _modelType
        }
    }

    /**
     * @brief 返回当前请求的模型状态字典。
     * @return 当前模型状态字典。
     */
    public prop modelState: ModelStateDictionary {
        get() {
            _modelState
        }
    }

    /**
     * @brief 返回当前请求的 HTTP 上下文。
     * @return 当前请求的 HTTP 上下文。
     */
    public prop httpContext: HttpContext {
        get() {
            _httpContext
        }
    }
}
