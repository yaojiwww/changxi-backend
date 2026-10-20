// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.sync.*
import std.reflect.*

/**
 * @brief 提供基于处理器发送 HTTP 请求的调用器。
 */
public open class HttpMessageInvoker <: Resource {
    private let _closeHandler: Bool
    private let _isClosed = AtomicBool(false)
    private let _handler: HttpMessageHandler

    /**
     * @brief 使用消息处理器创建调用器。
     * @param handler 实际执行请求的消息处理器。
     */
    public init(handler: HttpMessageHandler) {
        this(handler, true)
    }

    /**
     * @brief 使用消息处理器和关闭策略创建调用器。
     * @param handler 实际执行请求的消息处理器。
     * @param closeHandler 关闭调用器时是否同步关闭处理器。
     */
    public init(handler: HttpMessageHandler, closeHandler: Bool) {
        _handler = handler
        _closeHandler = closeHandler
    }

    /**
     * @brief 发送一个 HTTP 请求。
     * @param request 要发送的请求对象。
     * @return 服务器返回的响应消息。
     * @throws ObjectDisposedException 当当前调用器已关闭时抛出。
     */
    public open func send(request: HttpRequestMessage): HttpResponseMessage {
        checkClosed()
        return _handler.send(request)
    }

    /**
     * @brief 检查当前调用器是否已关闭。
     * @return 已关闭时返回 `true`。
     */
    public open func isClosed(): Bool {
        return _isClosed.load()
    }

    /**
     * @brief 关闭当前调用器。
     * @return 无返回值。
     */
    public open func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            close(true)
        }
    }

    /**
     * @brief 执行调用器关闭时的扩展逻辑。
     * @param closing 是否执行关闭动作。
     */
    protected open func close(closing: Bool): Unit {
        if (closing) {
            if (_closeHandler) {
                _handler.close()
            }
        }
    }

    /**
     * @brief 检查当前调用器是否已关闭。
     * @return 无返回值。
     * @throws ObjectDisposedException 当当前调用器已关闭时抛出。
     */
    protected func checkClosed() {
        if (_isClosed.load()) {
            throw ObjectDisposedException(ClassTypeInfo.of(this).toString())
        }
    }
}
