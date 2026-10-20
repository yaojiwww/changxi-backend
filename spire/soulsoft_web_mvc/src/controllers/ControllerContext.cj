// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.controllers

import soulsoft_web_http.*

/**
 * @brief 表示控制器执行上下文。
 */
public class ControllerContext {
    private let _httpContext: HttpContext
    private let _actionDescriptor: ControllerActionDescriptor

    /**
     * @brief 创建控制器上下文实例。
     * @param httpContext 当前请求的 HTTP 上下文。
     * @param actionDescriptor 当前执行的动作描述符。
     */
    public init(httpContext: HttpContext, actionDescriptor: ControllerActionDescriptor) {
        _httpContext = httpContext
        _actionDescriptor = actionDescriptor
    }

    /**
     * @brief 返回当前请求的 HTTP 上下文。
     * @return 当前请求的 HTTP 上下文。
     */
    public prop httpContext: HttpContext{
        get(){
            _httpContext
        }
    }

    /**
     * @brief 返回当前执行的动作描述符。
     * @return 当前动作描述符。
     */
    public prop actionDescriptor: ControllerActionDescriptor{
        get(){
            _actionDescriptor
        }
    }
}
