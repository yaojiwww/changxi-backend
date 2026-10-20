// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.sync.*
import stdx.net.http.HttpResponse

/**
 * @brief 表示一个 HTTP 响应消息。
 */
public class HttpResponseMessage <: Resource {
    private var _content: HttpContent
    private let _response: HttpResponse
    private let _request: HttpRequestMessage
    private let _headers: HttpResponseHeaders
    private let _isClosed = AtomicBool(false)

    init(request: HttpRequestMessage, response: HttpResponse) {
        _request = request
        _response = response
        _content = StreamContent(response.body)
        _headers = HttpResponseHeaders(response.headers)
    }

    /**
     * @brief 获取响应状态码。
     * @return 当前响应的数值状态码。
     */
    public prop statusCode: Int64 {
        get() {
            Int64(_response.status)
        }
    }

    /**
     * @brief 获取响应头集合。
     * @return 当前响应的头集合。
     */
    public prop headers: HttpResponseHeaders {
        get() {
            _headers
        }
    }

    /**
     * @brief 获取或设置响应内容体。
     */
    public mut prop content: HttpContent {
        get() {
            _content
        }
        set(value) {
            _content = value
        }
    }

    /**
     * @brief 获取关联的请求消息。
     * @return 生成当前响应的请求对象。
     */
    public prop request: HttpRequestMessage {
        get() {
            _request
        }
    }

    /**
     * @brief 检查状态码是否表示成功。
     * @return 状态码位于 2xx 区间时返回 `true`。
     */
    public prop isSuccessStatusCode: Bool {
        get() {
            statusCode >= 200 && statusCode <= 299
        }
    }

    /**
     * @brief 确保响应状态码表示成功。
     * @return 无返回值。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     */
    public func ensureSuccessStatusCode(): Unit {
        if (!isSuccessStatusCode) {
            let errorMessage = "Request failed with status code: ${statusCode}"
            throw HttpRequestException(errorMessage, None)
        }
    }

    /**
     * @brief 关闭当前响应及其底层资源。
     * @return 无返回值。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            try {
                content.close(true)
            } catch (_: Exception) {
            }
            try {
                _response.close()
            } catch (_: Exception) {
            }
        }
    }

    /**
     * @brief 检查当前响应是否已关闭。
     * @return 已关闭时返回 `true`。
     */
    public func isClosed(): Bool {
        _isClosed.load()
    }
}
