// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

import std.collection.*

/**
 * @brief 表示 CORS 策略评估后的结果。
 */
public class CorsResult {
    /**
     * @brief 指示响应是否需要按请求源设置 Vary 头。
     */
    public var varyByOrigin = false
    /**
     * @brief 指示当前请求源是否被策略允许。
     */
    public var isOriginAllowed = false
    /**
     * @brief 指示当前请求是否为 CORS 预检请求。
     */
    public var isPreflightRequest = false
    /**
     * @brief 指示当前结果是否允许携带凭据。
     */
    public var supportsCredentials = false
    /**
     * @brief 保存允许写入响应头的源地址。
     */
    public var allowedOrigin: ?String = None
    /**
     * @brief 保存预检响应可缓存的最大时长。
     */
    public var preflightMaxAge: ?Duration = None
    /**
     * @brief 保存允许的请求方法列表。
     */
    public var allowedMethods :List<String> = ArrayList<String>()
    /**
     * @brief 保存允许的请求头列表。
     */
    public var allowedHeaders :List<String> = ArrayList<String>()
    /**
     * @brief 保存允许暴露给客户端的响应头列表。
     */
    public var allowedExposedHeaders :List<String> = ArrayList<String>()
}
