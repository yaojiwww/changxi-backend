/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.utilities

import std.reflect.*
import soulsoft_web_mvc.annotations.*

/**
 * @brief 提供基于绑定注解的参数名称解析工具。
 */
public class BindingNameUtilities {
    private init() {}

    /**
     * @brief 解析查询字符串绑定名称。
     */
    public static func resolveQueryName(parameter: ParameterInfo): String {
        if (let Some(fromQuery) <- parameter.findAnnotation<FromQuery>() && let Some(name) <- fromQuery.name) {
            return name
        }
        return parameter.name
    }

    /**
     * @brief 解析表单绑定名称。
     */
    public static func resolveFormName(parameter: ParameterInfo): String {
        if (let Some(fromForm) <- parameter.findAnnotation<FromForm>() && let Some(name) <- fromForm.name) {
            return name
        }
        return parameter.name
    }

    /**
     * @brief 解析路由绑定名称。
     */
    public static func resolveRouteName(parameter: ParameterInfo): String {
        if (let Some(fromRoute) <- parameter.findAnnotation<FromRoute>() && let Some(name) <- fromRoute.name) {
            return name
        }
        return parameter.name
    }

    /**
     * @brief 解析请求头绑定名称。
     */
    public static func resolveHeaderName(parameter: ParameterInfo): String {
        if (let Some(fromHeader) <- parameter.findAnnotation<FromHeader>() && let Some(name) <- fromHeader.name) {
            return name
        }
        return parameter.name
    }
}
