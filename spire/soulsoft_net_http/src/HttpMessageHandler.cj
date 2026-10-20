// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.sync.*

/**
 * @brief 表示 HTTP 消息处理器的抽象基类。
 */
public abstract class HttpMessageHandler <: Resource {
    private let _isClosed = AtomicBool(false)

    protected func send(request: HttpRequestMessage): HttpResponseMessage

    /**
     * @brief 关闭当前消息处理器。
     * @return 无返回值。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            close(true)
        }
    }

    /**
     * @brief 检查当前处理器是否已关闭。
     * @return 已关闭时返回 `true`。
     */
    public open func isClosed(): Bool {
        return _isClosed.load()
    }

    /**
     * @brief 执行消息处理器关闭时的扩展逻辑。
     * @param _ 是否执行关闭动作。
     */
    protected open func close(_: Bool): Unit {
    }
}
