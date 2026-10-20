// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

import soulsoft_net_http.*

/**
 * @brief 定义 HTTP 消息处理器工厂的公共接口。
 */
public interface IHttpMessageHandlerFactory {
    /**
     * @brief 按名称创建 HTTP 消息处理器。
     * @param name 处理器名称。
     * @return 返回创建得到的 HTTP 消息处理器。
     */
    func createHandler(name: String): HttpMessageHandler
}
