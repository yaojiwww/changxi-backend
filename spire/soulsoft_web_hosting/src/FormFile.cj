// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.io.*

class FormFile <: IFormFile {
    private let _name: String

    private let _filename: ?String

    private let _contentType: String

    private let _stream: InputStream

    private let _contentDisposition: String

    private let _length: Int64

    init(name: String, filename: ?String, contentType: String, contentDisposition: String, stream: InputStream) {
        _name = name
        _stream = stream
        _filename = filename
        _contentType = contentType
        _contentDisposition = contentDisposition
        // 获取流长度，优先从 ByteBuffer 获取
        _length = if (let buffer: ByteBuffer <- stream) {
            buffer.length
        } else {
            0
        }
    }

    /**
     * @brief 返回表单字段名称。
     * @return 当前文件所属的表单字段名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回文件的内容类型。
     * @return 当前文件的内容类型。
     */
    public prop contentType: String {
        get() {
            _contentType
        }
    }

    /**
     * @brief 返回上传文件名。
     * @return 当前上传文件名；如果不存在则返回空。
     */
    public prop filename: ?String {
        get() {
            _filename
        }
    }

    /**
     * @brief 返回 Content-Disposition 头值。
     * @return 当前文件的 Content-Disposition 头值。
     */
    public prop contentDisposition: String {
        get() {
            _contentDisposition
        }
    }

    /**
     * @brief 返回文件长度。
     * @return 当前文件长度。
     */
    public prop length: Int64 {
        get() {
            _length
        }
    }

    /**
     * @brief 打开并返回文件读取流。
     * @return 可用于读取文件内容的流。
     */
    public func openReadStream(): InputStream {
        // drainStream 会在 readNextSection 中重新消费 section.body，需 seek 回起点保证可读
        if (let seekable: Seekable <- _stream) {
            seekable.seek(SeekPosition.Begin(0))
        }
        return _stream
    }
}
