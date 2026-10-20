// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

import std.ref.*
import soulsoft_net_http.*
import soulsoft_extensions_injection.*

class ExpiredHandlerTrackingEntry {
    private let _name: String
    private let _scope: IServiceScope
    private let _innerHandler: ?HttpMessageHandler
    private let _livenessTracker: WeakRef<LifetimeTrackingHttpMessageHandler>

    init(other: ActiveHandlerTrackingEntry) {
        _name = other.name
        _scope = other.scope
        _innerHandler = other.handler.innerHandler
        _livenessTracker = WeakRef<LifetimeTrackingHttpMessageHandler>(other.handler, CleanupPolicy.EAGER)
    }

    /**
     * @brief 返回已过期处理器项对应的客户端名称。
     * @return 返回已过期处理器项对应的客户端名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回已过期处理器项关联的服务作用域。
     * @return 返回已过期处理器项关联的服务作用域。
     */
    public prop scope: IServiceScope {
        get() {
            _scope
        }
    }

    /**
     * @brief 返回已过期处理器项持有的内部消息处理器。
     * @return 返回已过期处理器项持有的内部消息处理器；如果不存在则返回 None。
     */
    public prop innerHandler: ?HttpMessageHandler {
        get() {
            _innerHandler
        }
    }

    /**
     * @brief 检查当前已过期处理器项是否可以释放资源。
     * @return 如果当前已过期处理器项可以释放资源则返回 true，否则返回 false。
     */
    public prop canDispose: Bool {
        get() {
            _livenessTracker.value.isNone()
        }
    }
}
