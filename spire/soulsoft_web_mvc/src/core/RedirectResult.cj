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
 * @brief 表示重定向响应结果。
 */
public class RedirectResult <: IActionResult {
    private let _url: String

    /**
     * @brief 创建重定向响应结果。
     * @param url 要跳转到的目标地址。
     */
    public init(url: String) {
        _url = url
    }

    /**
     * @brief 将重定向响应写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        context.response.statusCode = StatusCodes.Found
        context.response.headers.location = [_url]
    }
}
