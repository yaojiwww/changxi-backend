// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import std.collection.*
import soulsoft_net_http.*
import soulsoft_extensions_injection.*

class DefaultHttpMessageHandlerBuilder <: HttpMessageHandlerBuilder {
    private var _name: ?String = None
    private let _services: IServiceProvider
    private var _primaryHandler: HttpMessageHandler
    private let _additionalHandlers = ArrayList<DelegatingHandler>()

    /**
     * @brief 创建默认 HTTP 消息处理器构建器。
     * @param services 当前构建器使用的服务提供程序。
     */
    public init(services: IServiceProvider) {
        _services = services
        _primaryHandler = createPrimaryHandler()
    }

    public mut prop name: ?String {
        get() {
            _name
        }
        set(value) {
            _name = value
        }
    }
    /**
     * @brief 返回当前处理器构建器使用的服务提供程序。
     * @return 返回当前处理器构建器使用的服务提供程序。
     */
    public prop services: IServiceProvider {
        get() {
            _services
        }
    }

    public mut prop primaryHandler: HttpMessageHandler {
        get() {
            _primaryHandler
        }
        set(value) {
            _primaryHandler = value
        }
    }

    /**
     * @brief 返回附加消息处理器集合。
     * @return 返回附加消息处理器集合。
     */
    public prop additionalHandlers: List<DelegatingHandler> {
        get() {
            _additionalHandlers
        }
    }

    /**
     * @brief 构建 HTTP 消息处理器管道。
     * @return 返回构建得到的 HTTP 消息处理器管道。
     */
    public func build(): HttpMessageHandler {
        return createHandlerPipeline(primaryHandler, additionalHandlers)
    }

    private static func createPrimaryHandler() {
        return HttpClientHandler()
    }
}
