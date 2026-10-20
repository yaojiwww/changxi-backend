// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * @brief 表示路由模式片段的种类。
 */
public enum RoutePatternPartKind {
    /**
     * @brief 表示字面量片段。
     */
    Literal
    /**
     * @brief 表示参数片段。
     */
    | Parameter
    /**
     * @brief 表示分隔符片段。
     */
    | Separator
}
