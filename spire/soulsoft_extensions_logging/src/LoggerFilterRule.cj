// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 表示一条日志过滤规则。
 */
public class LoggerFilterRule <: ToString {
    private let _providerName: ?String
    private let _categoryName: ?String
    private let _logLevel: ?LogLevel
    private let _filter: ?(?String, ?String, LogLevel) -> Bool

    /**
     * @brief 创建一条基于提供程序、分类和级别的过滤规则。
     * @param providerName 适用的日志提供程序名称。
     * @param categoryName 适用的日志分类名称。
     * @param logLevel 允许输出的最低日志级别。
     * @param filter 自定义过滤判断函数。
     */
    public init(providerName: ?String, categoryName: ?String, logLevel: ?LogLevel,
        filter: ?(?String, ?String, LogLevel) -> Bool) {
        _providerName = providerName
        _categoryName = categoryName
        _logLevel = logLevel
        _filter = filter
    }

    /**
     * @brief 返回当前规则绑定的自定义过滤器。
     * @return 返回当前规则绑定的自定义过滤器；如果未设置则返回 None。
     */
    public prop filter: ?(?String, ?String, LogLevel) -> Bool {
        get() {
            _filter
        }
    }

    /**
     * @brief 返回当前规则限制的最低日志级别。
     * @return 返回当前规则限制的最低日志级别；如果未设置则返回 None。
     */
    public prop logLevel: ?LogLevel {
        get() {
            _logLevel
        }
    }

    /**
     * @brief 返回当前规则适用的日志分类名称。
     * @return 返回当前规则适用的日志分类名称；如果未设置则返回 None。
     */
    public prop categoryName: ?String {
        get() {
            _categoryName
        }
    }

    /**
     * @brief 返回当前规则适用的日志提供程序名称。
     * @return 返回当前规则适用的日志提供程序名称；如果未设置则返回 None。
     */
    public prop providerName: ?String {
        get() {
            _providerName
        }
    }

    /**
     * @brief 返回当前日志过滤规则的字符串表示。
     * @return 返回规则的字符串形式。
     */
    public func toString(): String {
        let filterStr = if (filter.isSome()) {
            "<filter>"
        } else {
            "None"
        }
        return "providerName: '${providerName}', categoryName: '${categoryName}', logLevel: '${logLevel}', filter: '${filterStr}'"
    }
}
