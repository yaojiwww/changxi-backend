// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 表示路由模式中的分隔符片段。
 */
public class RoutePatternSeparatorPart <: RoutePatternPart{
    private let _content: String
    
    init(content: String) {
        super(RoutePatternPartKind.Separator)
        _content = content
    }

    /**
     * @brief 返回当前分隔符片段的文本内容。
     * @return 分隔符文本。
     */
    public prop content: String {
        get() {
            _content
        }
    }

    protected func debuggerToString(): String {
        return _content
    }
}
