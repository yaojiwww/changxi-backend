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
 * @brief 描述 json 控制台格式化输出选项。
 */
public class JsonWriterOptions <: IConfigurationBinding {
    /**
     * @brief 输出格式化时传递给 toJsonString 的深度参数。
     */
    public var depth: Int64 = 0

    /**
     * @brief 缩进字符串。
     */
    public var indent: String = "  "

    /**
     * @brief 是否将左花括号与字段内容分行输出。
     */
    public var bracketInNewLine: Bool = false

    /**
     * @brief 使用配置源绑定当前选项。
     * @param configuration 用于绑定的配置源。
     */
    public func configure(configuration: IConfiguration): Unit {
        configuration.bind(this)
    }

    /**
     * @brief 按成员名写入绑定值。
     * @param name 目标成员名。
     * @param value 已完成类型转换的绑定值。
     */
    public func bind(name: String, value: Any): Unit {
        if (name == "depth" && let value: Int64 <- value) {
            depth = value
            return
        }
        if (name == "indent" && let value: String <- value) {
            indent = value
            return
        }
        if (name == "bracketInNewLine" && let value: Bool <- value) {
            bracketInNewLine = value
        }
    }
}
