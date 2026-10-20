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
 * @brief 表示基于输入流的文件响应结果。
 */
public class FileStreamResult <: FileResult {
    private let _fileStream: InputStream

    /**
     * @brief 创建文件流响应结果。
     * @param fileStream 要输出的文件输入流。
     * @param contentType 文件响应内容类型。
     * @param fileDownloadName 下载时使用的文件名。
     */
    public init(fileStream: InputStream, contentType: String, fileDownloadName: ?String) {
        super(contentType, fileDownloadName)
        _fileStream = fileStream
    }

    /**
     * @brief 返回文件输入流。
     * @return 当前响应要输出的文件输入流。
     */
    public prop fileStream: InputStream {
        get() {
            _fileStream
        }
    }

    /**
     * @brief 将文件流内容写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        context.response.contentType = contentType
        if (let Some(fileDownloadName) <- fileDownloadName) {
            let encodedFileName = HttpUtility.urlEncode(fileDownloadName)
            let contentDisposition = "attachment; filename=\"${fileDownloadName}\"; filename*=UTF-8''${encodedFileName}"
            context.response.headers.contentDisposition = [contentDisposition]
        }
        try {
            let buffer = if (let s: Seekable <- _fileStream) {
                ByteBuffer(s.length)
            } else {
                ByteBuffer()
            }
            copy(_fileStream, to: buffer)
            context.response.write(buffer.bytes())
        } finally {
            if (let rs: Resource <- _fileStream) {
                rs.close()
            }
        }
    }
}
