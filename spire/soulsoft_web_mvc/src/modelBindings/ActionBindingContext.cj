// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*
import soulsoft_web_http.*
import soulsoft_web_mvc.abstractions.*

/**
 * @brief 表示控制器动作级别的绑定上下文。
 */
public class ActionBindingContext {
    private let _httpContext: HttpContext
    private let _parameters: Collection<ParameterInfo>
    private var _modelState: ?ModelStateDictionary = None

    /**
     * @brief 创建动作绑定上下文实例。
     * @param httpContext 当前请求的 HTTP 上下文。
     * @param parameters 当前动作的参数列表。
     */
    public init(httpContext: HttpContext, parameters: Collection<ParameterInfo>) {
        _httpContext = httpContext
        _parameters = parameters
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

    /**
     * @brief 返回当前请求的模型状态字典。
     * @return 当前动作绑定使用的模型状态字典。
     */
    public prop modelState: ModelStateDictionary {
        get() {
            if (_modelState.isNone()) {
                _modelState = ModelStateDictionary()
            }
            _modelState.getOrThrow()
        }
    }

    /**
     * @brief 返回当前动作的参数列表。
     * @return 当前动作的参数集合。
     */
    public prop parameters: Collection<ParameterInfo> {
        get() {
            _parameters
        }
    }
}
