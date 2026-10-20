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

class HttpClientMappingRegistry {
    /**
     * @brief 保存已注册的命名 HTTP 客户端与类型映射。
     */
    public let namedClientRegistrations = HashMap<String, TypeInfo>()
}
