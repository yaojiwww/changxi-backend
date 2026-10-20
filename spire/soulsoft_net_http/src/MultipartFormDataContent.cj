// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.io.*
import std.random.*
import std.collection.*

/**
 * @brief 表示 `multipart/form-data` 格式的 HTTP 内容。
 */
public class MultipartFormDataContent <: HttpContent {
    private let _boundary: String
    private let _nestedContent: ArrayList<(HttpContent, String, String)> = ArrayList()

    /**
     * @brief 创建带随机边界的多部分表单内容。
     */
    public init() {
        this("--------------------------${Random().nextUInt64()}")
    }

    /**
     * @brief 使用指定边界创建多部分表单内容。
     * @param boundary 多部分内容边界字符串。
     */
    public init(boundary: String) {
        _boundary = boundary
        headers.add(HeaderNames.ContentType, "multipart/form-data; boundary=${_boundary}")
    }

    /**
     * @brief 添加一个匿名内容分段。
     * @param content 要添加的内容对象。
     * @return 无返回值。
     */
    public func add(content: HttpContent): Unit {
        _nestedContent.add((content, String.empty, String.empty))
    }

    /**
     * @brief 添加一个带字段名的内容分段。
     * @param content 要添加的内容对象。
     * @param name 表单字段名。
     * @return 无返回值。
     */
    public func add(content: HttpContent, name: String): Unit {
        _nestedContent.add((content, name, String.empty))
    }

    /**
     * @brief 添加一个带字段名和文件名的内容分段。
     * @param content 要添加的内容对象。
     * @param name 表单字段名。
     * @param fileName 文件名。
     * @return 无返回值。
     */
    public func add(content: HttpContent, name: String, fileName: String): Unit {
        _nestedContent.add((content, name, fileName))
    }

    protected func serializeToStream(os: OutputStream): Unit {
        for ((content, name, fileName) in _nestedContent) {
            os.write("--${_boundary}\r\n".toArray())
            if (let Some(contentType) <- content.headers.getFirst("Content-Type")) {
                os.write("Content-Type: ${contentType}\r\n".toArray())
            }
            os.write("Content-Disposition: form-data".toArray())
            if (name != String.empty) {
                os.write("; name=\"${name}\"".toArray())
            }
            if (fileName != String.empty) {
                os.write("; filename=\"${fileName}\"".toArray())
            }
            os.write("\r\n\r\n".toArray())
            copyContentToStream(content, os)
            os.write("\r\n".toArray())
        }
        os.write("--${_boundary}--\r\n".toArray())
    }

    protected func close(_: Bool): Unit {
        for ((content, _, _) in _nestedContent) {
            content.close()
        }
        _nestedContent.clear()
    }

    private func copyContentToStream(content: HttpContent, os: OutputStream): Unit {
        let stream = content.readAsStream()
        let buffer = Array<Byte>(8192, repeat: 0)
        var n = stream.read(buffer)
        while (n > 0) {
            os.write(buffer[0..n])
            n = stream.read(buffer)
        }
    }
}
