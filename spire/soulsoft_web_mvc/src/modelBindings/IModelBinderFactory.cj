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
 * @brief 定义模型绑定器工厂接口。
 */
public interface IModelBinderFactory {
    /**
     * @brief 根据类型信息创建模型绑定器。
     * @param typeInfo 要解析的目标类型。
     * @return 匹配的模型绑定器；如果没有匹配项则返回 `None`。
     */
    func createBinder(typeInfo: TypeInfo): ?IModelBinder
}
