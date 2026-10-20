// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.reflect.*

/**
 * @brief 定义配置提供程序的基础接口。
 */
public interface IConfigurationProvider <: ToString {
    /**
     * @brief 加载或重新加载配置数据。
     */
    func load(): Unit

    /**
     * @brief 获取指定键对应的配置值。
     * @param key 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    func get(key: String): ?String

    /**
     * @brief 设置指定键对应的配置值。
     * @param key 配置项的键。
     * @param value 要写入的配置值。
     */
    func set(key: String, value: ?String): Unit

    /**
     * @brief 返回指定父路径下的子键集合。
     * @param earlierKeys 已收集的子键集合。
     * @param parentPath 父配置路径。
     * @return 返回当前提供程序可见的子键集合。
     */
    func getChildKeys(earlierKeys: Collection<String>, parentPath: ?String): Collection<String>

    /**
     * @brief 返回当前配置提供程序的类型描述。
     * @return 返回提供程序的字符串表示。
     */
    func toString(): String {
        "${TypeInfo.of(this).name}"
    }
}
