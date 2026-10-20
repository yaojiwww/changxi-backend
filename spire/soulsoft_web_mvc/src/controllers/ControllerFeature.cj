// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.controllers

import std.reflect.*
import std.collection.*

/**
 * @brief 保存控制器发现结果。
 */
public class ControllerFeature {
    private let _controllers = HashSet<TypeInfo>()

    /**
     * @brief 返回已发现的控制器类型集合。
     * @return 当前已发现的控制器类型集合。
     */
    public prop controllers: Set<TypeInfo> {
        get() {
            _controllers
        }
    }
}
