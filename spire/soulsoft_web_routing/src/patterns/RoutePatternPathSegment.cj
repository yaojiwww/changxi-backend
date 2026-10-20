// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.collection.*

/**
 * @brief 表示路由模式中的一个路径段。
 */
public class RoutePatternPathSegment {
    private let _parts: ReadOnlyList<RoutePatternPart>

    init(parts: ReadOnlyList<RoutePatternPart>) {
        _parts = parts
    }

    /**
     * @brief 检查当前路径段是否只包含一个片段。
     * @return 仅包含一个片段时返回 true。
     */
    public prop isSimple: Bool {
        get() {
            _parts.size == 1
        }
    }

    /**
     * @brief 返回当前路径段包含的片段列表。
     * @return 路径段片段集合。
     */
    public prop parts: ReadOnlyList<RoutePatternPart> {
        get() {
            _parts
        }
    }

    internal static func debugger(parts: ReadOnlyList<RoutePatternPart>): String {
        return String.join(parts |> map {f => f.debuggerToString()} |> collectArray, delimiter: String.empty)
    }

    /**
     * @brief 返回当前路径段的调试字符串。
     * @return 路径段文本表示。
     */
    public func toString(): String {
        debugger(_parts)
    }
}
