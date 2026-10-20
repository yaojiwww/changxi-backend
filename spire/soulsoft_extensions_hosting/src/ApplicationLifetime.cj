// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

import std.sync.*
import std.collection.*

/**
 * @brief 提供主机应用生命周期事件管理实现。
 */
public class ApplicationLifetime <: IHostApplicationLifetime {
    private let _lock = Mutex()
    private let _applicationStopping = SyncCounter(1)
    private let _startedEvents = ArrayList<() -> Unit>()
    private let _stoppedEvents = ArrayList<() -> Unit>()
    private let _stoppingEvents = ArrayList<() -> Unit>()

    /**
     * @brief 注册应用启动完成时执行的回调。
     * @param callback 应用启动完成时执行的回调。
     */
    public func onStarted(callback: () -> Unit): Unit {
        synchronized(_lock) {
            _startedEvents.add(callback)
        }
    }

    /**
     * @brief 注册应用停止完成时执行的回调。
     * @param callback 应用停止完成时执行的回调。
     */
    public func onStopped(callback: () -> Unit): Unit {
        synchronized(_lock) {
            _stoppedEvents.add(callback)
        }
    }

    /**
     * @brief 注册应用开始停止时执行的回调。
     * @param callback 应用开始停止时执行的回调。
     */
    public func onStopping(callback: () -> Unit): Unit {
        synchronized(_lock) {
            _stoppingEvents.add(callback)
        }
    }

    /**
     * @brief 通知所有已注册的启动完成回调。
     */
    public func notifyStarted(): Unit {
        let snapshot: Array<() -> Unit>
        synchronized(_lock) {
            snapshot = _startedEvents.toArray()
        }
        for (callback in snapshot) {
            try {
                callback()
            } catch (_) {
            }
        }
    }

    /**
     * @brief 等待应用进入停止状态。
     */
    public func waitForShutdown(): Unit {
        _applicationStopping.waitUntilZero()
    }

    /**
     * @brief 通知应用开始停止。
     */
    public func stopApplication(): Unit {
        synchronized(_lock) {
            if (_applicationStopping.count == 0) {
                return
            }
            for (callback in _stoppingEvents) {
                try {
                    callback()
                } catch (_) {
                }
            }
            _applicationStopping.dec()
        }
    }

    /**
     * @brief 通知所有已注册的停止完成回调。
     */
    public func notifyStopped(): Unit {
        let snapshot: Array<() -> Unit>
        synchronized(_lock) {
            snapshot = _stoppedEvents.toArray()
        }
        for (callback in snapshot) {
            try {
                callback()
            } catch (_: Exception) {
            }
        }
    }
}
