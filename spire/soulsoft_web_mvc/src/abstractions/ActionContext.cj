// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.abstractions

import soulsoft_web_http.*

/**
 * @brief 表示一次动作执行的上下文信息。
 */
public class ActionContext {
    /**
     * @brief 返回当前请求的 HTTP 上下文。
     * @return 当前请求的 HTTP 上下文。
     */
    public let httpContext: HttpContext
    /**
     * @brief 返回当前请求的模型状态字典。
     * @return 当前请求的模型状态字典。
     */
    public let modelState: ModelStateDictionary

    /**
     * @brief 创建动作上下文实例。
     * @param httpContext 当前请求的 HTTP 上下文。
     * @param modelState 当前请求的模型状态字典。
     */
    public init(httpContext: HttpContext, modelState: ModelStateDictionary) {
        this.httpContext = httpContext
        this.modelState = modelState
    }
}
