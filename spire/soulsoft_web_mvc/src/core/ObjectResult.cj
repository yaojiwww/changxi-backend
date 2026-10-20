// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.core

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_mvc.formatters.*

let DefaultContentTypes = ArrayList<String>(["application/json"])
let DefaultFormatters = ArrayList<IOutputFormatter>(0)

/**
 * @brief 表示由输出格式化器写出的对象响应结果。
 */
public class ObjectResult<T> <: ActionResult<T> {
    /**
     * @brief 创建对象响应结果。
     * @param value 要写入响应的对象值。
     */
    public init(value: T) {
        super(value)
    }

    /**
     * @brief 使用输出格式化器将对象写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        let selector = context.services.getOrThrow<OutputFormatterSelector>()
        let outputFormatterContext = OutputFormatterContext(this.value, context)
        let selectedFormatter = selector.selectFormatter(outputFormatterContext, DefaultFormatters, DefaultContentTypes)
        if (let Some(formatter) <- selectedFormatter) {
            formatter.write(outputFormatterContext)
        } else {
            context.response.statusCode = StatusCodes.NotAcceptable
        }
    }
}
