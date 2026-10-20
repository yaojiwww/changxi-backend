// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_injection.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*
import soulsoft_extensions_configuration.*

/**
 * @brief 提供基于配置源加载日志规则的扩展。
 */
public interface LoggingBuilderConfigurationExtension {
    /**
     * @brief 注册消费提供者配置所需的基础服务。
     * @return 返回当前日志构建器。
     */
    func addConfiguration(): LoggingBuilder

    /**
     * @brief 从配置对象加载日志规则到日志构建器。
     * @param configuration 包含日志配置节的配置对象。
     * @return 返回当前日志构建器，便于继续链式配置。
     */
    func addConfiguration(configuration: IConfiguration): LoggingBuilder
}

extend LoggingBuilder <: LoggingBuilderConfigurationExtension {
    /**
     * @brief 注册消费提供者配置所需的基础服务。
     * @return 返回当前日志构建器。
     */
    public func addConfiguration(): LoggingBuilder {
        services.tryAddSingleton<ILoggerProviderConfigurationFactory, LoggerProviderConfigurationFactory> {
            sp => LoggerProviderConfigurationFactory(sp.getAll<LoggingConfiguration>())
        }
        return this
    }

    /**
     * @brief 从配置对象加载日志规则到日志构建器。
     * @param configuration 包含日志配置节的配置对象。
     * @return 返回当前日志构建器，便于继续链式配置。
     */
    public func addConfiguration(configuration: IConfiguration): LoggingBuilder {
        addConfiguration()
        services.addOptions<LoggerFilterOptions>()
        services.addSingleton<IConfigureOptions<LoggerFilterOptions>, LoggerFilterConfigureOptions> {
            _ => LoggerFilterConfigureOptions(configuration)
        }
        services.addSingleton<LoggingConfiguration>(LoggingConfiguration(configuration))
        return this
    }
}
