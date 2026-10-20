// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.reflect.*
import soulsoft_web_http.*

/**
 * @brief 定义请求路径匹配器的抽象基类。
 */
public abstract class Matcher {
    /**
     * @brief 对当前请求执行端点匹配。
     * @param context 当前 HTTP 上下文。
     */
    public func invoke(context: HttpContext): Unit

    /**
     * @brief 返回当前匹配器的调试字符串。
     * @return 调试字符串表示。
     */
    public open func debuggerToString(): String {
        return ClassTypeInfo.of(this).qualifiedName
    }
}
