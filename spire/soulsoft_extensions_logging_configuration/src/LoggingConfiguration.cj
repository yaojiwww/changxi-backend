/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_configuration.*

/**
 * @brief 包装一份用于日志系统的配置根。
 */
public class LoggingConfiguration {
    /**
     * @brief 当前日志配置根。
     */
    public let configuration: IConfiguration

    /**
     * @brief 使用指定配置根创建包装对象。
     * @param configuration 日志配置根。
     */
    public init(configuration: IConfiguration) {
        this.configuration = configuration
    }
}
