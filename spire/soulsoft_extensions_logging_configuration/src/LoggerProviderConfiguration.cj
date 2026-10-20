/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_configuration.*
import std.reflect.*

/**
 * @brief 面向特定提供者类型暴露配置视图。
 */
public class LoggerProviderConfiguration<T> <: ILoggerProviderConfiguration<T> {
    private let _configuration: IConfiguration

    /**
     * @brief 通过工厂解析指定提供者的配置。
     * @param providerConfigurationFactory 配置工厂。
     */
    public init(providerConfigurationFactory: ILoggerProviderConfigurationFactory) {
        _configuration = providerConfigurationFactory.getConfiguration(TypeInfo.of<T>())
    }

    /**
     * @brief 当前提供者的配置视图。
     */
    public prop configuration: IConfiguration {
        get() {
            _configuration
        }
    }
}
