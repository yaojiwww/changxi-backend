// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import stdx.net.http.HttpHeaders

/**
 * @brief 表示 HTTP 响应头集合。
 */
public class HttpResponseHeaders <: HttpHeadersBase {
    /**
     * @brief 使用底层响应头集合创建响应头对象。
     * @param headers 底层 HTTP 响应头集合。
     */
    protected init(headers: HttpHeaders) {
        super(headers)
    }
}
