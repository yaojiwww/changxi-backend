// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

/**
 * @brief 定义配置节的公共接口。
 */
public interface IConfigurationSection <: IConfiguration {
    /**
     * @brief 返回当前配置节的键。
     */
    prop key: String

    /**
     * @brief 返回当前配置节对应的值。
     */
    prop value: ?String

    /**
     * @brief 返回当前配置节的完整路径。
     */
    prop path: String

    /**
     * @brief 判断当前配置节是否包含值或子配置节。
     * @return 如果当前配置节包含值或子配置节则返回 true，否则返回 false。
     */
    func exists(): Bool {
        value.isSome() || getChildren().size > 0
    }
}
