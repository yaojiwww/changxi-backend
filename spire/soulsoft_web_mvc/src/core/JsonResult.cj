// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.core

import soulsoft_web_http.*
import soulsoft_extensions_options.*

/**
 * @brief 表示 JSON 响应结果。
 */
public class JsonResult<T> <: IActionResult {
    /**
     * @brief 表示要写入响应的值。
     */
    public let value: T

    /**
     * @brief 创建 JSON 响应结果。
     * @param value 要序列化到响应中的值。
     */
    public init(value: T) {
        this.value = value
    }

    /**
     * @brief 将值序列化为 JSON 并写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        let mvcOptions = context.services.getOrThrow<IOptions<MvcOptions>>()
        let jsonSerializerOptions = mvcOptions.value.jsonSerializerOptions
        context.response.writeAsJson(value, jsonSerializerOptions)
    }
}
