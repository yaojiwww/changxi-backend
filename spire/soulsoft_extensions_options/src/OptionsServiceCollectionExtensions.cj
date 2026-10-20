// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import soulsoft_extensions_injection.*

/**
 * @brief 定义选项服务注册与配置扩展接口。
 */
public interface OptionsServiceCollectionExtensions {
    /**
     * @brief 为指定选项类型注册默认名称的选项服务。
     * @return 返回指定选项类型的构建器。
     */
    func addOptions<TOptions>(): OptionsBuilder<TOptions> where TOptions <: Object {
        addOptions<TOptions>(Options.defaultName)
    }

    /**
     * @brief 为指定名称的选项类型注册选项服务。
     * @param name 选项名称。
     * @return 返回指定选项类型的构建器。
     */
    func addOptions<TOptions>(name: String): OptionsBuilder<TOptions> where TOptions <: Object

    /**
     * @brief 为默认名称的选项注册配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configure<TOptions>(configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configure(Options.defaultName, configureOptions)
    }

    /**
     * @brief 为指定名称的选项注册配置委托。
     * @param name 选项名称。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configure<TOptions>(name: String, configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configure<TOptions>(name) {
            options, _ => configureOptions(options)
        }
    }

    /**
     * @brief 为默认名称的选项注册后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfter<TOptions>(configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configureAfter<TOptions>(Options.defaultName, configureOptions)
    }

    /**
     * @brief 为指定名称的选项注册后置配置委托。
     * @param name 选项名称。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfter<TOptions>(name: String, configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configureAfter<TOptions>(name) {
            options, _ => configureOptions(options)
        }
    }

    /**
     * @brief 为默认名称的选项注册可访问服务提供程序的配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configure<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为指定名称的选项注册可访问服务提供程序的配置委托。
     * @param name 选项名称。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configure<TOptions>(name: String, configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为默认名称的选项注册可访问服务提供程序的后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfter<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为指定名称的选项注册可访问服务提供程序的后置配置委托。
     * @param name 选项名称。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfter<TOptions>(name: String, configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为所有名称的选项注册统一配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAll<TOptions>(configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configureAll<TOptions> {
            options, _ => configureOptions(options)
        }
    }

    /**
     * @brief 为所有名称的选项注册可访问服务提供程序的统一配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAll<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为所有名称的选项注册统一后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfterAll<TOptions>(configureOptions: (TOptions) -> Unit): ServiceCollection where TOptions <: Object {
        configureAfterAll<TOptions> {
            options, _ => configureOptions(options)
        }
    }

    /**
     * @brief 为所有名称的选项注册可访问服务提供程序的统一后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    func configureAfterAll<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object

    /**
     * @brief 为默认名称的选项注册服务并启用启动时验证。
     * @return 返回指定选项类型的构建器。
     */
    func addOptionsWithValidateOnStart<TOptions>(): OptionsBuilder<TOptions> where TOptions <: Object {
        addOptionsWithValidateOnStart<TOptions>(Options.defaultName)
    }

    /**
     * @brief 为指定名称的选项注册服务并启用启动时验证。
     * @param name 选项名称。
     * @return 返回指定选项类型的构建器。
     */
    func addOptionsWithValidateOnStart<TOptions>(name: String): OptionsBuilder<TOptions> where TOptions <: Object
}

extend ServiceCollection <: OptionsServiceCollectionExtensions {
    /**
     * @brief 为指定名称的选项注册核心服务。
     * @param name 选项名称。
     * @return 返回指定选项类型的构建器。
     */
    public func addOptions<TOptions>(name: String): OptionsBuilder<TOptions> where TOptions <: Object {
        tryAddSingleton<IOptions<TOptions>, UnnamedOptionsManager<TOptions>>()

        tryAddSingleton<IOptionsMonitor<TOptions>, OptionsMonitor<TOptions>>()

        tryAddSingleton<IOptionsFactory<TOptions>, OptionsFactory<TOptions>>()

        tryAddSingleton<IOptionsMonitorCache<TOptions>, OptionsCache<TOptions>>()

        return OptionsBuilder<TOptions>(name, this)
    }

    /**
     * @brief 为默认名称的选项注册可访问服务提供程序的配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configure<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        configure(Options.defaultName, configureOptions)
        return this
    }

    /**
     * @brief 为默认名称的选项注册可访问服务提供程序的后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configureAfter<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        configureAfter(Options.defaultName, configureOptions)
        return this
    }

    /**
     * @brief 为指定名称的选项注册可访问服务提供程序的配置委托。
     * @param name 选项名称。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configure<TOptions>(name: String, configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        addOptions<TOptions>()
        addSingleton<IConfigureOptions<TOptions>, ConfigureNamedOptions<TOptions>> {
            services => ConfigureNamedOptions<TOptions>(name, services, configureOptions)
        }
        return this
    }

    /**
     * @brief 为指定名称的选项注册可访问服务提供程序的后置配置委托。
     * @param name 选项名称。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configureAfter<TOptions>(name: String, configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        addOptions<TOptions>()
        this.addSingleton<IConfigureAfterOptions<TOptions>, ConfigureAfterOptions<TOptions>> {
            services => ConfigureAfterOptions<TOptions>(name, services, configureOptions)
        }
        return this
    }

    /**
     * @brief 为所有名称的选项注册统一配置委托。
     * @param configureOptions 配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configureAll<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        addOptions<TOptions>()
        this.addSingleton<IConfigureOptions<TOptions>, ConfigureNamedOptions<TOptions>> {
            services => ConfigureNamedOptions<TOptions>(None, services, configureOptions)
        }
        return this
    }

    /**
     * @brief 为所有名称的选项注册统一后置配置委托。
     * @param configureOptions 后置配置选项实例的委托。
     * @return 返回当前服务集合。
     */
    public func configureAfterAll<TOptions>(configureOptions: (TOptions, IServiceProvider) -> Unit): ServiceCollection where TOptions <: Object {
        addOptions<TOptions>()
        this.addSingleton<IConfigureAfterOptions<TOptions>, ConfigureAfterOptions<TOptions>> {
            services => ConfigureAfterOptions<TOptions>(None, services, configureOptions)
        }
        return this
    }

    /**
     * @brief 为指定名称的选项注册服务并启用启动时验证。
     * @param name 选项名称。
     * @return 返回指定选项类型的构建器。
     */
    public func addOptionsWithValidateOnStart<TOptions>(name: String): OptionsBuilder<TOptions> where TOptions <: Object {
        OptionsBuilder<TOptions>(name, this).validateOnStart()
    }
}
