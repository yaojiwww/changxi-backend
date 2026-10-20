// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_configuration.*

/**
 * @brief 表示控制台格式化器的基础选项。
 */
public open class ConsoleFormatterOptions <: IConfigurationBinding {
    /**
     * @brief 获取或设置日志时间戳格式。
     */
    public var timestampFormat: ?String = None
    /**
     * @brief 获取或设置是否使用 UTC 时间戳。
     */
    public var useUtcTimestamp: Bool = false

    /**
     * @brief 使用配置源绑定当前选项。
     * @param configuration 用于绑定的配置源。
     */
    public open func configure(configuration: IConfiguration): Unit {
        configuration.bind(this)
    }

    /**
     * @brief 按成员名写入绑定值。
     * @param name 目标成员名。
     * @param value 已完成类型转换的绑定值。
     */
    public open func bind(name: String, value: Any): Unit {
        if (name == "timestampFormat" && let value: ?String <- value) {
            timestampFormat = value
            return
        }
        if (name == "useUtcTimestamp" && let value: Bool <- value) {
            useUtcTimestamp = value
        }
    }
}
