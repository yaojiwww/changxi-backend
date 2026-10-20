// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.reflect.*

/**
 * @brief 保存单个提供程序对应的日志记录信息。
 */
class LoggerInformation {
    private let _logger: ILogger
    private let _category: String
    private let _providerType: TypeInfo

    /**
     * @brief 创建日志记录信息。
     * @param provider 对应的日志提供程序。
     * @param category 日志分类名称。
     */
    init(provider: ILoggerProvider, category: String) {
        _logger = provider.createLogger(category)
        _category = category
        _providerType = TypeInfo.of(provider)
    }

    /**
     * @brief 获取日志记录器。
     * @return 返回日志记录器。
     */
    public prop logger: ILogger {
        get() {
            _logger
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
     * @brief 获取提供程序类型。
     * @return 返回提供程序类型。
     */
    public prop providerType: TypeInfo {
        get() {
            _providerType
        }
    }
}

struct MessageLogger {
    private let _logger: ILogger
    private let _category: String
    private let _providerName: String
    private let _minLevel: ?LogLevel
    private let _filter: ?(?String, ?String, LogLevel) -> Bool

    init(logger: ILogger, category: String, providerName: String, minLevel: ?LogLevel,
        filter: ?(?String, ?String, LogLevel) -> Bool) {
        _logger = logger
        _category = category
        _providerName = providerName
        _minLevel = minLevel
        _filter = filter
    }

    public prop logger: ILogger {
        get() {
            _logger
        }
    }

    public func isEnabled(logLevel: LogLevel): Bool {
        if (let Some(minLevel) <- _minLevel && logLevel < minLevel) {
            return false
        }

        if (let Some(filter) <- _filter) {
            return filter(_providerName, _category, logLevel)
        }

        return true
    }
}
