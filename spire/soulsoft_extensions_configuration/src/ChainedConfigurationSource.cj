// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

/**
 * @brief 将现有 IConfiguration 包装为一个可注册的配置源。
 */
class ChainedConfigurationSource <: IConfigurationSource {
    private let _configuration: IConfiguration
    private let _shouldDisposeConfiguration: Bool

    init(configuration: IConfiguration, shouldDisposeConfiguration!: Bool = false) {
        _configuration = configuration
        _shouldDisposeConfiguration = shouldDisposeConfiguration
    }

    /**
     * @brief 返回被链接的配置对象。
     */
    public prop configuration: IConfiguration {
        get() {
            _configuration
        }
    }

    /**
     * @brief 返回当提供程序释放时是否应同时释放被链接配置的标记。
     * @note 当前运行时未提供统一释放协议，该标记仅用于保留 API 兼容性。
     */
    public prop shouldDisposeConfiguration: Bool {
        get() {
            _shouldDisposeConfiguration
        }
    }

    /**
     * @brief 基于当前链接配置源创建配置提供程序。
     * @param _ 当前配置构建器上下文。
     * @return 返回链式配置提供程序。
     */
    public func build(_: IConfigurationBuilder): IConfigurationProvider {
        ChainedConfigurationProvider(this)
    }
}
