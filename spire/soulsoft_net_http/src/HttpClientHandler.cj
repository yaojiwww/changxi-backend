// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.reflect.*
import stdx.net.tls.*
import stdx.net.http.*
import stdx.net.tls.common.*

/**
 * @brief 提供基于底层 HTTP 客户端的默认消息处理器实现。
 */
public class HttpClientHandler <: HttpMessageHandler {
    private var _client: Client

    /**
     * @brief 创建使用默认 TLS 与超时配置的处理器。
     */
    public init() {
        this(createDefaultClient())
    }

    /**
     * @brief 使用现成底层客户端创建处理器。
     * @param client 底层 HTTP 客户端实例。
     */
    public init(client: Client) {
        _client = client
    }

    private static func createDefaultClient(): Client {
        var tlsConfig = TlsClientConfig()
        tlsConfig.verifyMode = CertificateVerifyMode.Default
        return ClientBuilder().tlsConfig(tlsConfig).readTimeout(75 * Duration.second).build()
    }

    /**
     * @brief 发送一个 HTTP 请求消息。
     * @param request 要发送的请求对象。
     * @return 服务器返回的响应消息。
     * @throws ObjectDisposedException 当当前处理器已关闭时抛出。
     */
    public func send(request: HttpRequestMessage): HttpResponseMessage {
        checkClosed()
        let response = _client.send(createHttpRequest(request))
        return HttpResponseMessage(request, response)
    }

    private func createHttpRequest(request: HttpRequestMessage) {
        let requestBuilder = HttpRequestBuilder()
        requestBuilder.url(request.requestUri)
        if (let Some(timeout) <- request.timeout) {
            requestBuilder.readTimeout(timeout)
        }
        requestBuilder.method(request.method.toString())
        requestBuilder.setHeaders(createRequestHeaders(request))
        if (let Some(content) <- request.content) {
            requestBuilder.body(content.readAsStream())
        }
        return requestBuilder.build()
    }

    private func createRequestHeaders(request: HttpRequestMessage): HttpHeaders {
        let headers = HttpHeaders()
        // request.headers（请求头）与 content.headers（内容头）在 C# 中分属不同命名空间，
        // 正常使用不会有同名冲突，直接合并两个集合即可，与 C# HttpClientHandler wire 行为一致。
        // 合并规则：
        // - 先写 request.headers，再写 content.headers
        // - 单值头部使用 set（后者同名值覆盖前者，保证内容头语义）
        // - 多值头部使用 add（两集合值累积，符合 HTTP 多值语义）
        // defaultRequestHeaders 优先级最低，由 HttpClient.prepareRequestMessage 在调用前处理。

        // 1. 添加 request.headers
        for ((name, values) in request.headers) {
            if (KnownHeaders.isSingleValue(name)) {
                for (value in values) {
                    headers.set(name, value)
                    break
                }
            } else {
                for (value in values) {
                    headers.add(name, value)
                }
            }
        }

        // 2. 添加 content.headers（单值头部会覆盖上面写入的同名值，符合内容头语义优先的设计意图）
        if (let Some(content) <- request.content) {
            for ((name, values) in content.headers) {
                if (KnownHeaders.isSingleValue(name)) {
                    for (value in values) {
                        headers.set(name, value)
                        break
                    }
                } else {
                    for (value in values) {
                        headers.add(name, value)
                    }
                }
            }
        }

        return headers
    }

    /**
     * @brief 关闭当前处理器及其底层客户端。
     * @param closing 是否执行实际关闭逻辑。
     * @return 无返回值。
     */
    public override func close(closing: Bool) {
        if (closing) {
            _client.close()
        }
    }

    private func checkClosed() {
        if (isClosed()) {
            throw ObjectDisposedException(ClassTypeInfo.of(this).toString())
        }
    }
}
