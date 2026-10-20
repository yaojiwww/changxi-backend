/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import std.reflect.*
import soulsoft_extensions_configuration.*

/**
 * @brief 定义按提供者类型解析配置的工厂接口。
 */
public interface ILoggerProviderConfigurationFactory {
    /**
     * @brief 返回指定提供者类型对应的配置视图。
     * @param providerType 日志提供者类型。
     */
    func getConfiguration(providerType: TypeInfo): IConfiguration
}
