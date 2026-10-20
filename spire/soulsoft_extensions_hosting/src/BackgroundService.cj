// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

import std.sync.*

/**
 * @brief 提供后台托管服务的基础实现。
 */
public abstract class BackgroundService <: IHostedService & Resource {
    private var _future: ?Future<Unit> = None
    private let _isClosed = AtomicBool(false)

    /**
     * @brief 启动后台服务。
     */
    public func start(): Unit {
        _future = spawn {
            run()
        }
    }

    /**
     * @brief 停止后台服务。
     */
    public func stop(): Unit {
        _future?.cancel()
    }

    /**
     * @brief 执行后台服务的主体逻辑。
     */
    public func run(): Unit

    /**
     * @brief 检查当前后台服务是否已关闭。
     * @return 如果后台服务已关闭则返回 true，否则返回 false。
     */
    public open func isClosed(): Bool {
        return _isClosed.load()
    }

    /**
     * @brief 关闭当前后台服务。
     */
    public open func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            _future?.cancel()
        }
    }
}
