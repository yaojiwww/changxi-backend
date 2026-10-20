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

/**
 * @brief 表示输出格式化器写出检查上下文。
 */
public open class OutputFormatterCanWriteContext {
    /**
     * @brief 表示待写出的结果对象。
     */
    public let result: Any
    /**
     * @brief 表示待写出结果的类型信息。
     */
    public let resultType: TypeInfo
    /**
     * @brief 表示当前请求的 HTTP 上下文。
     */
    public let httpContext: HttpContext
    /**
     * @brief 表示当前协商得到的内容类型。
     */
    public var contentType = String.empty
    /**
     * @brief 表示当前内容类型是否由服务端预先指定。
     */
    public var contentTypeIsServerDefined = false

    /**
     * @brief 创建输出格式化器写出检查上下文。
     * @param result 待写出的结果对象。
     * @param httpContext 当前请求的 HTTP 上下文。
     */
    public init(result: Any, httpContext: HttpContext) {
        this.result = result
        this.resultType = TypeInfo.of(result)
        this.httpContext = httpContext
    }
}
