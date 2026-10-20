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
 * @brief 表示字符串模型绑定器。
 */
public class StringModelBinder <: IModelBinder {
    private let _typeInfo: TypeInfo = TypeInfo.of<String>()

    /**
     * @brief 检查当前绑定器是否支持 `String` 类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果目标类型为 `String` 则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _typeInfo
    }

    /**
     * @brief 将字符串值绑定到目标参数。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的字符串值；如果值缺失则返回空字符串。
     */
    public func bind(context: ModelBindingContext): Any {
        if (let Some(str) <- context.source.get(context.name)) {
            if (!str.isEmpty()) { return str }
        }
        return String.empty
    }
}
