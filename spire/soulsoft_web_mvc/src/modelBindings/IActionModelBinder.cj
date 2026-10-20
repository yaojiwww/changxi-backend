// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

/**
 * @brief 定义动作级模型绑定器接口。
 */
public interface IActionModelBinder {
    /**
     * @brief 绑定控制器动作的全部参数。
     * @param context 动作绑定上下文。
     * @return 按参数顺序排列的绑定结果数组。
     */
    func bind(context: ActionBindingContext): Array<Any>
}
