// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.formatters

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示纯文本输出格式化器。
 */
public class TextOutputFormatter <: OutputFormatter {
    /**
     * @brief 创建纯文本输出格式化器实例。
     */
    public init() {
        this.supportedMediaTypes.add("text/plain")
    }

    /**
     * @brief 检查当前格式化器是否支持指定类型。
     * @param typeInfo 要检查的结果类型。
     * @return 如果类型实现了 `ToString` 接口则返回 `true`。
     */
    public override func canWrite(typeInfo: TypeInfo): Bool {
        return typeInfo.superInterfaces |> any {f => f == TypeInfo.of<ToString>()}
    }

    /**
     * @brief 将结果按纯文本写入 HTTP 响应。
     * @param context 输出格式化上下文。
     */
    public func write(context: OutputFormatterContext): Unit {
        if (let result: ToString <- context.result) {
            context.httpContext.response.contentType = "text/plain; charset=utf-8"
            context.httpContext.response.write(result.toString())
        }
    }
}
