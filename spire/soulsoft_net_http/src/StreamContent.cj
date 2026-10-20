// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.io.*
import std.sync.*

/**
 * @brief 表示基于输入流的 HTTP 内容。
 */
public class StreamContent <: HttpContent {
    private let _stream: InputStream
    private let _contentConsumed = AtomicBool(false)

    /**
     * @brief 使用输入流创建 HTTP 内容。
     * @param stream 要作为内容源读取的输入流。
     */
    public init(stream: InputStream) {
        _stream = stream
    }

    protected func serializeToStream(os: OutputStream): Unit {
        prepareContent()
        let buffer = Array<Byte>(8192, repeat: 0)
        var n = _stream.read(buffer)
        while (n > 0) {
            os.write(buffer[0..n])
            n = _stream.read(buffer)
        }
    }

    /**
     * @brief 创建用于读取内容体的输入流。
     * @return 底层输入流对象。
     * @throws Exception 当流已被消费且不支持回绕时抛出。
     */
    public override func createContentReadStream(): InputStream {
        prepareContent()
        return _stream
    }

    private func prepareContent(): Unit {
        if (!_contentConsumed.compareAndSwap(false, true)) {
            if (let seekable: Seekable <- _stream) {
                seekable.seek(SeekPosition.Begin(0))
            } else {
                throw Exception(StringResx.net_http_content_stream_already_read)
            }
        }
    }

    protected func close(_: Bool) {
        if (let stream: Resource <- _stream) {
            try {
                stream.close()
            } catch (_: Exception) {
            }
        }
    }
}
