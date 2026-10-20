/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_injection.*
import soulsoft_extensions_options_configuration.*

/**
 * @brief 将提供者专属配置绑定到选项对象。
 */
public class LoggerProviderConfigureOptions<TOptions, TProvider> <: ConfigureFromConfigurationOptions<TOptions>
    where TOptions <: Object {
    /**
     * @brief 使用指定提供者配置创建选项配置器。
     * @param providerConfiguration 提供者专属配置。
     */
    public init(services: IServiceProvider, providerConfiguration: ILoggerProviderConfiguration<TProvider>) {
        super(services, providerConfiguration.configuration)
    }
}
