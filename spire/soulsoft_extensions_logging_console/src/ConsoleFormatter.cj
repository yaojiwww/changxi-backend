// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_logging.*

/**
 * @brief 表示控制台格式化器基类。
 */
public abstract class ConsoleFormatter {
    private let _name: String

    /**
     * @brief 创建一个指定名称的格式化器。
     * @param name 格式化器名称。
     */
    protected init(name: String) {
        _name = name
    }

    /**
     * @brief 获取格式化器名称。
     * @return 当前格式化器名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 将日志条目格式化为字符串。
     * @param logEntry 待格式化的日志条目。
     * @return 格式化后的日志文本。
     */
    public func format<TState>(logEntry: LogEntry<TState>): String where TState <: ToString

    /**
     * @brief 判断是否需要单独输出日志消息文本。
     * @details 当 message 与 exception.message 完全相同时，返回 false，避免控制台重复打印同一异常消息。
     */
    protected func shouldWriteMessage(message: String, exception: ?Exception): Bool {
        if (message.isEmpty()) {
            return false
        }
        if (let Some(ex) <- exception) {
            if (!ex.message.isEmpty() && message == ex.message) {
                return false
            }
        }
        return true
    }
}
