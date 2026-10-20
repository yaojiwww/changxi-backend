// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging_configuration.*
import soulsoft_extensions_options_configuration.*

/**
 * @brief 提供控制台日志扩展方法。
 */
public interface ConsoleLoggerExtensions {
    /**
     * @brief 注册默认控制台日志提供程序。
     */
    func addConsole(): LoggingBuilder

    /**
     * @brief 注册并配置控制台日志提供程序选项。
     * @param configure 控制台日志选项配置回调。
     * @return 配置后的日志构建器。
     */
    func addConsole(configure: (ConsoleLoggerOptions) -> Unit): LoggingBuilder

    /**
     * @brief 注册默认的 simple 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    func addSimpleConsole(): LoggingBuilder {
        return addConsole()
    }

    /**
     * @brief 注册并配置 simple 控制台格式化器。
     * @param configure simple 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    func addSimpleConsole(configure: (SimpleConsoleFormatterOptions) -> Unit): LoggingBuilder

    /**
     * @brief 从配置源注册 simple 控制台格式化器。
     * @param configuration simple 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    func addSimpleConsole(configuration: IConfiguration): LoggingBuilder

    /**
     * @brief 注册默认的 json 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    func addJsonConsole(): LoggingBuilder {
        return addConsole()
    }

    /**
     * @brief 注册并配置 json 控制台格式化器。
     * @param configure json 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    func addJsonConsole(configure: (JsonConsoleFormatterOptions) -> Unit): LoggingBuilder

    /**
     * @brief 从配置源注册 json 控制台格式化器。
     * @param configuration json 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    func addJsonConsole(configuration: IConfiguration): LoggingBuilder

    /**
     * @brief 注册默认的 systemd 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    func addSystemdConsole(): LoggingBuilder {
        return addConsole()
    }

    /**
     * @brief 注册并配置 systemd 控制台格式化器。
     * @param configure systemd 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    func addSystemdConsole(configure: (ConsoleFormatterOptions) -> Unit): LoggingBuilder

    /**
     * @brief 从配置源注册 systemd 控制台格式化器。
     * @param configuration systemd 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    func addSystemdConsole(configuration: IConfiguration): LoggingBuilder

    /**
     * @brief 注册自定义控制台格式化器。
     */
    func addConsoleFormatter<TFormatter, TOptions>(): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions

    /**
     * @brief 注册并配置自定义控制台格式化器。
     * @param configure 自定义格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    func addConsoleFormatter<TFormatter, TOptions>(configure: (TOptions) -> Unit): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions

    /**
     * @brief 从配置源注册自定义控制台格式化器。
     * @param configuration 自定义格式化器配置源。
     * @return 配置后的日志构建器。
     */
    func addConsoleFormatter<TFormatter, TOptions>(configuration: IConfiguration): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions
}

extend LoggingBuilder <: ConsoleLoggerExtensions {
    /**
     * @brief 注册默认控制台日志提供程序。
     * @return 配置后的日志构建器。
     */
    public func addConsole(): LoggingBuilder {
        addConfiguration()
        addConsoleCore()
        this
    }

    /**
     * @brief 注册并配置控制台日志提供程序选项。
     * @param configure 控制台日志选项配置回调。
     * @return 配置后的日志构建器。
     */
    public func addConsole(configure: (ConsoleLoggerOptions) -> Unit): LoggingBuilder {
        addConsole()
        services.configure<ConsoleLoggerOptions>(configure)
        this
    }

    /**
     * @brief 注册并配置 simple 控制台格式化器。
     * @param configure simple 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    public func addSimpleConsole(configure: (SimpleConsoleFormatterOptions) -> Unit): LoggingBuilder {
        addConsoleWithFormatter<SimpleConsoleFormatterOptions>(ConsoleFormatterNames.Simple, configure)
        this
    }

    /**
     * @brief 注册默认的 simple 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    public func addSimpleConsole(): LoggingBuilder {
        addFormatterWithName(ConsoleFormatterNames.Simple)
        this
    }

    /**
     * @brief 从配置源注册 simple 控制台格式化器。
     * @param configuration simple 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    public func addSimpleConsole(configuration: IConfiguration): LoggingBuilder {
        addConsoleWithFormatterConfiguration<SimpleConsoleFormatterOptions>(ConsoleFormatterNames.Simple, configuration)
        this
    }

    /**
     * @brief 注册默认的 json 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    public func addJsonConsole(): LoggingBuilder {
        addFormatterWithName(ConsoleFormatterNames.Json)
        this
    }

    /**
     * @brief 注册并配置 json 控制台格式化器。
     * @param configure json 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    public func addJsonConsole(configure: (JsonConsoleFormatterOptions) -> Unit): LoggingBuilder {
        addConsoleWithFormatter<JsonConsoleFormatterOptions>(ConsoleFormatterNames.Json, configure)
        this
    }

    /**
     * @brief 从配置源注册 json 控制台格式化器。
     * @param configuration json 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    public func addJsonConsole(configuration: IConfiguration): LoggingBuilder {
        addConsoleWithFormatterConfiguration<JsonConsoleFormatterOptions>(ConsoleFormatterNames.Json, configuration)
        this
    }

    /**
     * @brief 注册并配置 systemd 控制台格式化器。
     * @param configure systemd 格式化器选项配置回调。
     * @return 配置后的日志构建器。
     */
    public func addSystemdConsole(configure: (ConsoleFormatterOptions) -> Unit): LoggingBuilder {
        addConsoleWithFormatter<ConsoleFormatterOptions>(ConsoleFormatterNames.Systemd, configure)
        this
    }

    /**
     * @brief 注册默认的 systemd 控制台格式化器。
     * @return 配置后的日志构建器。
     */
    public func addSystemdConsole(): LoggingBuilder {
        addFormatterWithName(ConsoleFormatterNames.Systemd)
        this
    }

    /**
     * @brief 从配置源注册 systemd 控制台格式化器。
     * @param configuration systemd 格式化器配置源。
     * @return 配置后的日志构建器。
     */
    public func addSystemdConsole(configuration: IConfiguration): LoggingBuilder {
        addConsoleWithFormatterConfiguration<ConsoleFormatterOptions>(ConsoleFormatterNames.Systemd, configuration)
        this
    }

    public func addConsoleFormatter<TFormatter, TOptions>(): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions {
        addConsoleFormatterCore<TFormatter, TOptions, ConsoleLoggerFormatterConfigureOptions<TFormatter, TOptions>> {
            sp => ConsoleLoggerFormatterConfigureOptions<TFormatter, TOptions>(sp,
                sp.getOrThrow<ILoggerProviderConfiguration<ConsoleLoggerProvider>>())
        }
        this
    }

    public func addConsoleFormatter<TFormatter, TOptions>(configure: (TOptions) -> Unit): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions {
        addConsoleFormatter<TFormatter, TOptions>()
        services.configure<TOptions>(configure)
        this
    }

    public func addConsoleFormatter<TFormatter, TOptions>(configuration: IConfiguration): LoggingBuilder where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions {
        addConsoleFormatter<TFormatter, TOptions>()
        services.configure<TOptions>(configuration)
        this
    }

    private func addConsoleFormatterCore<TFormatter, TOptions, TConfigureOptions>(
        createConfigureOptions: (IServiceProvider) -> TConfigureOptions): Unit where TFormatter <: ConsoleFormatter & Object,
        TOptions <: ConsoleFormatterOptions, TConfigureOptions <: IConfigureOptions<TOptions> & Object {
        addConfiguration()
        services.addOptions<TOptions>()
        services.tryAddEnumerable(ServiceDescriptor.singleton<ConsoleFormatter, TFormatter>())
        services.tryAddEnumerable(ServiceDescriptor.singleton<IConfigureOptions<TOptions>, TConfigureOptions> {
            sp => createConfigureOptions(sp)
        })
    }

    private func addConsoleWithFormatter<TOptions>(name: String, configure: (TOptions) -> Unit): LoggingBuilder where TOptions <: ConsoleFormatterOptions {
        addFormatterWithName(name)
        services.configure<TOptions>(configure)
        this
    }

    private func addConsoleWithFormatterConfiguration<TOptions>(name: String, configuration: IConfiguration): LoggingBuilder where TOptions <: ConsoleFormatterOptions {
        addFormatterWithName(name)
        services.configure<TOptions>(configuration)
        this
    }

    private func addFormatterWithName(name: String): LoggingBuilder {
        addConsole {
            options => options.formatterName = name
        }
        this
    }

    private func addConsoleCore(): Unit {
        services.tryAddSingleton<ILoggerProviderConfiguration<ConsoleLoggerProvider>> {
            sp => LoggerProviderConfiguration<ConsoleLoggerProvider>(
                sp.getOrThrow<ILoggerProviderConfigurationFactory>())
        }
        addConsoleFormatterCore<SystemdConsoleFormatter, ConsoleFormatterOptions, ConsoleFormatterConfigureOptions<ConsoleFormatterOptions>> {
            sp => ConsoleFormatterConfigureOptions<ConsoleFormatterOptions>(
                sp.getOrThrow<ILoggerProviderConfiguration<ConsoleLoggerProvider>>())
        }
        addConsoleFormatterCore<JsonConsoleFormatter, JsonConsoleFormatterOptions, ConsoleFormatterConfigureOptions<JsonConsoleFormatterOptions>> {
            sp => ConsoleFormatterConfigureOptions<JsonConsoleFormatterOptions>(
                sp.getOrThrow<ILoggerProviderConfiguration<ConsoleLoggerProvider>>())
        }
        addConsoleFormatterCore<SimpleConsoleFormatter, SimpleConsoleFormatterOptions, ConsoleFormatterConfigureOptions<SimpleConsoleFormatterOptions>> {
            sp => ConsoleFormatterConfigureOptions<SimpleConsoleFormatterOptions>(
                sp.getOrThrow<ILoggerProviderConfiguration<ConsoleLoggerProvider>>())
        }
        services.tryAddEnumerable(ServiceDescriptor.singleton<ILoggerProvider, ConsoleLoggerProvider>())
        services.addOptions<ConsoleLoggerOptions>()
        services.tryAddEnumerable(
            ServiceDescriptor.singleton<IConfigureOptions<ConsoleLoggerOptions>, ConsoleLoggerConfigureOptions> {
                sp => ConsoleLoggerConfigureOptions(
                    sp.getOrThrow<ILoggerProviderConfiguration<ConsoleLoggerProvider>>())
            })
    }
}

/**
 * @brief 从提供程序配置绑定控制台格式化器选项。
 */
class ConsoleLoggerFormatterConfigureOptions<TFormatter, TOptions> <: ConfigureFromConfigurationOptions<TOptions> where TFormatter <: ConsoleFormatter & Object,
    TOptions <: ConsoleFormatterOptions {
    /**
     * @brief 创建一个控制台格式化器选项配置器。
     * @param services 服务提供程序。
     * @param providerConfiguration 控制台日志提供程序配置。
     */
    public init(services: IServiceProvider, providerConfiguration: ILoggerProviderConfiguration<ConsoleLoggerProvider>) {
        super(services, getFormatterOptionsSection(providerConfiguration))
    }
}
