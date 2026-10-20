// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.reflect.*

/**
 * @brief 定义按类型存取 HTTP 功能对象的集合。
 */
public interface IFeatureCollection <: Iterable<(TypeInfo, Any)> {
    /**
     * @brief 按类型获取功能实例。
     * @return 匹配类型的功能实例；如果不存在则返回空。
     */
    func get<T>(): ?T
    /**
     * @brief 按类型设置功能实例。
     * @param value 要设置的功能实例。
     */
    func set<T>(value: T): Unit
}
