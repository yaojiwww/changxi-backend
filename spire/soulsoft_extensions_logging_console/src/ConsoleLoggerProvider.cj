// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.sync.*
import std.collection.concurrent.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_logging.annotations.*

/**
 * @brief 提供控制台日志记录器实例。
 */
@ProviderAlias["console"]
public class ConsoleLoggerProvider <: ILoggerProvider {
    private let _isClosed = AtomicBool(false)
    private let _processor: ConsoleLoggerProcessor
    private let _loggers: ConcurrentHashMap<String, ConsoleLogger>
    private let _formatters: ConcurrentHashMap<String, ConsoleFormatter>
    private let _options: IOptionsMonitor<ConsoleLoggerOptions>

    /**
     * @brief 创建控制台日志提供程序。
     * @param options 控制台日志公共选项监视器。
     * @param formatters 已注册的格式化器集合。
     */
    public init(options: IOptionsMonitor<ConsoleLoggerOptions>, formatters: Collection<ConsoleFormatter>) {
        _options = options
        _loggers = ConcurrentHashMap<String, ConsoleLogger>()
        _formatters = createFormatters(formatters)
        _processor = ConsoleLoggerProcessor(
            createConsole(stdErr: false),
            createConsole(stdErr: true),
            _options.currentValue.queueFullMode,
            _options.currentValue.maxQueueLength
        )
    }

    protected init(options: IOptionsMonitor<ConsoleLoggerOptions>, formatters: Collection<ConsoleFormatter>,
        console: IConsole, errorConsole: IConsole) {
        _options = options
        _loggers = ConcurrentHashMap<String, ConsoleLogger>()
        _formatters = createFormatters(formatters)
        _processor = ConsoleLoggerProcessor(
            console,
            errorConsole,
            _options.currentValue.queueFullMode,
            _options.currentValue.maxQueueLength
        )
    }

    /**
     * @brief 创建或返回指定分类的日志记录器。
     * @param categoryName 日志分类名称。
     * @return 对应分类的日志记录器。
     */
    public func createLogger(categoryName: String): ILogger {
        if (let Some(logger) <- _loggers.get(categoryName)) {
            return logger
        }

        return _loggers.entryView(categoryName) {
            view => if (view.value.isNone()) {
                view.value = ConsoleLogger(categoryName, _processor, getFormatter(), _options.currentValue)
            }
        }.getOrThrow()
    }

    /**
     * @brief 关闭当前提供程序。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            _processor.dispose()
        }
    }

    /**
     * @brief 判断当前提供程序是否已关闭。
     * @return 当前提供程序是否已关闭。
     */
    public func isClosed(): Bool {
        _isClosed.load()
    }

    private static func createConsole(stdErr!: Bool): IConsole {
        let writer = ConsoleWriter(stdErr: stdErr)
        return AnsiLogConsole(writer)
    }

    private func getFormatter(): ConsoleFormatter {
        let formatterName = normalizeFormatterName(_options.currentValue.formatterName)
        if (let Some(name) <- formatterName) {
            if (let Some(formatter) <- _formatters.get(name)) {
                return formatter
            }
        }
        let defaultFormatter = _formatters.get(ConsoleFormatterNames.Simple.toAsciiLower())
        if (let Some(formatter) <- defaultFormatter) {
            return formatter
        }
        throw UnsupportedException("Console formatter '${ConsoleFormatterNames.Simple}' is not registered.")
    }

    private static func createFormatters(formatters: Collection<ConsoleFormatter>): ConcurrentHashMap<String,
        ConsoleFormatter> {
        let map = ConcurrentHashMap<String, ConsoleFormatter>()
        for (formatter in formatters) {
            map[formatter.name.toAsciiLower()] = formatter
        }
        return map
    }

    private static func normalizeFormatterName(formatterName: ?String): ?String {
        if (let Some(name) <- formatterName) {
            return Some(name.trimAscii().toAsciiLower())
        }
        return Some(ConsoleFormatterNames.Simple.toAsciiLower())
    }

}
