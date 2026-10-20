// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

extend ConfigurationBuilder {
    /**
     * @brief 将现有配置对象作为链式配置源添加到构建器。
     * @param configuration 被链接的配置对象。
     * @param shouldDisposeConfiguration 保留的兼容参数；当前运行时不执行释放动作。
     * @return 返回当前配置构建器。
     */
    public func addConfiguration(configuration: IConfiguration, shouldDisposeConfiguration!: Bool = false): ConfigurationBuilder {
        add(ChainedConfigurationSource(configuration, shouldDisposeConfiguration: shouldDisposeConfiguration))
        return this
    }
}

extend ConfigurationManager {
    /**
     * @brief 将现有配置对象作为链式配置源添加到配置管理器。
     * @param configuration 被链接的配置对象。
     * @param shouldDisposeConfiguration 保留的兼容参数；当前运行时不执行释放动作。
     * @return 返回当前配置管理器。
     */
    public func addConfiguration(configuration: IConfiguration, shouldDisposeConfiguration!: Bool = false): ConfigurationManager {
        add(ChainedConfigurationSource(configuration, shouldDisposeConfiguration: shouldDisposeConfiguration))
        return this
    }
}
