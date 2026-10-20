// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*

/**
 * @brief 定义单个模型绑定器接口。
 */
public interface IModelBinder {
    /**
     * @brief 检查当前绑定器是否支持指定类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果当前绑定器支持该类型则返回 `true`。
     */
    func canBind(typeInfo: TypeInfo): Bool
    /**
     * @brief 绑定指定上下文中的值。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的值。
     */
    func bind(context: ModelBindingContext): Any
}
