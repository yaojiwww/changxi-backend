// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.io.*

/**
 * @brief 表示基于字节数组的 HTTP 内容。
 */
public open class ByteArrayContent <: HttpContent {
    private let _bytes: Array<Byte>

    /**
     * @brief 使用字节数组创建 HTTP 内容。
     * @param bytes 要作为内容体发送的字节数组。
     */
    public init(bytes: Array<Byte>) {
        _bytes = bytes
    }

    protected func serializeToStream(os: OutputStream): Unit {
        os.write(_bytes)
    }
}
