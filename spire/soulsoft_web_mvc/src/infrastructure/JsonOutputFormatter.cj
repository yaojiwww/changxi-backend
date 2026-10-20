// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import soulsoft_web_http.*
import soulsoft_web_mvc.core.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.formatters.*

/**
 * @brief 表示 JSON 输出格式化器。
 */
public class JsonOutputFormatter <: OutputFormatter {
    /**
     * @brief 创建 JSON 输出格式化器实例。
     */
    public init() {
        this.supportedMediaTypes.add("application/json")
        this.supportedMediaTypes.add("text/json")
        this.supportedMediaTypes.add("application/*+json")
    }

    /**
     * @brief 将结果序列化为 JSON 并写入 HTTP 响应。
     * @param context 输出格式化上下文。
     */
    public func write(context: OutputFormatterContext): Unit {
        let options = context.httpContext.services.getOrThrow<IOptions<MvcOptions>>().value
        context.httpContext.response.writeAsJson(context.result, options.jsonSerializerOptions)
    }
}
