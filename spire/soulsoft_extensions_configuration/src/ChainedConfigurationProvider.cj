// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

/**
 * @brief 提供对现有 IConfiguration 的链式适配。
 */
public class ChainedConfigurationProvider <: IConfigurationProvider {
    private let _configuration: IConfiguration

    init(source: ChainedConfigurationSource) {
        _configuration = source.configuration
    }

    /**
     * @brief 返回被链接的配置对象。
     */
    public prop configuration: IConfiguration {
        get() {
            _configuration
        }
    }

    /**
     * @brief 链式配置提供程序不维护独立缓存，加载时无需额外处理。
     */
    public func load(): Unit {}

    /**
     * @brief 获取被链接配置中的指定键值。
     * @param key 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    public func get(key: String): ?String {
        _configuration[key]
    }

    /**
     * @brief 将值写回被链接的配置对象。
     * @param key 配置项的键。
     * @param value 要写入的配置值。
     */
    public func set(key: String, value: ?String): Unit {
        _configuration[key] = value
    }

    /**
     * @brief 返回指定父路径下的子键集合。
     * @param earlierKeys 已收集的子键集合。
     * @param parentPath 父配置路径。
     * @return 返回当前链接配置可见的子键集合。
     */
    public func getChildKeys(earlierKeys: Collection<String>, parentPath: ?String): Collection<String> {
        let keys = HashSet<String>()
        let section: IConfiguration = if (let Some(parentPath) <- parentPath) {
            _configuration.getSection(parentPath)
        } else {
            _configuration
        }

        for (child in section.getChildren()) {
            keys.add(child.key)
        }

        keys.add(all: earlierKeys)
        return keys
    }
}
