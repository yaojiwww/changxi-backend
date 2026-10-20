// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import std.sort.*
import std.unicode.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_mvc.core.*
import soulsoft_web_mvc.formatters.*
import soulsoft_extensions_options.*

protected class DefaultOutputFormatterSelector <: OutputFormatterSelector {
    private let _options: MvcOptions

    public init(options: IOptions<MvcOptions>) {
        _options = options.value
    }

    public func selectFormatter(context: OutputFormatterCanWriteContext, formatters: List<IOutputFormatter>,
        contentTypes: List<String>): ?IOutputFormatter {
        let selectedFormatters = if (!formatters.isEmpty()) {
            formatters
        } else {
            _options.outputFormatters
        }
        if (selectedFormatters.size == 0) {
            throw UnsupportedException(
                "'MvcOptions.outputFormatters' must not be empty. At least one 'IOutputFormatter' is required to format a response.")
        }
        var selectedFormatter: ?IOutputFormatter = None

        // 解析Accept头并排序
        let acceptableMediaTypes = getAcceptableMediaTypes(context.httpContext.request)

        var selectFormatterWithoutRegardingAcceptHeader = false

        if (acceptableMediaTypes.size == 0) {
            selectFormatterWithoutRegardingAcceptHeader = true
        } else {
            if (contentTypes.size == 0) {
                selectedFormatter = selectFormatterUsingSortedAcceptHeaders(context, selectedFormatters,
                    acceptableMediaTypes)
            } else {
                selectedFormatter = selectFormatterUsingSortedAcceptHeadersAndContentTypes(context, selectedFormatters,
                    acceptableMediaTypes, contentTypes)
            }

            if (selectedFormatter.isNone()) {
                // 是否响应406
                if (!_options.returnHttpNotAcceptable) {
                    selectFormatterWithoutRegardingAcceptHeader = true
                }
            }
        }

        // 如果不允许返回406，那么根据默认的contentType作为协议内容，重新查找
        if (selectFormatterWithoutRegardingAcceptHeader) {
            if (contentTypes.size == 0) {
                selectedFormatter = selectFormatterNotUsingContentType(context, selectedFormatters)
            } else {
                selectedFormatter = selectFormatterUsingAnyAcceptableContentType(context, selectedFormatters,
                    contentTypes)
            }
        }

        return selectedFormatter
    }

    private func selectFormatterUsingSortedAcceptHeaders(context: OutputFormatterCanWriteContext,
        formatters: List<IOutputFormatter>, sortedAcceptHeaders: List<MediaType>): ?IOutputFormatter {
        for (index in 0..sortedAcceptHeaders.size) {
            context.contentType = sortedAcceptHeaders[index].value
            context.contentTypeIsServerDefined = false
            for (index in 0..formatters.size) {
                let formatter = formatters[index]
                if (formatter.canWrite(context)) {
                    return formatter
                }
            }
        }

        return None
    }

    private func selectFormatterUsingSortedAcceptHeadersAndContentTypes(context: OutputFormatterCanWriteContext,
        formatters: List<IOutputFormatter>, sortedAcceptableContentTypes: List<MediaType>,
        possibleOutputContentTypes: List<String>): ?IOutputFormatter {
        for (index in 0..sortedAcceptableContentTypes.size) {
            let acceptableContentType = sortedAcceptableContentTypes[index]

            for (index in 0..possibleOutputContentTypes.size) {
                let candidateContentType = MediaType.parse(possibleOutputContentTypes[index])
                // 请求的内容类型必须适配默认的内容类型
                if (candidateContentType.isSubsetOf(acceptableContentType)) {
                    for (index in 0..formatters.size) {
                        let formatter = formatters[index]
                        context.contentType = candidateContentType.value
                        context.contentTypeIsServerDefined = true
                        if (formatter.canWrite(context)) {
                            return formatter
                        }
                    }
                }
            }
        }

        return None
    }

    private func selectFormatterNotUsingContentType(context: OutputFormatterCanWriteContext,
        formatters: List<IOutputFormatter>): ?IOutputFormatter {
        for (index in 0..formatters.size) {
            let formatter = formatters[index]

            context.contentType = String.empty
            context.contentTypeIsServerDefined = false

            if (formatter.canWrite(context)) {
                return formatter
            }
        }

        return None
    }

    private func selectFormatterUsingAnyAcceptableContentType(context: OutputFormatterCanWriteContext,
        formatters: List<IOutputFormatter>, acceptableContentTypes: List<String>): ?IOutputFormatter {
        for (index in 0..formatters.size) {
            let formatter = formatters[index]
            for (index in 0..acceptableContentTypes.size) {
                context.contentType = acceptableContentTypes[index]
                context.contentTypeIsServerDefined = true
                if (formatter.canWrite(context)) {
                    return formatter
                }
            }
        }

        return None
    }

    private func getAcceptableMediaTypes(request: HttpRequest) {
        let acceptValues = request.headers.getCommaSeparatedValues(HeaderNames.Accept)
        let result = ArrayList<MediaType>(acceptValues.size)
        for (index in 0..acceptValues.size) {
            // RFC 7230 §3.2.6: OWS (optional whitespace) is allowed around comma-separated items
            let mediaType = MediaType.parse(acceptValues[index].trim())
            if (!_options.respectBrowserAcceptHeader && mediaType.matchesAllSubTypes && mediaType.matchesAllTypes) {
                result.clear()
                return result
            }
            result.add(mediaType)
        }

        sort(result, key: {k => k.quality}, descending: true)

        return result
    }
}
