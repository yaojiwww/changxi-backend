// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

extend ConfigurationManager {
    /**
     * @brief 添加一个不带前缀过滤的环境变量配置源。
     * @return 返回当前配置管理器。
     */
    public func addEnvVars(): ConfigurationManager {
        return addEnvVars(String.empty)
    }

    /**
     * @brief 添加一个按前缀过滤的环境变量配置源。
     * @param prefix 环境变量名前缀。
     * @return 返回当前配置管理器。
     */
    public func addEnvVars(prefix: String): ConfigurationManager {
        add(EnvVarsConfigurationSource(prefix))
        return this
    }
}

extend ConfigurationBuilder {
    /**
     * @brief 添加一个不带前缀过滤的环境变量配置源。
     * @return 返回当前配置构建器。
     */
    public func addEnvVars(): ConfigurationBuilder {
        return addEnvVars(String.empty)
    }

    /**
     * @brief 添加一个按前缀过滤的环境变量配置源。
     * @param prefix 环境变量名前缀。
     * @return 返回当前配置构建器。
     */
    public func addEnvVars(prefix: String): ConfigurationBuilder {
        add(EnvVarsConfigurationSource(prefix))
        return this
    }
}
