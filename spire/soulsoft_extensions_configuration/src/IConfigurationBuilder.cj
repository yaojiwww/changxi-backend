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
 * @brief 定义配置构建器的公共接口。
 */
public interface IConfigurationBuilder {
    /**
     * @brief 返回当前已注册的配置源列表。
     */
    prop sources: List<IConfigurationSource>

    /**
     * @brief 返回配置构建过程共享的属性集合。
     */
    prop properties: Map<String, Any>

    /**
     * @brief 添加一个配置源。
     * @param source 要添加的配置源。
     * @return 返回当前配置构建器。
     */
    func add(source: IConfigurationSource): IConfigurationBuilder

    /**
     * @brief 构建配置根对象。
     * @return 返回构建得到的配置根对象。
     */
    func build(): IConfigurationRoot
}
