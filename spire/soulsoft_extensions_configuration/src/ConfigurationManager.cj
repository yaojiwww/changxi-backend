// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.reflect.*
import std.collection.*

/**
 * @brief 提供配置读取、写入和动态追加配置源的管理器。
 */
public class ConfigurationManager <: IConfigurationManager & IConfigurationRoot {
    private let _sources = ArrayList<IConfigurationSource>()
    private let _properties = HashMap<String, Any>()
    private let _providers = ArrayList<IConfigurationProvider>()

    /**
     * @brief 返回当前已注册的配置源列表。
     * @return 返回当前已注册的配置源列表。
     */
    public prop sources: List<IConfigurationSource> {
        get() {
            _sources
        }
    }

    /**
     * @brief 返回当前已加载的配置提供程序列表。
     * @return 返回当前已加载的配置提供程序列表。
     */
    public prop providers: ReadOnlyList<IConfigurationProvider> {
        get() {
            _providers
        }
    }

    /**
     * @brief 返回配置管理过程共享的属性集合。
     * @return 返回配置管理过程共享的属性集合。
     */
    public prop properties: Map<String, Any> {
        get() {
            _properties
        }
    }

    /**
     * @brief 获取指定键对应的配置值。
     * @param key 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    public operator func [](key: String): ?String {
        ConfigurationRoot.getConfiguration(_providers, key)
    }

    /**
     * @brief 设置指定键对应的配置值。
     * @param key 配置项的键。
     * @param value 要写入的配置值。
     */
    public operator func [](key: String, value!: ?String): Unit {
        ConfigurationRoot.setConfiguration(_providers, key, value)
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

    /**
     * @brief 返回当前配置树中的所有键值对。
     * @return 返回键值对集合。
     */
    public func asEnumerable(): Collection<(String, ?String)> {
        ConfigurationUtilities.asEnumerable(this, false)
    }

    /**
     * @brief 返回当前配置树中的所有键值对。
     * @param makePathsRelative 是否将路径裁剪为相对于当前配置节点。
     * @return 返回键值对集合。
     */
    public func asEnumerable(makePathsRelative: Bool): Collection<(String, ?String)> {
        ConfigurationUtilities.asEnumerable(this, makePathsRelative)
    }

    /**
     * @brief 按指定类型信息获取配置值。
     * @param typeInfo 目标值的类型信息。
     * @param name 配置项的键。
     * @return 返回转换后的配置值；如果不存在或无法提供则返回 None。
     */
    public func getValue(typeInfo: TypeInfo, name: String): ?Any {
        ConfigurationBinder.getValue(this, typeInfo, name)
    }

    /**
     * @brief 按泛型类型获取配置值。
     * @param name 配置项的键。
     * @return 返回转换后的配置值；如果不存在或类型不匹配则返回 None。
     */
    public func getValue<T>(name: String): ?T {
        ConfigurationBinder.getValue<T>(this, name)
    }

    /**
     * @brief 将当前配置节点自身绑定到对象实例的可变字段。
     * @param instance 待绑定的对象实例。
     */
    public func bind(instance: Object): Unit {
        ConfigurationBinder.bind(instance, this)
    }

    /**
     * @brief 将指定配置节的值绑定到对象实例的可变字段。
     * @param name 配置节的键。
     * @param instance 待绑定的对象实例。
     */
    public func bind(name: String, instance: Object): Unit {
        ConfigurationBinder.bind(instance, getSection(name))
    }

    /**
     * @brief 添加一个配置源并立即加载对应提供程序。
     * @param source 要添加的配置源。
     * @return 返回当前配置管理器。
     */
    public func add(source: IConfigurationSource): IConfigurationBuilder {
        let provider = source.build(this)
        provider.load()
        _sources.add(source)
        _providers.add(provider)
        return this
    }

    /**
     * @brief 返回当前配置根对象。
     * @return 返回当前配置管理器自身。
     */
    public func build(): IConfigurationRoot {
        this
    }
}
