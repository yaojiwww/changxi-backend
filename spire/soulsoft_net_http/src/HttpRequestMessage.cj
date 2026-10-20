// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.collection.*
import stdx.encoding.url.*

/**
 * @brief 表示一个 HTTP 请求消息。
 */
public class HttpRequestMessage {
    private var _requestUri: URL
    private let _method: HttpMethod
    private var _timeout: ?Duration = None
    private let _headers = HttpRequestHeaders()
    private let _properties = HashMap<String, Any>()

    /**
     * @brief 使用方法和字符串地址创建请求消息。
     * @param method 请求方法。
     * @param requestUri 请求地址字符串。
     */
    public init(method: HttpMethod, requestUri: String) {
        this(method, URL.parse(requestUri))
    }

    /**
     * @brief 使用方法和 URL 创建请求消息。
     * @param method 请求方法。
     * @param requestUri 请求地址。
     */
    public init(method: HttpMethod, requestUri: URL) {
        _method = method
        _requestUri = requestUri
    }

    /**
     * @brief 获取或设置请求级别的超时时间。
     * @return `None` 表示沿用客户端默认超时时间。
     */
    internal mut prop timeout: ?Duration {
        get() {
            _timeout
        }
        set(value) {
            _timeout = value
        }
    }

    /**
     * @brief 获取或设置请求内容体。
     */
    public var content: ?HttpContent = None

    /**
     * @brief 获取请求方法。
     * @return 当前请求方法。
     */
    public prop method: HttpMethod {
        get() {
            _method
        }
    }

    /**
     * @brief 获取或设置请求地址。
     */
    public mut prop requestUri: URL {
        get() {
            _requestUri
        }
        set(value) {
            _requestUri = value
        }
    }

    /**
     * @brief 获取请求头集合。
     * @return 当前请求的头集合。
     */
    public prop headers: HttpRequestHeaders {
        get() {
            _headers
        }
    }

    /**
     * @brief 获取请求属性集合。
     * @return 当前请求关联的属性字典。
     */
    public prop properties: HashMap<String, Any> {
        get() {
            _properties
        }
    }
}
