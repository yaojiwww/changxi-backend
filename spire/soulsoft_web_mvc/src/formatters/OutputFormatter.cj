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

/**
 * @brief 定义输出格式化器基类。
 */
public abstract class OutputFormatter <: IOutputFormatter {
    protected let supportedMediaTypes = ArrayList<String>()

    /**
     * @brief 检查当前格式化器是否支持指定结果类型。
     * @param typeInfo 要检查的结果类型。
     * @return 如果当前格式化器支持该类型则返回 `true`。
     */
    public open func canWrite(typeInfo: TypeInfo): Bool {
        return true
    }

    /**
     * @brief 根据上下文检查当前格式化器是否可写。
     * @param context 包含结果类型和内容类型的写出上下文。
     * @return 如果当前格式化器可用于写出该结果则返回 `true`。
     * @throws UnsupportedException 当未配置任何支持的媒体类型时抛出。
     */
    public func canWrite(context: OutputFormatterCanWriteContext): Bool {
        if (supportedMediaTypes.size == 0) {
            let typeInfo = ClassTypeInfo.of(this)
            throw UnsupportedException(
                "No media types found in '${typeInfo}.supportedMediaTypes'. Add at least one media type to the list of supported media types.")
        }

        if (!canWrite(context.resultType)) {
            return false
        }

        if (context.contentType.isEmpty()) {
            context.contentType = supportedMediaTypes[0]
            return true
        }
        let parsedContentType = MediaType.parse(context.contentType)
        for (index in 0..supportedMediaTypes.size) {
            let supportedMediaType = MediaType.parse(supportedMediaTypes[index])
            if (supportedMediaType.hasWildcard) {
                if (context.contentTypeIsServerDefined && parsedContentType.isSubsetOf(supportedMediaType)) {
                    return true
                }
            } else {
                if (supportedMediaType.isSubsetOf(parsedContentType)) {
                    return true
                }
            }
        }
        return false
    }
}
