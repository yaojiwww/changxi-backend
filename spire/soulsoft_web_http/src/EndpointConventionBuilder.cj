// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义向端点构建器追加约定的能力。
 */
public abstract class EndpointConventionBuilder {
    /**
     * @brief 追加一个端点构建约定。
     * @param builder 用于修改端点构建器的回调。
     */
    public func add(builder: (EndpointBuilder) -> Unit): Unit
}
