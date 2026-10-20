// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http


/**
 * @brief 表示基于字符串的 HTTP 内容。
 */
public class StringContent <: ByteArrayContent {

    /**
     * @brief 使用字符串创建纯文本内容。
     * @param content 要发送的字符串内容。
     */
    public init(content: String) {
        this(content, "text/plain", "utf-8")
    }

    /**
     * @brief 使用字符串和媒体类型创建内容。
     * @param content 要发送的字符串内容。
     * @param mediaType 内容的媒体类型。
     */
    public init(content: String, mediaType: String) {
        this(content, mediaType, "utf-8")
    }

    /**
     * @brief 使用字符串、媒体类型和编码创建内容。
     * @param content 要发送的字符串内容。
     * @param mediaType 内容的媒体类型。
     * @param encoding 内容的字符编码名称。
     */
    public init(content: String, mediaType: String, encoding: String) {
        super(content.toArray())
        headers.add(HeaderNames.ContentType, "${mediaType}; charset=${encoding}")
    }
}
