// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.core

import soulsoft_web_http.*

/**
 * @brief 表示仅写出状态码的动作结果。
 */
public class StatusCodeResult <: IActionResult {
    /**
     * @brief 表示要写入响应的状态码。
     */
    public let status: UInt16

    /**
     * @brief 创建状态码结果。
     * @param status 要写入响应的状态码。
     */
    public init(status: UInt16) {
        this.status = status
    }

    /**
     * @brief 将状态码写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        context.response.statusCode = this.status
    }
}
