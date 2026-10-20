/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_injection.*
import soulsoft_extensions_options.*

/**
 * @brief 提供日志提供者选项注册辅助方法。
 */
public abstract class LoggerProviderOptions {
    /**
     * @brief 注册将指定提供者配置绑定到指定选项类型的服务。
     * @param services 服务集合。
     */
    public static func registerProviderOptions<TOptions, TProvider>(services: ServiceCollection): Unit where TOptions <: Object {
        services.addOptions<TOptions>()
        services.addSingleton<IConfigureOptions<TOptions>, LoggerProviderConfigureOptions<TOptions, TProvider>> {
            sp => LoggerProviderConfigureOptions<TOptions, TProvider>(sp,
                sp.getOrThrow<ILoggerProviderConfiguration<TProvider>>())
        }
    }
}
