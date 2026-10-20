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
 * @brief 表示基于字节数组的文件响应结果。
 */
public class FileContentResult <: FileResult {
    private let _fileContents: Array<Byte>

    /**
     * @brief 创建字节数组文件响应结果。
     * @param fileContents 要输出的文件字节内容。
     * @param contentType 文件响应内容类型。
     * @param fileDownloadName 下载时使用的文件名。
     */
    public init(fileContents: Array<Byte>, contentType: String, fileDownloadName: ?String) {
        super(contentType, fileDownloadName)
        _fileContents = fileContents
    }

    /**
     * @brief 返回文件字节内容。
     * @return 当前响应要输出的文件字节数组。
     */
    public prop fileContents: Array<Byte> {
        get() {
            _fileContents
        }
    }

    /**
     * @brief 将文件字节内容写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit {
        context.response.headers.contentType = [contentType]
        if (let Some(fileDownloadName) <- fileDownloadName) {
            let encodedFileName = HttpUtility.urlEncode(fileDownloadName)
            let contentDisposition = "attachment; filename=\"${fileDownloadName}\"; filename*=UTF-8''${encodedFileName}"
            context.response.headers.contentDisposition = [contentDisposition]
        }
        context.response.write(fileContents)
    }
}
