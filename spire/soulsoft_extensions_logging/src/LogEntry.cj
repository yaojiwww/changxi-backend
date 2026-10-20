// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 封装单条日志记录的上下文信息。
 */
public struct LogEntry<TState> {
    private let _logLevel: LogLevel
    private let _category: String
    private let _eventId: EventId
    private let _state: TState
    private let _exception: ?Exception
    private let _formatter: (TState, ?Exception) -> String

    /**
     * @brief 创建一条日志记录上下文。
     * @param logLevel 日志级别。
     * @param category 日志分类名称。
     * @param eventId 事件标识。
     * @param state 日志状态对象。
     * @param exception 关联的异常对象。
     * @param formatter 将状态格式化为字符串的函数。
     */
    public init(logLevel: LogLevel, category: String, eventId: EventId, state: TState, exception: ?Exception,
        formatter: (TState, ?Exception) -> String) {
        _logLevel = logLevel
        _category = category
        _eventId = eventId
        _state = state
        _exception = exception
        _formatter = formatter
    }

    /**
     * @brief 获取日志级别。
     * @return 返回日志级别。
     */
    public prop logLevel: LogLevel {
        get() {
            _logLevel
        }
    }

    /**
     * @brief 获取日志分类名称。
     * @return 返回日志分类名称。
     */
    public prop category: String {
        get() {
            _category
        }
    }

    /**
     * @brief 获取事件标识。
     * @return 返回事件标识。
     */
    public prop eventId: EventId {
        get() {
            _eventId
        }
    }

    /**
     * @brief 获取日志状态对象。
     * @return 返回日志状态对象。
     */
    public prop state: TState {
        get() {
            _state
        }
    }

    /**
     * @brief 获取关联的异常对象。
     * @return 返回关联的异常对象；如果未设置则返回 `None`。
     */
    public prop exception: ?Exception {
        get() {
            _exception
        }
    }

    /**
     * @brief 获取日志格式化函数。
     * @return 返回用于格式化日志状态的函数。
     */
    public prop formatter: (TState, ?Exception) -> String {
        get() {
            _formatter
        }
    }
}
