// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.time.*
import std.reflect.*

/**
 * @brief 表示日期时间模型绑定器。
 */
public class DateTimeModelBinder <: IModelBinder {
    private let _typeInfo: TypeInfo = TypeInfo.of<DateTime>()

    /**
     * @brief 检查当前绑定器是否支持 `DateTime` 类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果目标类型为 `DateTime` 则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _typeInfo
    }

    /**
     * @brief 将字符串值绑定为日期时间。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的日期时间值、默认值或 `()`。
     */
    public func bind(context: ModelBindingContext): Any {
        if (let Some(str) <- context.source.get(context.name)) {
            if (str.isEmpty()) {
                return DateTime.UnixEpoch
            }
            if (let Some(value) <- tryParseDateTime(str)) {
                return value
            }
            context.modelState.addError(context.name, "The value '${str}' is not valid for ${context.name}.")
            return ()
        }
        return DateTime.UnixEpoch
    }

    private static func tryParseDateTime(str: String): ?DateTime {
        if (let Some(v) <- DateTime.tryParse(str)) {
            return v
        }
        if (let Some(v) <- tryParse(str, "yyyy-MM-dd HH:mm:ss")) {
            return v
        }
        if (let Some(v) <- tryParse(str, "yyyy-MM-dd")) {
            return v
        }
        if (let Some(v) <- tryParse(str, DateTimeFormat.RFC3339)) {
            return v
        }
        return None
    }

    private static func tryParse(str: String, format: String): ?DateTime {
        try {
            return DateTime.parse(str, format)
        } catch (_) {
            return None
        }
    }
}
