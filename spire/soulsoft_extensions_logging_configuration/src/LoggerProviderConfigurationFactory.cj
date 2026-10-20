/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import std.reflect.*
import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging.utilities.*

/**
 * @brief 基于日志配置集合解析提供者专属配置。
 */
protected class LoggerProviderConfigurationFactory <: ILoggerProviderConfigurationFactory {
    private let _configurations: Collection<LoggingConfiguration>

    /**
     * @brief 使用已注册日志配置集合创建工厂。
     * @param configurations 日志配置集合。
     */
    public init(configurations: Collection<LoggingConfiguration>) {
        _configurations = configurations
    }

    /**
     * @brief 返回指定提供者类型的配置视图。
     * @param providerType 日志提供者类型。
     */
    public func getConfiguration(providerType: TypeInfo): IConfiguration {
        let fullName = providerType.qualifiedName
        let builder = ConfigurationBuilder()
        for (loggingConfiguration in _configurations) {
            builder.addConfiguration(loggingConfiguration.configuration.getSection(fullName))
        }

        if (let Some(alias) <- ProviderAliasUtilities.getAlias(providerType) && !alias.trimAscii().isEmpty()) {
            for (loggingConfiguration in _configurations) {
                builder.addConfiguration(loggingConfiguration.configuration.getSection(alias))
            }
        }

        return builder.build()
    }
}
