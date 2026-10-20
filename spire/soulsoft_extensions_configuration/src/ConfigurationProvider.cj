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
 * @brief 提供基于键值存储的配置提供程序基类。
 */
public abstract class ConfigurationProvider <: IConfigurationProvider {
    private let _data = IgnoreCaseHashMap<?String>()

    /**
     * @brief 返回当前提供程序维护的配置数据集合。
     * @return 返回当前提供程序维护的配置数据集合。
     */
    protected prop data: Map<String, ?String> {
        get() {
            _data
        }
    }

    /**
     * @brief 获取指定键对应的配置值。
     * @param key 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    public open func get(key: String): ?String {
        if (_data.contains(key)) {
            return _data[key]
        }
        return None
    }

    /**
     * @brief 设置指定键对应的配置值。
     * @param key 配置项的键。
     * @param value 要写入的配置值。
     */
    public open func set(key: String, value: ?String): Unit {
        _data[key] = value
    }

    /**
     * @brief 返回指定父路径下的子键集合。
     * @param earlierKeys 已收集的子键集合。
     * @param parentPath 父配置路径。
     * @return 返回当前提供程序可见的子键集合。
     */
    public open func getChildKeys(earlierKeys: Collection<String>, parentPath: ?String): Collection<String> {
        let results = HashSet<String>()
        if (let Some(parentPath) <- parentPath) {
            let normalizedParent = parentPath.toLowerStr()
            for (key in data.keys()) {
                if (key.size > normalizedParent.size && key.startsWith(normalizedParent) &&
                    key[normalizedParent.size..normalizedParent.size + 1] == ConfigurationPath.delimiter) {
                    results.add(segment(key, normalizedParent.size + 1))
                }
            }
        } else {
            for (key in data.keys()) {
                results.add(segment(key, 0))
            }
        }
        results.add(all: earlierKeys)
        return results
    }

    private static func segment(key: String, prefixLength: Int64): String {
        if (let Some(index) <- key.indexOf(ConfigurationPath.delimiter, prefixLength)) {
            return key[prefixLength..index]
        }
        return key[prefixLength..]
    }

    /**
     * @brief 加载或重新加载当前提供程序的数据。
     */
    public open func load(): Unit
}
