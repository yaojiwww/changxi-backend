// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

import std.collection.*

/**
 * @brief 表示 OpenAPI 路径集合。
 */
public class OpenApiPaths <: OpenApiExtensibleDictionary<OpenApiPathItem> {
    /**
     * @brief 创建 OpenAPI 路径集合实例。
     */
    public init() {

    }

    private init(paths: HashMap<String, OpenApiPathItem>) {
        super(paths)
    }
    
}
