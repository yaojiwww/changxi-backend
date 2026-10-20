// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.utilities

import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示一个 multipart 分段。
 */
public class MultipartSection {
    /**
     * @brief 表示当前分段的正文流。
     */
    public let body: MultipartReaderStream
    /**
     * @brief 表示当前分段的头集合。
     */
    public let headers: HashMap<String, StringValues>
    /**
     * @brief 返回当前分段在底层流中的起始偏移。
     * @return 当前分段在底层流中的起始偏移；无法定位时返回空。
     */
    public let baseStreamOffset: ?Int64

    /**
     * @brief 创建一个 multipart 分段对象。
     * @param body 当前分段的内容流。
     * @param headers 当前分段的头集合。
     * @param baseStreamOffset 当前分段在底层流中的起始偏移。
     */
    protected init(body: MultipartReaderStream, headers: HashMap<String, StringValues>, baseStreamOffset: ?Int64) {
        this.body = body
        this.headers = headers
        this.baseStreamOffset = baseStreamOffset
    }

    /**
     * @brief 返回当前分段的 Content-Type 标头值。
     * @return 当前分段的 Content-Type 标头值；不存在时返回空。
     */
    public prop contentType: ?String {
        get() {
            headers.get(HeaderNames.ContentType).flatMap {f => f.first}
        }
    }

    /**
     * @brief 返回当前分段的 Content-Disposition 标头值。
     * @return 当前分段的 Content-Disposition 标头值；不存在时返回空。
     */
    public prop contentDisposition: ?String {
        get() {
            headers.get(HeaderNames.ContentDisposition).flatMap {f => f.first}
        }
    }
}
