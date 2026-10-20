// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 表示路由模式片段的抽象基类。
 */
public abstract class RoutePatternPart {
    private let _partKind: RoutePatternPartKind

    /**
     * @brief 创建一个路由模式片段基类实例。
     * @param partKind 当前片段的种类。
     */
    protected RoutePatternPart(partKind: RoutePatternPartKind) {
        _partKind = partKind
    }

    /**
     * @brief 检查当前片段是否为字面量片段。
     * @return 当前片段为字面量时返回 true。
     */
    public prop isLiteral: Bool {
        get() {
            match (_partKind) {
                case RoutePatternPartKind.Literal => true
                case _ => false
            }
        }
    }

    /**
     * @brief 检查当前片段是否为参数片段。
     * @return 当前片段为参数时返回 true。
     */
    public prop isParameter: Bool {
        get() {
            match (_partKind) {
                case RoutePatternPartKind.Parameter => true
                case _ => false
            }
        }
    }

    /**
     * @brief 检查当前片段是否为分隔符片段。
     * @return 当前片段为分隔符时返回 true。
     */
    public prop isSeparator: Bool {
        get() {
            match (_partKind) {
                case RoutePatternPartKind.Separator => true
                case _ => false
            }
        }
    }

    /**
     * @brief 返回当前片段的种类。
     * @return 片段种类。
     */
    public prop partKind: RoutePatternPartKind {
        get() {
            _partKind
        }
    }

    protected func debuggerToString(): String
}
