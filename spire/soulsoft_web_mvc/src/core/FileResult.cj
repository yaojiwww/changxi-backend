// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.core

/**
 * @brief 表示文件响应结果基类。
 */
public abstract class FileResult <: IActionResult {
    private let _contentType: String
    private let _fileDownloadName: ?String

    /**
     * @brief 创建文件响应结果基类实例。
     * @param contentType 文件响应内容类型。
     * @param fileDownloadName 下载时使用的文件名。
     */
    public init(contentType: String, fileDownloadName: ?String) {
        _contentType = contentType
        _fileDownloadName = fileDownloadName
    }

    /**
     * @brief 返回文件响应内容类型。
     * @return 当前文件响应的内容类型。
     */
    public prop contentType: String {
        get() {
            _contentType
        }
    }

    /**
     * @brief 返回下载时使用的文件名。
     * @return 当前文件响应的下载文件名；如果未设置则返回 `None`。
     */
    public prop fileDownloadName: ?String {
        get() {
            _fileDownloadName
        }
    }
}
