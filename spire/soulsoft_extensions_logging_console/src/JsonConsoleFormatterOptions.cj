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
 * @brief 表示 json 控制台格式化器选项。
 */
public class JsonConsoleFormatterOptions <: ConsoleFormatterOptions {
    /**
     * @brief 获取或设置 json 序列化输出选项。
     */
    public var jsonWriterOptions: JsonWriterOptions = JsonWriterOptions()

    /**
     * @brief 使用配置源绑定当前选项。
     * @param configuration 用于绑定的配置源。
     */
    public override func configure(configuration: IConfiguration): Unit {
        super.configure(configuration)
        jsonWriterOptions.configure(configuration.getSection("jsonWriterOptions"))
    }

    /**
     * @brief 按成员名写入绑定值。
     * @param name 目标成员名。
     * @param value 已完成类型转换的绑定值。
     */
    public override func bind(name: String, value: Any): Unit {
        super.bind(name, value)
    }
}
