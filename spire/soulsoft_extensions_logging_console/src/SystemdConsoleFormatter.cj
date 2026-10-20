// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.time.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*

class SystemdConsoleFormatter <: ConsoleFormatter {
    public init(options: IOptionsMonitor<ConsoleFormatterOptions>) {
        super(ConsoleFormatterNames.Systemd)
        _options = options
    }

    private let _options: IOptionsMonitor<ConsoleFormatterOptions>

    private prop formatterOptions: ConsoleFormatterOptions {
        get() {
            _options.currentValue
        }
    }

    public override func format<TState>(logEntry: LogEntry<TState>): String where TState <: ToString {
        let options = formatterOptions
        let sb = StringBuilder()
        sb.append("${pri(logEntry.logLevel)}")
        if (options.timestampFormat.isSome()) {
            sb.append(getStamp(options))
        }
        sb.append(logEntry.category)
        sb.append("[")
        sb.append(logEntry.eventId.id)
        sb.append("] ")
        let message = logEntry.formatter(logEntry.state, logEntry.exception)
        let hasMessage = shouldWriteMessage(message, logEntry.exception)
        if (hasMessage) {
            sb.append(message.replace("\n", " "))
        }
        if (let Some(ex) <- logEntry.exception) {
            if (hasMessage) {
                sb.append(" ")
            }
            sb.append(ExceptionTextFormatter.shared.format(Some(ex)).replace("\n", " "))
        }
        sb.append("\n")
        sb.toString()
    }

    private func pri(logLevel: LogLevel): String {
        if (logLevel == LogLevel.Info) {
            return "<6>"
        }
        if (logLevel == LogLevel.Warn) {
            return "<4>"
        }
        if (logLevel == LogLevel.Error) {
            return "<3>"
        }
        if (logLevel == LogLevel.Fatal) {
            return "<2>"
        }
        "<7>"
    }

    private func getStamp(options: ConsoleFormatterOptions): String {
        let dt = if (options.useUtcTimestamp) {
            DateTime.nowUTC()
        } else {
            DateTime.now()
        }
        if (let Some(format) <- options.timestampFormat) {
            return dt.format(format)
        }
        dt.toString()
    }
}
