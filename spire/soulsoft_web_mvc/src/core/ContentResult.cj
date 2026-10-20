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
 * @brief 表示文本内容响应结果。
 */
public class ContentResult <: IActionResult {
    private let _content: String
    private let _contentType: String
    private var _status: ?UInt16

    /**
     * @brief 创建文本内容响应结果。
     * @param content 要写入响应的文本内容。
     */
    public init(content: String) {
        _content = content
        _status = None
        _contentType = "text/plain; charset=utf-8"
    }

    /**
     * @brief 创建带状态码的文本内容响应结果。
     * @param content 要写入响应的文本内容。
     * @param status 响应状态码。
     */
    public init(content: String, status: UInt16) {
        _content = content
        _status = status
        _contentType = "text/plain; charset=utf-8"
    }

    /**
     * @brief 创建带内容类型的文本内容响应结果。
     * @param content 要写入响应的文本内容。
     * @param contentType 响应内容类型。
     */
    public init(content: String, contentType: String) {
        _content = content
        _status = None
        _contentType = contentType
    }

    /**
     * @brief 创建带内容类型和状态码的文本内容响应结果。
     * @param content 要写入响应的文本内容。
     * @param contentType 响应内容类型。
     * @param status 响应状态码。
     */
    public init(content: String, contentType: String, status: UInt16) {
        _content = content
        _status = status
        _contentType = contentType
    }

    /**
     * @brief 将文本内容写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        context.response.contentType = _contentType
        if (_content.size == 0) {
            context.response.statusCode = StatusCodes.NoContent
        } else {
            context.response.statusCode = (this._status ?? StatusCodes.Ok)
            context.response.write(_content)
        }
    }
}
