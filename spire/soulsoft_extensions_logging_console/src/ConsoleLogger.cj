// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_logging.*

class ConsoleLogger <: ILogger {
    private let _categoryName: String
    private let _processor: ConsoleLoggerProcessor
    private let _formatter: ConsoleFormatter
    private let _options: ConsoleLoggerOptions

    init(categoryName: String, processor: ConsoleLoggerProcessor, formatter: ConsoleFormatter,
        options: ConsoleLoggerOptions) {
        _categoryName = categoryName
        _processor = processor
        _formatter = formatter
        _options = options
    }

    public func log<TState>(logLevel: LogLevel, eventId: EventId, state: TState, exception: ?Exception,
        formatter: (TState, ?Exception) -> String): Unit where TState <: ToString {
        if (!isEnabled(logLevel)) {
            return
        }

        let entry = LogEntry<TState>(logLevel, _categoryName, eventId, state, exception, formatter)
        let message = _formatter.format<TState>(entry)
        if (message.isEmpty()) {
            return
        }

        _processor.enqueue(LogMessageEntry(message, logAsError: logToStandardError(logLevel)))
    }

    private func logToStandardError(logLevel: LogLevel): Bool {
        return logLevel >= _options.logToStandardErrorThreshold
    }
}
