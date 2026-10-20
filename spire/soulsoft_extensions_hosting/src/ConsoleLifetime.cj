// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

@When[os != "Windows"]
import std.runtime.*

/**
 * @brief 提供基于控制台信号的主机生命周期实现。
 */
public class ConsoleLifetime <: IHostLifetime {
    private let _lifetime: IHostApplicationLifetime

    @When[os != "Windows"]
    private var _signalHandler: ?((Int32) -> Bool) = None

    /**
     * @brief 创建控制台生命周期实例。
     * @param lifetime 主机应用生命周期控制器。
     */
    public init(lifetime: IHostApplicationLifetime) {
        _lifetime = lifetime
    }

    /**
     * @brief 注册控制台信号处理器并等待主机启动。
     */
    @When[os != "Windows"]
    public func waitForStart(): Unit {
        let handler: (Int32) -> Bool = { _ =>
            _lifetime.stopApplication()
            true
        }
        _signalHandler = handler
        registerSignalHandler(Signal.SIGINT, handler)
        registerSignalHandler(Signal.SIGTERM, handler)
    }

    /**
     * @brief 等待主机启动。
     */
    @When[os == "Windows"]
    public func waitForStart(): Unit {}

    /**
     * @brief 注销已注册的控制台信号处理器。
     */
    @When[os != "Windows"]
    public func stop(): Unit {
        if (let Some(handler) <- _signalHandler) {
            unregisterSignalHandler(Signal.SIGINT, handler)
            unregisterSignalHandler(Signal.SIGTERM, handler)
            _signalHandler = None
        }
    }

    /**
     * @brief 停止控制台生命周期控制。
     */
    @When[os == "Windows"]
    public func stop(): Unit {}
}
