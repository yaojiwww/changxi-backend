// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 表示路由参数片段的种类。
 */
public enum RoutePatternParameterKind <: Equatable<RoutePatternParameterKind> {
    /**
     * @brief 表示标准参数。
     */
    Standard
    /**
     * @brief 表示可选参数。
     */
    | Optional
    /**
     * @brief 表示捕获全部剩余路径的参数。
     */
    | CatchAll

    /**
     * @brief 检查当前种类是否为标准参数。
     * @return 当前种类为标准参数时返回 true。
     */
    public func isStandard(): Bool {
        match (this) {
            case Standard => true
            case _ => false
        }
    }

    /**
     * @brief 检查当前种类是否为可选参数。
     * @return 当前种类为可选参数时返回 true。
     */
    public func isOptional(): Bool {
        match (this) {
            case Optional => true
            case _ => false
        }
    }

    /**
     * @brief 检查当前种类是否为捕获所有参数。
     * @return 当前种类为捕获所有参数时返回 true。
     */
    public func isCatchAll(): Bool {
        match (this) {
            case CatchAll => true
            case _ => false
        }
    }

    public operator func ==(that: RoutePatternParameterKind): Bool {
        match ((this, that)) {
            case (Standard, Standard) | (Optional, Optional) | (CatchAll, CatchAll) => true
            case _ => false
        }
    }
}
