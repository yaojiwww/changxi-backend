// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import std.sync.*
import soulsoft_extensions_injection.*

type TimerCallback = () -> Unit

class ActiveHandlerTrackingEntry {
    private let _operationStarted = AtomicBool(false)
    private let _timerLock = Mutex()
    private var _timer: ?Timer = None

    ActiveHandlerTrackingEntry(let name: String, let lifetime: Duration, let scope: IServiceScope,
        let handler: LifetimeTrackingHttpMessageHandler) {
    }

    /**
     * @brief 启动当前活动处理器项的过期定时器。
     * @param callback 定时器到期后执行的回调。
     */
    public func startExpiryTimer(callback: TimerCallback): Unit {
        if (lifetime == Duration.Zero) {
            return
        }

        if (_operationStarted.load()) {
            return
        }

        if (_operationStarted.compareAndSwap(false, true)) {
            synchronized(_timerLock) {
                _timer = Timer.once(lifetime) {
                    timerTick(callback)
                }
            }
        }
    }

    // 定时器触发时的内部处理：先在锁内确认未被取消并释放 Timer 引用，再执行回调。
    // cancel() 不会打断正在执行的 task，但若在 task 启动前调用 cancel()，
    // _timer 已被外部置 None，此处 null-guard 可安全跳过回调。
    private func timerTick(callback: TimerCallback) {
        synchronized(_timerLock) {
            if (_timer.isNone()) {
                return
            }
            _timer = None
        }
        callback()
    }
}
