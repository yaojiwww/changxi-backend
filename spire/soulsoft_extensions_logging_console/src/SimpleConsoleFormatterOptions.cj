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
 * @brief 表示 simple 控制台格式化器选项。
 */
public class SimpleConsoleFormatterOptions <: ConsoleFormatterOptions {
    /**
     * @brief 获取或设置颜色策略。
     */
    public var colorBehavior: LoggerColorBehavior = LoggerColorBehavior.Default
    /**
     * @brief 获取或设置是否单行输出。
     */
    public var singleLine: Bool = false

    /**
     * @brief 使用配置源绑定当前选项。
     * @param configuration 用于绑定的配置源。
     */
    public override func configure(configuration: IConfiguration): Unit {
        configuration.bind(this)
    }

    /**
     * @brief 按成员名写入绑定值。
     * @param name 目标成员名。
     * @param value 已完成类型转换的绑定值。
     */
    public override func bind(name: String, value: Any): Unit {
        super.bind(name, value)
        if (name == "colorBehavior" && let value: LoggerColorBehavior <- value) {
            colorBehavior = value
            return
        }
        if (name == "singleLine" && let value: Bool <- value) {
            singleLine = value
        }
    }
}
