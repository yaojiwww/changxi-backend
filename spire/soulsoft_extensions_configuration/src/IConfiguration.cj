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
 * @brief 定义配置读取、写入和分节访问的核心接口。
 */
public interface IConfiguration {
    /**
     * @brief 获取指定键对应的配置值。
     * @param name 配置项的键。
     * @return 返回对应的配置值；如果不存在则返回 None。
     */
    operator func [](name: String): ?String

    /**
     * @brief 设置指定键对应的配置值。
     * @param name 配置项的键。
     * @param value 要写入的配置值。
     */
    operator func [](name: String, value!: ?String): Unit

    /**
     * @brief 返回指定键对应的配置节。
     * @param name 配置节的键。
     * @return 返回对应的配置节对象。
     */
    func getSection(name: String): IConfigurationSection

    /**
     * @brief 返回当前配置下的直接子配置节集合。
     * @return 返回直接子配置节集合。
     */
    func getChildren(): Collection<IConfigurationSection>

    /**
     * @brief 返回当前配置树中的所有键值对。
     * @return 返回键值对集合。
     */
    func asEnumerable(): Collection<(String, ?String)> {
        asEnumerable(false)
    }

    /**
     * @brief 返回当前配置树中的所有键值对。
     * @param makePathsRelative 是否将路径裁剪为相对于当前配置节点。
     * @return 返回键值对集合。
     */
    func asEnumerable(makePathsRelative: Bool): Collection<(String, ?String)> {
        ConfigurationUtilities.asEnumerable(this, makePathsRelative)
    }

    /**
     * @brief 按指定类型信息获取配置值。
     * @param typeInfo 目标值的类型信息。
     * @param name 配置项的键。
     * @return 返回转换后的配置值；如果不存在或无法提供则返回 None。
     */
    func getValue(typeInfo: TypeInfo, name: String): ?Any {
        ConfigurationBinder.getValue(this, typeInfo, name)
    }

    /**
     * @brief 按泛型类型获取配置值。
     * @param name 配置项的键。
     * @return 返回转换后的配置值；如果不存在或类型不匹配则返回 None。
     */
    func getValue<T>(name: String): ?T {
        ConfigurationBinder.getValue<T>(this, name)
    }

    /**
     * @brief 将当前配置节点自身绑定到对象实例的可变字段。
     * @param instance 待绑定的对象实例。
     */
    func bind(instance: Object): Unit {
        ConfigurationBinder.bind(instance, this)
    }

    /**
     * @brief 将指定配置节的值绑定到对象实例的可变字段。
     * @param name 配置节的键。
     * @param instance 待绑定的对象实例。
     */
    func bind(name: String, instance: Object): Unit {
        ConfigurationBinder.bind(instance, getSection(name))
    }
}
