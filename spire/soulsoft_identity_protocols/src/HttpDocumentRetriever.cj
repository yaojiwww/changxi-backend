// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

import stdx.encoding.url.*
import soulsoft_net_http.*

/**
 * @brief 提供基于 HTTP 的文档读取实现。
 */
public class HttpDocumentRetriever <: IDocumentRetriever {
    private let _requireHttps: Bool
    private let _httpClient: ?HttpClient
    private static let _defaultHttpClient = HttpClient()

    /**
     * @brief 创建使用默认 HTTP 客户端的文档读取器。
     * @param requireHttps 指示是否强制要求 HTTPS 地址。
     */
    public init(requireHttps!: Bool = true) {
        _httpClient = None
        _requireHttps = requireHttps
    }

    /**
     * @brief 创建使用指定 HTTP 客户端的文档读取器。
     * @param httpClient 用于发送请求的 HTTP 客户端。
     * @param requireHttps 指示是否强制要求 HTTPS 地址。
     */
    public init(httpClient: HttpClient, requireHttps!: Bool = true) {
        _httpClient = httpClient
        _requireHttps = requireHttps
    }

    /**
     * @brief 读取指定地址的文档内容。
     * @param address 文档地址。
     * @return 返回响应中的文档字符串。
     * @throws IllegalArgumentException 当启用 HTTPS 限制且地址不是 HTTPS 时抛出。
     */
    public func getDocument(address: String): String {
        if (_requireHttps && !Utility.isHttps(address)) {
            throw IllegalArgumentException(
                "The address specified '${address}' is not valid as per HTTPS scheme. Please specify an https address for security reasons. If you want to test with http address, set the RequireHttps property on IDocumentRetriever to false.")
        }
        let httpClient = getHttpClient()
        let response = httpClient.get(URL.parse(address))
        response.ensureSuccessStatusCode()
        return response.content.readAsString()
    }

    private func getHttpClient() {
        if (let Some(httpClient) <- _httpClient) {
            return httpClient
        }
        return _defaultHttpClient
    }

    /**
     * @brief 返回当前是否强制要求 HTTPS 地址。
     * @return 如果当前读取器强制要求 HTTPS 地址则返回 true，否则返回 false。
     */
    public prop requireHttps: Bool {
        get() {
            _requireHttps
        }
    }
}
