// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import soulsoft_web_http.*

/**
 * @brief 提供 RoutePattern 转换功能的抽象基类。
 * 提供 RoutePattern 转换功能的抽象基类，通常作为单例服务注入使用。
 *
 * 通过调用 substituteRequiredValues 可将一个通用参数化路由模式替换为
 * 某套特定 required values 对应的衍生路由模式，用于多端点共用同一路由模板的场景。
 */
public abstract class RoutePatternTransformer {

    /**
     * @brief 尝试将 requiredValues 替换到原始路由模式中。
     * @description 替换过程会考虑参数默认值与路由约束；任意 required value 不满足条件时返回 None。
     * @param original 原始路由模式。
     * @param requiredValues 要替换的 required values 字典。
     * @return 替换成功时返回新的 RoutePattern，失败时返回 None。
     */
    public open func substituteRequiredValues(original: RoutePattern, requiredValues: RouteValueDictionary): ?RoutePattern {
        throw UnsupportedException("This API is not supported.")
    }
}
