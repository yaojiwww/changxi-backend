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
 * @brief 表示由多个配置提供程序组合而成的配置根对象。
 */
public class ConfigurationRoot <: IConfigurationRoot {
    private let _providers: ReadOnlyList<IConfigurationProvider>

    /**
     * @brief 创建一个配置根对象。
     * @param providers 参与解析配置的提供程序列表。
     */
    public init(providers: ReadOnlyList<IConfigurationProvider>) {
        _providers = providers
    }

    /**
     * @brief 返回当前配置根关联的配置提供程序列表。
     * @return 返回当前配置根关联的配置提供程序列表。
     */
    public prop providers: ReadOnlyList<IConfigurationProvider> {
        get() {
            _providers
        }
    }

    /**
     * @brief 获取指定键对应的配置值。
     * @param key 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    public operator func [](key: String): ?String {
        return getConfiguration(_providers, key)
    }

    /**
     * @brief 设置指定键对应的配置值。
     * @param key 配置项的键。
     * @param value 要写入的配置值。
     */
    public operator func [](key: String, value!: ?String): Unit {
        setConfiguration(_providers, key, value)
    }

    /**
     * @brief 重新加载当前所有配置提供程序。
     */
    public func reload(): Unit {
        for (provider in _providers) {
            provider.load()
        }
    }

    /**
     * @brief 返回指定键对应的配置节。
     * @param key 配置节的键。
     * @return 返回对应的配置节对象。
     */
    public func getSection(key: String): IConfigurationSection {
        return ConfigurationSection(key, key, this)
    }

    /**
     * @brief 返回当前配置下的直接子配置节集合。
     * @return 返回直接子配置节集合。
     */
    public func getChildren(): Collection<IConfigurationSection> {
        let items = ArrayList<IConfigurationSection>()
        for (key in ConfigurationUtilities.getChildKeys(this, None)) {
            let section = getSection(key)
            items.add(section)
        }
        return items
    }

    static func getConfiguration(providers: ReadOnlyList<IConfigurationProvider>, key: String): ?String {
        var index = providers.size - 1
        while (index >= 0) {
            let provider = providers[index]
            if (let Some(value) <- provider.get(key)) {
                return value
            }
            index--
        }
        return None
    }

    static func setConfiguration(providers: Collection<IConfigurationProvider>, key: String, value: ?String): Unit {
        for (provider in providers) {
            provider.set(key, value)
        }
    }
}
