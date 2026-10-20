// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.controllers

import std.collection.*

/**
 * @brief 表示控制器动作描述符集合。
 */
public class ActionDescriptorCollection {
    /**
     * @brief 返回当前集合中的动作描述符列表。
     */
    public let items: ReadOnlyList<ControllerActionDescriptor>

    /**
     * @brief 创建动作描述符集合实例。
     * @param items 要包含的动作描述符列表。
     */
    public init(items: ReadOnlyList<ControllerActionDescriptor>) {
        this.items = items
    }
}
