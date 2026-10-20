// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 定义日志记录器的公共接口。
 */
public interface ILogger {
    /**
     * @brief 按指定级别记录日志。
     * @param logLevel 日志级别。
     * @param eventId 事件标识。
     * @param state 日志状态对象。
     * @param exception 关联的异常对象。
     * @param formatter 将状态格式化为字符串的函数。
     */
    func log<TState>(logLevel: LogLevel, eventId: EventId, state: TState, exception: ?Exception,
        formatter: (TState, ?Exception) -> String): Unit where TState <: ToString

    /**
     * @brief 按日志条目记录日志。
     * @param entry 单条日志记录的完整上下文。
     */
    func log<TState>(entry: LogEntry<TState>): Unit where TState <: ToString {
        log(entry.logLevel, entry.eventId, entry.state, entry.exception, entry.formatter)
    }

    /**
     * @brief 按消息记录日志。
     * @param logLevel 日志级别。
     * @param message 日志消息。
     */
    func log(logLevel: LogLevel, message: ?String): Unit {
        log(logLevel, EventId(0), None, message)
    }

    /**
     * @brief 按事件标识和消息记录日志。
     * @param logLevel 日志级别。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func log(logLevel: LogLevel, eventId: EventId, message: ?String): Unit {
        log(logLevel, eventId, None, message)
    }

    /**
     * @brief 按异常和消息记录日志。
     * @param logLevel 日志级别。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func log(logLevel: LogLevel, exception: ?Exception, message: ?String): Unit {
        log(logLevel, EventId(0), exception, message)
    }

    /**
     * @brief 按事件标识、异常和消息记录日志。
     * @param logLevel 日志级别。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func log(logLevel: LogLevel, eventId: EventId, exception: ?Exception, message: ?String): Unit {
        let state = message ?? "[null]"
        log<String>(logLevel, eventId, state, exception, {
            content, _ => content
        })
    }

    /**
     * @brief 检查指定日志级别是否启用。
     * @param logLevel 要检查的日志级别。
     * @return 如果该级别已启用则返回 `true`，否则返回 `false`。
     */
    func isEnabled(logLevel: LogLevel): Bool {
        return logLevel != LogLevel.Off
    }

    /**
     * @brief 记录一条跟踪级别日志。
     * @param message 日志消息。
     */
    func trace(message: ?String): Unit {
        log(LogLevel.Trace, message)
    }

    /**
     * @brief 记录一条带事件标识的跟踪级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func trace(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Trace, eventId, message)
    }

    /**
     * @brief 记录一条带异常的跟踪级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func trace(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Trace, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的跟踪级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func trace(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Trace, eventId, exception, message)
    }

    /**
     * @brief 记录一条调试级别日志。
     * @param message 日志消息。
     */
    func debug(message: ?String): Unit {
        log(LogLevel.Debug, message)
    }

    /**
     * @brief 记录一条带事件标识的调试级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func debug(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Debug, eventId, message)
    }

    /**
     * @brief 记录一条带异常的调试级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func debug(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Debug, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的调试级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func debug(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Debug, eventId, exception, message)
    }

    /**
     * @brief 记录一条信息级别日志。
     * @param message 日志消息。
     */
    func info(message: ?String): Unit {
        log(LogLevel.Info, message)
    }

    /**
     * @brief 记录一条带事件标识的信息级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func info(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Info, eventId, message)
    }

    /**
     * @brief 记录一条带异常的信息级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func info(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Info, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的信息级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func info(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Info, eventId, exception, message)
    }

    /**
     * @brief 记录一条警告级别日志。
     * @param message 日志消息。
     */
    func warn(message: ?String): Unit {
        log(LogLevel.Warn, message)
    }

    /**
     * @brief 记录一条带事件标识的警告级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func warn(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Warn, eventId, message)
    }

    /**
     * @brief 记录一条带异常的警告级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func warn(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Warn, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的警告级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func warn(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Warn, eventId, exception, message)
    }

    /**
     * @brief 记录一条错误级别日志。
     * @param message 日志消息。
     */
    func error(message: ?String): Unit {
        log(LogLevel.Error, message)
    }

    /**
     * @brief 记录一条带事件标识的错误级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func error(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Error, eventId, message)
    }

    /**
     * @brief 记录一条带异常的错误级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func error(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Error, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的错误级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func error(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Error, eventId, exception, message)
    }

    /**
     * @brief 记录一条致命级别日志。
     * @param message 日志消息。
     */
    func fatal(message: ?String): Unit {
        log(LogLevel.Fatal, message)
    }

    /**
     * @brief 记录一条带事件标识的致命级别日志。
     * @param eventId 事件标识。
     * @param message 日志消息。
     */
    func fatal(eventId: EventId, message: ?String): Unit {
        log(LogLevel.Fatal, eventId, message)
    }

    /**
     * @brief 记录一条带异常的致命级别日志。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func fatal(exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Fatal, exception, message)
    }

    /**
     * @brief 记录一条带事件标识和异常的致命级别日志。
     * @param eventId 事件标识。
     * @param exception 关联的异常对象。
     * @param message 日志消息。
     */
    func fatal(eventId: EventId, exception: ?Exception, message: ?String): Unit {
        log(LogLevel.Fatal, eventId, exception, message)
    }
}
