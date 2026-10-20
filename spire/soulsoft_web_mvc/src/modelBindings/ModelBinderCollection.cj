// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*
import std.collection.*

/**
 * @brief 表示模型绑定器集合。
 */
public class ModelBinderCollection {
    private let _binders: ArrayList<IModelBinder> = ArrayList<IModelBinder>()

    /**
     * @brief 向集合中添加模型绑定器。
     * @param binder 要添加的模型绑定器。
     * @return 当前模型绑定器集合实例。
     */
    public func add(binder: IModelBinder): ModelBinderCollection {
        _binders.add(binder)
        return this
    }

    /**
     * @brief 按注册顺序倒序查找可处理指定类型的绑定器。
     * @param typeInfo 要查找的目标类型。
     * @return 找到的模型绑定器；如果没有匹配项则返回 `None`。
     */
    public func find(typeInfo: TypeInfo): ?IModelBinder {
        var i = _binders.size - 1
        while (i >= 0) {
            let binder = _binders[i]
            if (binder.canBind(typeInfo)) {
                return binder
            }
            i--
        }
        return None
    }
}
