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
 * @brief 使用 IConfiguration 为命名选项执行配置绑定。
 */
public open class NamedConfigureFromConfigurationOptions<TOptions> <: ConfigureNamedOptions<TOptions> where TOptions <: Object {
    /**
     * @brief 使用指定名称和配置源创建命名选项配置器。
     * @param name 选项名称。
     * @param services 配置时使用的服务提供程序。
     * @param configuration 用于绑定选项的配置源。
     */
    public init(name: ?String, services: IServiceProvider, configuration: IConfiguration) {
        super(name, services, {
            options, _ => configuration.bind(options)
        })
    }
}
