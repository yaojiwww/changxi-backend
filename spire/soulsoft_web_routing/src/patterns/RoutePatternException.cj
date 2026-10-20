// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 表示路由模式解析或组合失败时抛出的异常。
 */
public class RoutePatternException <: Exception {
    private let _pattern: String

    /**
     * @brief 创建一个路由模式异常。
     * @param pattern 触发异常的路由模式文本。
     * @param message 异常说明。
     */
    public init(pattern: String, message: String) {
        super(message)
        _pattern = pattern
    }

    /**
     * @brief 返回触发异常的路由模式文本。
     * @return 路由模式字符串。
     */
    public prop pattern: String {
        get() {
            _pattern
        }
    }
}
