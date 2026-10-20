// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.reflect.*
import std.sync.*

/**
 * @brief 表示可包装内部处理器的委托式 HTTP 消息处理器。
 */
public abstract class DelegatingHandler <: HttpMessageHandler {
    private var _innerHandler: ?HttpMessageHandler
    private let _operationStarted = AtomicBool(false)

    /**
     * @brief 创建一个未指定内部处理器的委托处理器。
     */
    protected init() {
        _innerHandler = None
    }

    /**
     * @brief 使用指定内部处理器创建委托处理器。
     * @param innerHandler 内部消息处理器。
     */
    protected init(innerHandler: HttpMessageHandler) {
        _innerHandler = innerHandler
    }

    /**
     * @brief 获取或设置内部消息处理器。
     * @throws ObjectDisposedException 当当前处理器已关闭时抛出。
     * @throws UnsupportedException 当当前处理器已开始处理请求后再修改内部处理器时抛出。
     */
    public mut prop innerHandler: ?HttpMessageHandler {
        get() {
            _innerHandler
        }
        set(value) {
            checkClosedOrStarted()
            _innerHandler = value
        }
    }

    /**
     * @brief 将请求转发给内部处理器。
     * @param request 要发送的请求消息。
     * @return 内部处理器返回的响应消息。
     * @throws UnsupportedException 当内部处理器未设置时抛出。
     * @throws ObjectDisposedException 当当前处理器已关闭时抛出。
     */
    protected open func send(request: HttpRequestMessage): HttpResponseMessage {
        setOperationStarted()
        if (let Some(innerHandler) <- _innerHandler) {
            innerHandler.send(request)
        } else {
            throw UnsupportedException(StringResx.net_http_handler_not_assigned)
        }
    }

    /**
     * @brief 关闭当前委托处理器并按需关闭内部处理器。
     * @param closing 是否执行关闭动作。
     */
    protected open func close(closing: Bool): Unit {
        if (closing) {
            if (let Some(innerHandler) <- innerHandler) {
                innerHandler.close()
            }
        }
    }

    private func checkClosed() {
        if (isClosed()) {
            throw ObjectDisposedException(ClassTypeInfo.of(this).toString())
        }
    }

    private func checkClosedOrStarted() {
        checkClosed()
        if (_operationStarted.load()) {
            throw UnsupportedException(StringResx.net_http_operation_started)
        }
    }

    private func setOperationStarted() {
        checkClosed()
        _operationStarted.compareAndSwap(false, true)
    }
}
