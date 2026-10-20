// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 提供路由值的相等性比较能力。
 */
public class RouteValueEqualityComparer {

    /**
     * @brief 返回默认的路由值比较器单例。
     */
    public static let default = RouteValueEqualityComparer()

    /**
     * @brief 比较两个路由值是否相等。
     * @param x 第一个路由值。
     * @param y 第二个路由值。
     * @return 相等返回 true。
     */
    public func equals(x: ?String, y: ?String): Bool {
        let sx = x ?? ""
        let sy = y ?? ""
        if (sx.isEmpty() && sy.isEmpty()) {
            // null/空 与 null/空 等价
            return true
        }
        return sx.equalsIgnoreAsciiCase(sy)
    }

    /**
     * @brief 计算路由值的哈希码。
     * @param value 路由值。
     * @return 哈希码。
     */
    public func hashCode(value: ?String): Int64 {
        (value ?? "").toAsciiLower().hashCode()
    }
}
