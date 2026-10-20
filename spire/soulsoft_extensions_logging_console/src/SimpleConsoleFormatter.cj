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

class SimpleConsoleFormatter <: ConsoleFormatter {
    private static let messagePadding = "      "

    public init(options: IOptionsMonitor<SimpleConsoleFormatterOptions>) {
        super(ConsoleFormatterNames.Simple)
        _options = options
    }

    private let _options: IOptionsMonitor<SimpleConsoleFormatterOptions>

    private prop formatterOptions: SimpleConsoleFormatterOptions {
        get() {
            _options.currentValue
        }
    }

    public override func format<TState>(logEntry: LogEntry<TState>): String where TState <: ToString {
        let options = formatterOptions
        let sb = StringBuilder()
        if (options.timestampFormat.isSome()) {
            sb.append(getStamp(options))
        }
        sb.append(levelTag(logEntry.logLevel))
        sb.append(": ")
        sb.append(logEntry.category)
        sb.append("[")
        sb.append(logEntry.eventId.id)
        sb.append("]")
        let message = logEntry.formatter(logEntry.state, logEntry.exception)
        if (shouldWriteMessage(message, logEntry.exception)) {
            sb.append(if (options.singleLine) {
                " "
            } else {
                "\n"
            })
            sb.append(if (options.singleLine) {
                message.replace("\n", " ")
            } else {
                writeMultilineMessage(message)
            })
        }
        if (let Some(ex) <- logEntry.exception) {
            sb.append(if (options.singleLine) {
                " "
            } else {
                "\n"
            })
            let exText = ExceptionTextFormatter.shared.format(Some(ex))
            sb.append(if (options.singleLine) {
                exText.replace("\n", " ")
            } else {
                writeMultilineMessage(exText)
            })
        }
        sb.append("\n")
        sb.toString()
    }

    private func levelTag(logLevel: LogLevel): String {
        let tag = if (logLevel == LogLevel.Trace) {
            "trce"
        } else if (logLevel == LogLevel.Debug) {
            "dbug"
        } else if (logLevel == LogLevel.Info) {
            "info"
        } else if (logLevel == LogLevel.Warn) {
            "warn"
        } else if (logLevel == LogLevel.Error) {
            "fail"
        } else if (logLevel == LogLevel.Fatal) {
            "crit"
        } else {
            "off"
        }
        return if (shouldUseColor()) {
            colorize(tag, colorFor(logLevel))
        } else {
            tag
        }
    }

    private func getStamp(options: SimpleConsoleFormatterOptions): String {
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

    private func shouldUseColor(): Bool {
        return match (formatterOptions.colorBehavior) {
            case LoggerColorBehavior.Disabled => false
            case LoggerColorBehavior.Enabled => true
            case LoggerColorBehavior.Default => true
        }
    }

    private func colorFor(logLevel: LogLevel): String {
        if (logLevel == LogLevel.Trace || logLevel == LogLevel.Debug) {
            return "\u{1b}[37m"
        }
        if (logLevel == LogLevel.Info) {
            return "\u{1b}[32m"
        }
        if (logLevel == LogLevel.Warn) {
            return "\u{1b}[33m"
        }
        if (logLevel == LogLevel.Error) {
            return "\u{1b}[31m"
        }
        if (logLevel == LogLevel.Fatal) {
            return "\u{1b}[91m"
        }
        ""
    }

    private func colorize(text: String, prefix: String): String {
        if (prefix.isEmpty()) {
            return text
        }
        return "${prefix}${text}\u{1b}[0m"
    }

    private func writeMultilineMessage(message: String): String {
        "${messagePadding}${message.replace("\n", "\n${messagePadding}")}"
    }
}
