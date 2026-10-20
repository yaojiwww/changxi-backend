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
import stdx.net.http.*
import stdx.encoding.url.*

/**
 * @brief 提供便捷 HTTP 请求发送能力的客户端。
 */
public class HttpClient <: HttpMessageInvoker {
    private static let defaultTimeout = Duration.second * 100
    private var _timeout: Duration = defaultTimeout
    private var _baseAddress: ?URL = None
    private let _operationStarted = AtomicBool(false)
    private var _defaultRequestHeaders: ?HttpRequestHeaders = None

    /**
     * @brief 创建使用默认处理器的 HTTP 客户端。
     */
    public init() {
        this(HttpClientHandler())
    }

    /**
     * @brief 使用指定消息处理器创建 HTTP 客户端。
     * @param handler 用于发送请求的消息处理器。
     */
    public init(handler: HttpMessageHandler) {
        super(handler)
    }

    /**
     * @brief 使用指定消息处理器和关闭策略创建 HTTP 客户端。
     * @param handler 用于发送请求的消息处理器。
     * @param closeHandler 关闭客户端时是否同步关闭处理器。
     */
    public init(handler: HttpMessageHandler, closeHandler: Bool) {
        super(handler, closeHandler)
    }

    /**
     * @brief 获取或设置基础地址。
     * @throws ObjectDisposedException 当当前客户端已关闭时抛出。
     * @throws UnsupportedException 当客户端已经开始发送请求后再修改基础地址时抛出。
     */
    public mut prop baseAddress: ?URL {
        get() {
            _baseAddress
        }
        set(value) {
            checkClosedOrStarted()
            _baseAddress = value
        }
    }

    /**
     * @brief 获取或设置请求超时时间。
     * @throws ObjectDisposedException 当当前客户端已关闭时抛出。
     * @throws UnsupportedException 当客户端已经开始发送请求后再修改超时时间时抛出。
     */
    public mut prop timeout: Duration {
        get() {
            _timeout
        }
        set(value) {
            checkClosedOrStarted()
            _timeout = value
        }
    }

    /**
     * @brief 获取默认请求头集合。
     * @return 客户端级别的默认请求头集合。
     */
    public prop defaultRequestHeaders: HttpRequestHeaders {
        get() {
            if (let Some(defaultRequestHeaders) <- _defaultRequestHeaders) {
                defaultRequestHeaders
            } else {
                _defaultRequestHeaders = HttpRequestHeaders()
                return _defaultRequestHeaders.getOrThrow()
            }
        }
    }

    /**
     * @brief 使用底层客户端构建器配置创建 HTTP 客户端。
     * @param configure 用于配置底层 `ClientBuilder` 的回调。
     * @return 创建出的 HTTP 客户端实例。
     */
    public static func create(configure: (ClientBuilder) -> Unit): HttpClient {
        let builder = ClientBuilder()
        configure(builder)
        let client = builder.build()
        return HttpClient(HttpClientHandler(client))
    }

    /**
     * @brief 发送 GET 请求。
     * @param requestUri 请求地址字符串。
     * @return 服务器返回的响应消息。
     */
    public func get(requestUri: String): HttpResponseMessage {
        return get(URL.parse(requestUri))
    }

    /**
     * @brief 发送 GET 请求。
     * @param requestUri 请求地址。
     * @return 服务器返回的响应消息。
     */
    public func get(requestUri: URL): HttpResponseMessage {
        let request = HttpRequestMessage(HttpMethod.Get, requestUri)
        return send(request)
    }

    /**
     * @brief 发送 GET 请求并读取字符串响应。
     * @param requestUri 请求地址字符串。
     * @return 响应内容字符串。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getString(requestUri: String): String {
        return getString(URL.parse(requestUri))
    }

    /**
     * @brief 发送 GET 请求并读取字符串响应。
     * @param requestUri 请求地址。
     * @return 响应内容字符串。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getString(requestUri: URL): String {
        try (response = get(requestUri)) {
            response.ensureSuccessStatusCode()
            return response.content.readAsString()
        }
        throw UnsupportedException()
    }

    /**
     * @brief 发送 GET 请求并读取字节数组响应。
     * @param requestUri 请求地址字符串。
     * @return 响应内容字节数组。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getByteArray(requestUri: String): Array<Byte> {
        return getByteArray(URL.parse(requestUri))
    }

    /**
     * @brief 发送 GET 请求并读取字节数组响应。
     * @param requestUri 请求地址。
     * @return 响应内容字节数组。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getByteArray(requestUri: URL): Array<Byte> {
        try (response = get(requestUri)) {
            response.ensureSuccessStatusCode()
            return response.content.readAsByteArray()
        }
        throw UnsupportedException()
    }

    /**
     * @brief 发送 GET 请求并返回响应流。
     * @param requestUri 请求地址字符串。
     * @return 响应内容输入流。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getStream(requestUri: String): InputStream {
        return getStream(URL.parse(requestUri))
    }

    /**
     * @brief 发送 GET 请求并返回响应流。
     * @param requestUri 请求地址。
     * @return 响应内容输入流。
     * @throws HttpRequestException 当响应状态码不是成功状态时抛出。
     * @throws ObjectDisposedException 当客户端或响应内容已关闭时抛出。
     */
    public func getStream(requestUri: URL): InputStream {
        let response = get(requestUri)
        try {
            response.ensureSuccessStatusCode()
            return response.content.readAsStream()
        } catch (e: Exception) {
            response.close()
            throw e
        }
    }

    /**
     * @brief 发送 POST 请求。
     * @param requestUri 请求地址字符串。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func post(requestUri: String, content: ?HttpContent): HttpResponseMessage {
        return post(URL.parse(requestUri), content)
    }

    /**
     * @brief 发送 POST 请求。
     * @param requestUri 请求地址。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func post(requestUri: URL, content: ?HttpContent): HttpResponseMessage {
        let request = HttpRequestMessage(HttpMethod.Post, requestUri)
        request.content = content
        return send(request)
    }

    /**
     * @brief 发送 PUT 请求。
     * @param requestUri 请求地址字符串。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func put(requestUri: String, content: ?HttpContent): HttpResponseMessage {
        return put(URL.parse(requestUri), content)
    }

    /**
     * @brief 发送 PUT 请求。
     * @param requestUri 请求地址。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func put(requestUri: URL, content: ?HttpContent): HttpResponseMessage {
        let request = HttpRequestMessage(HttpMethod.Put, requestUri)
        request.content = content
        return send(request)
    }

    /**
     * @brief 发送 DELETE 请求。
     * @param requestUri 请求地址字符串。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func delete(requestUri: String, content: ?HttpContent): HttpResponseMessage {
        return delete(URL.parse(requestUri), content)
    }

    /**
     * @brief 发送 DELETE 请求。
     * @param requestUri 请求地址。
     * @param content 请求内容体。
     * @return 服务器返回的响应消息。
     */
    public func delete(requestUri: URL, content: ?HttpContent): HttpResponseMessage {
        let request = HttpRequestMessage(HttpMethod.Delete, requestUri)
        request.content = content
        return send(request)
    }

    /**
     * @brief 发送一个请求消息。
     * @param request 要发送的请求对象。
     * @return 服务器返回的响应消息。
     * @throws ObjectDisposedException 当当前客户端已关闭时抛出。
     * @throws UnsupportedException 当请求地址无效或客户端状态不允许时抛出。
     */
    public func send(request: HttpRequestMessage): HttpResponseMessage {
        checkClosed()
        setOperationStarted()
        prepareRequestMessage(request)
        return super.send(request)
    }

    private func prepareRequestMessage(request: HttpRequestMessage) {
        
        request.timeout = this.timeout

        if (!request.requestUri.isAbsoluteURL()) {
            let requestPath = request.requestUri
            request.requestUri = if (let Some(baseAddress) <- baseAddress) {
                baseAddress.resolveURL(requestPath)
            } else {
                throw UnsupportedException(StringResx.net_http_client_invalid_requesturi)
            }
        }

        // 设置默认请求头（与 C# AddHeaders 行为一致：按头部名整体判断，不合并多值集合）
        if (let Some(defaultRequestHeaders) <- _defaultRequestHeaders) {
            for ((name, values) in defaultRequestHeaders) {
                // 已存在则整体跳过，不合并——与 C# "we don't merge collections" 语义相同
                if (request.headers.getFirst(name).isSome()) {
                    continue
                }
                if (KnownHeaders.isSingleValue(name)) {
                    for (value in values) {
                        request.headers.set(name, value)
                        break
                    }
                } else {
                    for (value in values) {
                        request.headers.add(name, value)
                    }
                }
            }
        }
    }

    private func setOperationStarted() {
        _operationStarted.compareAndSwap(false, true)
    }

    private func checkClosedOrStarted() {
        checkClosed()
        if (_operationStarted.load()) {
            throw UnsupportedException(StringResx.net_http_operation_started)
        }
    }
}
