// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 参数位置。
 */
public enum ParameterLocation <: ToString {
    /**
     * @brief 表示查询字符串参数。
     */
    Query
    /**
     * @brief 表示请求头参数。
     */
    | Header
    /**
     * @brief 表示路径参数。
     */
    | Path

    /**
     * @brief 返回参数位置对应的名称。
     * @return 当前参数位置对应的名称字符串。
     */
    public func toString(): String {
        match (this) {
            case Query => "query"
            case Header => "header"
            case Path => "path"
        }
    }
}
