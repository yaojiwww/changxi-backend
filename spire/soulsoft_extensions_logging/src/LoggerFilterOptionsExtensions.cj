// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.collection.*

extend LoggerFilterOptions {
    /**
     * @brief 添加基于提供程序、分类和级别的过滤规则。
     * @param filter 过滤判断函数。
     * @return 返回当前过滤配置。
     */
    public func addFilter(filter: (provider: ?String, category: ?String, logLevel: LogLevel) -> Bool): LoggerFilterOptions {
        return addRule(filter: filter)
    }

    /**
     * @brief 添加基于分类和级别的过滤规则。
     * @param categoryLevelFilter 按分类和级别判断是否允许输出的函数。
     * @return 返回当前过滤配置。
     */
    public func addFilter(categoryLevelFilter: (?String, LogLevel) -> Bool): LoggerFilterOptions {
        return addRule(filter: {_, category, level => categoryLevelFilter(category, level)})
    }

    /**
     * @brief 添加仅基于级别的过滤规则。
     * @param levelFilter 按级别判断是否允许输出的函数。
     * @return 返回当前过滤配置。
     */
    public func addFilter(levelFilter: (LogLevel) -> Bool): LoggerFilterOptions {
        return addRule(filter: {_, _, level => levelFilter(level)})
    }

    /**
     * @brief 添加基于分类名和最低级别的过滤规则。
     * @param category 适用的分类名称。
     * @param level 允许输出的最低级别。
     * @return 返回当前过滤配置。
     */
    public func addFilter(category: ?String, level: ?LogLevel): LoggerFilterOptions {
        return addRule(category: category, level: level)
    }

    /**
     * @brief 添加基于分类名和级别判断函数的过滤规则。
     * @param category 适用的分类名称。
     * @param levelFilter 按级别判断是否允许输出的函数。
     * @return 返回当前过滤配置。
     */
    public func addFilter(category: ?String, levelFilter: (LogLevel) -> Bool): LoggerFilterOptions {
        return addRule(category: category, filter: {_, _, level => levelFilter(level)})
    }

    private func addRule(provider!: ?String = None, category!: ?String = None, level!: ?LogLevel = None,
        filter!: ?(?String, ?String, LogLevel) -> Bool = None) {
        this.rules.add(LoggerFilterRule(provider, category, level, filter))
        return this
    }
}
