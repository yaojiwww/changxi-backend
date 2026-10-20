// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.collection.*
import soulsoft_extensions_options.exceptions.*

/**
 * @brief 将日志调用分发给已配置提供程序对应的日志记录器。
 */
class Logger <: ILogger {
    private var _loggers: Array<LoggerInformation>
    private var _messageLoggers: Array<MessageLogger>

    init(loggers: Array<LoggerInformation>, messageLoggers: Array<MessageLogger>) {
        _loggers = loggers
        _messageLoggers = messageLoggers
    }

    mut prop loggers: Array<LoggerInformation> {
        get() {
            _loggers
        }
        set(value) {
            _loggers = value
        }
    }

    mut prop messageLoggers: Array<MessageLogger> {
        get() {
            _messageLoggers
        }
        set(value) {
            _messageLoggers = value
        }
    }

    public func isEnabled(logLevel: LogLevel) {
        if (logLevel == LogLevel.Off) {
            return false
        }
        var exceptions: ?ArrayList<Exception> = None
        var enabled = false
        var index = 0
        while (index < _messageLoggers.size) {
            let messageLogger = _messageLoggers[index]
            if (!messageLogger.isEnabled(logLevel)) {
                index++
                continue
            }
            try {
                if (messageLogger.logger.isEnabled(logLevel)) {
                    enabled = true
                    break
                }
            } catch (ex: Exception) {
                if (let Some(exceptions) <- exceptions) {
                    exceptions.add(ex)
                } else {
                    exceptions = ArrayList<Exception>([ex])
                }
            }
            index++
        }
        if (let Some(exceptions) <- exceptions) {
            throw AggregateException(exceptions)
        }
        return enabled
    }

    public func log<TState>(logLevel: LogLevel, eventId: EventId, state: TState, exception: ?Exception,
        formatter: (TState, ?Exception) -> String): Unit where TState <: ToString {
        var exceptions: ?ArrayList<Exception> = None
        var index = 0
        while (index < _messageLoggers.size) {
            let messageLogger = _messageLoggers[index]
            if (!messageLogger.isEnabled(logLevel)) {
                index++
                continue
            }
            try {
                messageLogger.logger.log(logLevel, eventId, state, exception, formatter)
            } catch (ex: Exception) {
                if (let Some(exceptions) <- exceptions) {
                    exceptions.add(ex)
                } else {
                    exceptions = ArrayList<Exception>([ex])
                }
            }
            index++
        }
        if (let Some(exceptions) <- exceptions) {
            throw AggregateException(exceptions)
        }
    }
}
