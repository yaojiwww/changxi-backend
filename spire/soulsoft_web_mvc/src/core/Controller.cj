// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.core

import std.io.*
import soulsoft_web_http.*

/**
 * @brief 表示 MVC 控制器基类。
 */
public abstract class Controller {
    private var _context: ?HttpContext = None

    /**
     * @brief 返回当前控制器关联的 HTTP 上下文。
     * @return 当前请求的 HTTP 上下文。
     */
    protected prop context: HttpContext {
        get() {
            _context.getOrThrow()
        }
    }

    /**
     * @brief 返回当前请求对象。
     * @return 当前请求实例。
     */
    protected prop request: HttpRequest {
        get() {
            context.request
        }
    }

    /**
     * @brief 返回当前响应对象。
     * @return 当前响应实例。
     */
    protected prop response: HttpResponse {
        get() {
            context.response
        }
    }

    /**
     * @brief 创建 200 OK 结果。
     * @return 表示 200 状态码的结果对象。
     */
    protected func ok(): StatusCodeResult {
        return StatusCodeResult(StatusCodes.Ok)
    }

    /**
     * @brief 创建携带响应对象的结果。
     * @param value 要写入响应的对象。
     * @return 包含指定对象的动作结果。
     */
    protected func ok<T>(value: T): ObjectResult<T> {
        return ObjectResult<T>(value)
    }

    /**
     * @brief 创建 202 Accepted 结果。
     * @return 表示 202 状态码的结果对象。
     */
    protected func accepted(): StatusCodeResult {
        status(StatusCodes.Accepted)
    }

    /**
     * @brief 创建 201 Created 结果。
     * @return 表示 201 状态码的结果对象。
     */
    protected func created(): StatusCodeResult {
        status(StatusCodes.Created)
    }

    /**
     * @brief 创建纯文本响应结果。
     * @param content 要写入响应的文本内容。
     * @return 文本响应结果对象。
     */
    protected func content(content: String): ContentResult {
        return ContentResult(content)
    }

    /**
     * @brief 创建指定内容类型的文本响应结果。
     * @param content 要写入响应的文本内容。
     * @param contentType 响应内容类型。
     * @return 文本响应结果对象。
     */
    protected func content(content: String, contentType: String): ContentResult {
        return ContentResult(content, contentType)
    }

    /**
     * @brief 创建 204 No Content 结果。
     * @return 表示 204 状态码的结果对象。
     */
    protected func noContent(): StatusCodeResult {
        return StatusCodeResult(StatusCodes.NoContent)
    }

    /**
     * @brief 创建指定状态码结果。
     * @param status 要返回的 HTTP 状态码。
     * @return 表示指定状态码的结果对象。
     */
    protected func status(status: UInt16): StatusCodeResult {
        return StatusCodeResult(status)
    }

    /**
     * @brief 创建 404 Not Found 结果。
     * @return 表示 404 状态码的结果对象。
     */
    protected func notFound(): StatusCodeResult {
        return StatusCodeResult(StatusCodes.NotFound)
    }

    /**
     * @brief 创建 401 Unauthorized 结果。
     * @return 表示 401 状态码的结果对象。
     */
    protected func unauthorized(): StatusCodeResult {
        return StatusCodeResult(StatusCodes.Unauthorized)
    }

    /**
     * @brief 创建 400 Bad Request 结果。
     * @return 表示 400 状态码的结果对象。
     */
    protected func badRequest(): StatusCodeResult {
        return StatusCodeResult(StatusCodes.BadRequest)
    }

    /**
     * @brief 创建重定向结果。
     * @param url 要跳转到的目标地址。
     * @return 重定向结果对象。
     */
    protected func redirect(url: String): RedirectResult {
        return RedirectResult(url)
    }

    /**
     * @brief 创建字节数组文件响应结果。
     * @param fileContents 要输出的文件字节内容。
     * @param contentType 文件响应内容类型。
     * @return 文件内容结果对象。
     */
    protected func file(fileContents: Array<Byte>, contentType: String): FileContentResult {
        return file(fileContents, contentType, None)
    }

    /**
     * @brief 创建带下载文件名的字节数组文件响应结果。
     * @param fileContents 要输出的文件字节内容。
     * @param contentType 文件响应内容类型。
     * @param fileDownloadName 下载时使用的文件名。
     * @return 文件内容结果对象。
     */
    protected func file(fileContents: Array<Byte>, contentType: String, fileDownloadName: ?String): FileContentResult {
        return FileContentResult(fileContents, contentType, fileDownloadName)
    }

    /**
     * @brief 创建流式文件响应结果。
     * @param fileStream 要输出的文件输入流。
     * @param contentType 文件响应内容类型。
     * @return 文件流结果对象。
     */
    protected func file(fileStream: InputStream, contentType: String): FileStreamResult {
        return file(fileStream, contentType, None)
    }

    /**
     * @brief 创建带下载文件名的流式文件响应结果。
     * @param fileStream 要输出的文件输入流。
     * @param contentType 文件响应内容类型。
     * @param fileDownloadName 下载时使用的文件名。
     * @return 文件流结果对象。
     */
    protected func file(fileStream: InputStream, contentType: String, fileDownloadName: ?String): FileStreamResult {
        return FileStreamResult(fileStream, contentType, fileDownloadName)
    }

    /**
     * @brief 创建 JSON 响应结果。
     * @param data 要序列化到响应中的数据。
     * @return JSON 结果对象。
     */
    protected func json<T>(data: T): JsonResult<T> {
        return JsonResult<T>(data)
    }

    /**
     * @brief 绑定当前请求上下文并返回控制器自身。
     * @param context 要绑定的 HTTP 上下文。
     * @return 已绑定上下文的控制器实例。
     */
    protected func setup(context: HttpContext): Controller {
        _context = context
        return this
    }
}
