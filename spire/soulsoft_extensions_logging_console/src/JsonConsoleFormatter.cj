// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.time.*
import stdx.encoding.json.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*

class JsonConsoleFormatter <: ConsoleFormatter {
    public init(options: IOptionsMonitor<JsonConsoleFormatterOptions>) {
        super(ConsoleFormatterNames.Json)
        _options = options
    }

    private let _options: IOptionsMonitor<JsonConsoleFormatterOptions>

    private prop formatterOptions: JsonConsoleFormatterOptions {
        get() {
            _options.currentValue
        }
    }

    public override func format<TState>(logEntry: LogEntry<TState>): String where TState <: ToString {
        let options = formatterOptions
        let obj = JsonObject()
        if (options.timestampFormat.isSome()) {
            obj.put("timestamp", JsonString(getStamp(options)))
        }
        obj.put("logLevel", JsonString(logEntry.logLevel.toString()))
        obj.put("category", JsonString(logEntry.category))
        obj.put("eventId", JsonInt(logEntry.eventId.id))
        obj.put("message", JsonString(logEntry.formatter(logEntry.state, logEntry.exception)))
        if (let Some(ex) <- logEntry.exception) {
            obj.put("exception", JsonString(ExceptionTextFormatter.shared.format(Some(ex))))
        }
        if (!options.jsonWriterOptions.bracketInNewLine) {
            return "${obj.toString()}\n"
        }

        // 兼容当前 stdx JSON 运行时的限制：
        // 实际验证中，JsonValue.toJsonString(..., bracketInNewLine: false) 仍然会输出多行内容。
        // 后续如果运行时修正了 bracketInNewLine 的语义，这里应该去掉分支判断，
        // 改为统一按 jsonWriterOptions 调用同一条序列化路径。
        let json = obj.toJsonString(
            options.jsonWriterOptions.depth,
            bracketInNewLine: true,
            indent: options.jsonWriterOptions.indent
        )
        return "${json}\n"
    }

    private func getStamp(options: JsonConsoleFormatterOptions): String {
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
