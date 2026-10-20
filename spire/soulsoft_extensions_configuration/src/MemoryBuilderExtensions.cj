// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

extend ConfigurationBuilder {
    /**
     * @brief 添加一个空的内存配置源。
     * @return 返回当前配置构建器。
     */
    public func addMemory(): ConfigurationBuilder {
        addMemory([])
        return this
    }

    /**
     * @brief 添加一个基于键值集合的内存配置源。
     * @param values 初始化内存配置源的键值集合。
     * @return 返回当前配置构建器。
     */
    public func addMemory(values: Collection<(String, String)>): ConfigurationBuilder {
        add(MemoryConfigurationSource(HashMap<String, String>(values)))
        return this
    }
}

extend ConfigurationManager {
    /**
     * @brief 添加一个空的内存配置源。
     * @return 返回当前配置管理器。
     */
    public func addMemory(): ConfigurationManager {
        addMemory([])
        return this
    }

    /**
     * @brief 添加一个基于键值集合的内存配置源。
     * @param values 初始化内存配置源的键值集合。
     * @return 返回当前配置管理器。
     */
    public func addMemory(values: Collection<(String, String)>): ConfigurationManager {
        add(MemoryConfigurationSource(HashMap<String, String>(values)))
        return this
    }
}
