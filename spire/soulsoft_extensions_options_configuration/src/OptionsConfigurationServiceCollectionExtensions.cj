/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options_configuration

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_configuration.*

/**
 * @brief 定义基于配置源注册选项的服务集合扩展接口。
 */
public interface OptionsConfigurationServiceCollectionExtensions {
    /**
     * @brief 将默认名称的选项绑定到指定配置源。
     * @param configuration 用于绑定选项的配置源。
     */
    func configure<TOptions>(configuration: IConfiguration): Unit where TOptions <: Object

    /**
     * @brief 将指定名称的选项绑定到配置源。
     * @param name 选项名称。
     * @param configuration 用于绑定选项的配置源。
     */
    func configure<TOptions>(name: String, configuration: IConfiguration): Unit where TOptions <: Object
}

extend ServiceCollection <: OptionsConfigurationServiceCollectionExtensions {
    /**
     * @brief 将默认名称的选项绑定到指定配置源并注册配置服务。
     * @param configuration 用于绑定选项的配置源。
     */
    public func configure<TOptions>(configuration: IConfiguration): Unit where TOptions <: Object {
        this.addOptions<TOptions>()
        this.addSingleton<IConfigureOptions<TOptions>> {
            services => ConfigureFromConfigurationOptions<TOptions>(services, configuration)
        }
    }

    /**
     * @brief 将指定名称的选项绑定到配置源并注册配置服务。
     * @param name 选项名称。
     * @param configuration 用于绑定选项的配置源。
     */
    public func configure<TOptions>(name: String, configuration: IConfiguration): Unit where TOptions <: Object {
        this.addOptions<TOptions>()
        this.addSingleton<IConfigureOptions<TOptions>> {
            services => NamedConfigureFromConfigurationOptions<TOptions>(name, services, configuration)
        }
    }
}
