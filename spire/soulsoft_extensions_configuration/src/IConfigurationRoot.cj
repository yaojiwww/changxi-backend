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
 * @brief 定义配置根对象的公共接口。
 */
public interface IConfigurationRoot <: IConfiguration {
    /**
     * @brief 重新加载所有配置提供程序。
     */
    func reload(): Unit

    /**
     * @brief 返回当前配置根关联的配置提供程序列表。
     */
    prop providers: ReadOnlyList<IConfigurationProvider>
}
