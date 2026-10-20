// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.formatters

import soulsoft_web_http.*

/**
 * @brief 表示输出格式化上下文。
 */
public class OutputFormatterContext <: OutputFormatterCanWriteContext {
    /**
     * @brief 创建输出格式化上下文实例。
     * @param result 待写出的结果对象。
     * @param httpContext 当前请求的 HTTP 上下文。
     */
    public init(result: Any, httpContext: HttpContext) {
        super(result, httpContext)
    }
}
