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
 * @brief 提供配置根对象的构建能力。
 */
public class ConfigurationBuilder <: IConfigurationBuilder {
    private let _properties = HashMap<String, Any>()
    private let _sources = ArrayList<IConfigurationSource>()

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
     * @brief 返回配置构建过程共享的属性集合。
     * @return 返回配置构建过程共享的属性集合。
     */
    public prop properties: Map<String, Any> {
        get() {
            _properties
        }
    }

    /**
     * @brief 添加一个配置源。
     * @param source 要添加的配置源。
     * @return 返回当前配置构建器。
     */
    public func add(source: IConfigurationSource): IConfigurationBuilder {
        _sources.add(source)
        return this
    }

    /**
     * @brief 构建配置根对象并加载所有配置源。
     * @return 返回构建得到的配置根对象。
     */
    public func build(): IConfigurationRoot {
        let providers = ArrayList<IConfigurationProvider>()
        for (source in _sources) {
            let provider = source.build(this)
            provider.load()
            providers.add(provider)
        }
        return ConfigurationRoot(providers)
    }
}
