// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

class ConfigurationSection <: IConfigurationSection {
    private let _path: String
    private let _key: String
    private let _root: IConfigurationRoot

    init(path: String, key: String, root: IConfigurationRoot) {
        _path = path
        _key = key
        _root = root
    }

    /**
     * @brief 返回当前配置节的键名。
     * @return 返回当前配置节的键名。
     */
    public prop key: String {
        get() {
            _key
        }
    }

    /**
     * @brief 返回当前配置节对应的值。
     * @return 返回当前配置节对应的值；如果未设置则返回 None。
     */
    public prop value: ?String {
        get() {
            _root[_path]
        }
    }

    /**
     * @brief 返回当前配置节的完整路径。
     * @return 返回当前配置节的完整路径。
     */
    public prop path: String {
        get() {
            _path
        }
    }

    public operator func [](key: String) {
        return _root[ConfigurationPath.combine(_path, key)]
    }

    public operator func [](key: String, value!: ?String) {
        _root[ConfigurationPath.combine(_path, key)] = value
    }

    /**
     * @brief 返回当前配置节下指定键对应的子配置节。
     * @param key 子配置节的键。
     * @return 返回对应的子配置节对象。
     */
    public func getSection(key: String): IConfigurationSection {
        return ConfigurationSection(ConfigurationPath.combine(_path, key), key, _root)
    }

    /**
     * @brief 返回当前配置节下的直接子配置节集合。
     * @return 返回当前配置节下的直接子配置节集合。
     */
    public func getChildren(): Collection<IConfigurationSection> {
        let items = ArrayList<IConfigurationSection>()
        for (key in ConfigurationUtilities.getChildKeys(_root, _path)) {
            let section = getSection(key)
            items.add(section)
        }
        return items
    }
}
