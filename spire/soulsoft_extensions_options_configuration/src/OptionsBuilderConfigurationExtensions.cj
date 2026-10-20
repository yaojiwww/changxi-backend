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
 * @brief 定义 OptionsBuilder 的配置绑定扩展接口。
 */
public interface OptionsBuilderConfigurationExtensions<TOptions> where TOptions <: Object {
    /**
     * @brief 将当前 OptionsBuilder 绑定到指定配置源。
     * @param configuration 用于绑定选项的配置源。
     * @return 返回当前构建器，便于继续链式配置。
     */
    func bind(configuration: IConfiguration): OptionsBuilder<TOptions>

    /**
     * @brief 从依赖注入容器解析 IConfiguration，并绑定指定配置节。
     * @param configSectionPath 要绑定的配置节路径；空字符串表示根配置。
     * @return 返回当前构建器，便于继续链式配置。
     */
    func bindConfiguration(configSectionPath: String): OptionsBuilder<TOptions>
}

extend<TOptions> OptionsBuilder<TOptions> <: OptionsBuilderConfigurationExtensions<TOptions> {
    /**
     * @brief 将当前 OptionsBuilder 绑定到指定配置源。
     * @param configuration 用于绑定选项的配置源。
     * @return 返回当前构建器，便于继续链式配置。
     */
    public func bind(configuration: IConfiguration): OptionsBuilder<TOptions> {
        this.configure {
            options => configuration.bind(options)
        }
        return this
    }

    /**
     * @brief 从依赖注入容器解析 IConfiguration，并绑定指定配置节。
     * @param configSectionPath 要绑定的配置节路径；空字符串表示根配置。
     * @return 返回当前构建器，便于继续链式配置。
     */
    public func bindConfiguration(configSectionPath: String): OptionsBuilder<TOptions> {
        this.configure {
            options, services =>
                let configuration = services.getOrThrow<IConfiguration>()
                let section = if (configSectionPath.isEmpty()) {
                    configuration
                } else {
                    configuration.getSection(configSectionPath)
                }
                ConfigurationBinder.bind(options, section)
        }
        return this
    }
}
