// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.core

/**
 * @brief 表示携带返回值的动作结果基类。
 */
public abstract class ActionResult<T> <: IActionResult {
    private let _value: T

    init(value: T) {
        _value = value
    }

    /**
     * @brief 返回当前动作结果携带的值。
     * @return 当前动作结果中的值。
     */
    public prop value: T {
        get() {
            _value
        }
    }
}
