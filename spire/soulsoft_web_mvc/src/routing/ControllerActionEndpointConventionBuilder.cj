// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.routing

import std.sync.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 提供控制器动作端点约定构建器。
 */
public class ControllerActionEndpointConventionBuilder <: EndpointConventionBuilder {
    private let _lock: Mutex
    private let _conventions: ArrayList<(EndpointBuilder) -> Unit>

    init(lock: Mutex, conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        _lock = lock
        _conventions = conventions
    }

    /**
     * @brief 添加端点约定。
     * @param builder 要应用到端点构建器的约定。
     */
    public func add(builder: (EndpointBuilder) -> Unit): Unit {
        synchronized(_lock) {
            _conventions.add(builder)
        }
    }
}
