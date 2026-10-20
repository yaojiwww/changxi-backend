// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

import soulsoft_net_http.*
import std.collection.*

/**
 * @brief 表示 HTTP 客户端工厂的配置选项。
 */
public class HttpClientFactoryOptions {

    private var _handlerLifetime = Duration.minute * 2
    
    internal static let MinimumHandlerLifetime = Duration.second * 1

    /**
     * @brief 获取或设置处理器实例的生命周期。
     * @throws IllegalArgumentException 当处理器生命周期小于最小值且不为零时抛出。
     */
    public mut prop handlerLifetime: Duration {
        get() {
            _handlerLifetime
        }
        set(value) {
            if (value != Duration.Zero && value < MinimumHandlerLifetime) {
                throw IllegalArgumentException(
                    "The handler lifetime must be at least ${MinimumHandlerLifetime.toSeconds()} second.")
            }
            _handlerLifetime = value
        }
    }

    /**
     * @brief 表示应用到 HTTP 客户端实例的配置操作集合。
     */
    public let httpClientActions: List<(HttpClient) -> Unit> = ArrayList<(HttpClient) -> Unit>()

    /**
     * @brief 表示应用到消息处理器构建器的配置操作集合。
     */
    public let httpMessageHandlerBuilderActions: List<(HttpMessageHandlerBuilder) -> Unit> = ArrayList<(HttpMessageHandlerBuilder) -> Unit>()
}
