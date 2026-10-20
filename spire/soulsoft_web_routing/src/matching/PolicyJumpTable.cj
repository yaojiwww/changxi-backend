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
 * @brief 定义策略跳转表的抽象基类。
 */
public abstract class PolicyJumpTable {
    /**
     * @brief 根据请求上下文返回下一个目标状态索引。
     * @param context 当前 HTTP 上下文。
     * @return 目标状态索引。
     */
    public func getDestination(context: HttpContext): Int64

    /**
     * @brief 返回当前策略跳转表的调试字符串。
     * @return 调试字符串表示。
     */
    protected open func debuggerToString(): String {
        ClassTypeInfo.of(this).qualifiedName
    }
}
