// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

/**
 * @brief 表示请求匹配到多个同优先级端点时抛出的异常。
 */
public class AmbiguousMatchException <: Exception {
    /**
     * @brief 创建一个端点匹配歧义异常。
     * @param message 异常说明。
     */
    public init(message: String) {
        super(message)
    }
}
