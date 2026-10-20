// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

import soulsoft_net_http.*
import soulsoft_extensions_options.*

/**
 * @brief 定义 HTTP 客户端工厂的公共接口。
 */
public interface IHttpClientFactory {
    /**
     * @brief 创建默认名称的 HTTP 客户端。
     * @return 返回创建得到的 HTTP 客户端。
     */
    func createClient(): HttpClient {
        return createClient(Options.defaultName)
    }

    /**
     * @brief 按名称创建 HTTP 客户端。
     * @param name 客户端名称。
     * @return 返回创建得到的 HTTP 客户端。
     */
    func createClient(name: String): HttpClient
}
