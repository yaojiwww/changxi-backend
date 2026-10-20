// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import std.reflect.*
import std.collection.*
import soulsoft_net_http.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义 HTTP 消息处理器管道构建器的抽象基类。
 */
public abstract class HttpMessageHandlerBuilder {
    /**
     * @brief 获取或设置当前处理器构建器名称。
     */
    public mut prop name: ?String

    /**
     * @brief 返回当前处理器构建器使用的服务提供程序。
     * @return 返回当前处理器构建器使用的服务提供程序。
     */
    public prop services: IServiceProvider

    /**
     * @brief 获取或设置主 HTTP 消息处理器。
     */
    public mut prop primaryHandler: HttpMessageHandler

    /**
     * @brief 返回附加消息处理器集合。
     * @return 返回附加消息处理器集合。
     */
    public prop additionalHandlers: List<DelegatingHandler>

    /**
     * @brief 构建 HTTP 消息处理器管道。
     * @return 返回构建得到的 HTTP 消息处理器。
     */
    public func build(): HttpMessageHandler

    protected func createHandlerPipeline(primaryHandler: HttpMessageHandler,
        additionalHandlers: Collection<DelegatingHandler>): HttpMessageHandler {
        let additionalHandlersList = additionalHandlers.toArray()

        var next = primaryHandler

        var i = additionalHandlers.size - 1
        while (i >= 0) {
            let handler = additionalHandlersList[i]
            if (handler.innerHandler.isSome()) {
                throw UnsupportedException(
                    "The 'innerHandler' property must be null. 'DelegatingHandler' instances provided to 'HttpMessageHandlerBuilder' must not be reused or cached.\r\nHandler: '${ClassTypeInfo.of(handler)}'")
            }

            handler.innerHandler = next
            next = handler
            i--
        }

        return next
    }
}
