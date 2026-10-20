// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import std.collection.*

/**
 * @brief 定义端点的 HTTP 方法元数据接口。
 */
public interface IHttpMethodMetadata {
    /**
     * @brief 获取或设置是否接受 CORS 预检请求。
     */
    mut prop acceptCorsPreflight: Bool
    /**
     * @brief 返回端点允许的 HTTP 方法列表。
     * @return HTTP 方法集合。
     */
    prop httpMethods: ReadOnlyList<String>
}


