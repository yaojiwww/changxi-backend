// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.io.*

/**
 * @brief 定义上传表单文件的抽象。
 */
public interface IFormFile {
    /**
     * @brief 返回表单字段名称。
     * @return 当前文件所属的表单字段名称。
     */
    prop name: String
    /**
     * @brief 返回文件长度。
     * @return 当前文件长度。
     */
    prop length: Int64
    /**
     * @brief 返回上传文件名。
     * @return 当前上传文件名；如果不存在则返回空。
     */
    prop filename: ?String
    /**
     * @brief 返回文件内容类型。
     * @return 当前文件内容类型。
     */
    prop contentType: String
    /**
     * @brief 返回 Content-Disposition 头值。
     * @return 当前文件的 Content-Disposition 头值。
     */
    prop contentDisposition: String
    /**
     * @brief 打开并返回文件读取流。
     * @return 可用于读取文件内容的流。
     */
    func openReadStream(): InputStream
}
