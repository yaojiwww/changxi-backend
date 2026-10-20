// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import std.reflect.*

extend LoggingBuilder {
    /**
     * @brief 设置全局最低日志级别。
     * @param level 全局最低级别。
     * @return 返回当前构建器。
     */
    public func setMinimumLevel(level: LogLevel): LoggingBuilder {
        services.addSingleton<IConfigureOptions<LoggerFilterOptions>, DefaultLoggerLevelConfigureOptions>(
            DefaultLoggerLevelConfigureOptions(level))
        return this
    }

    /**
     * @brief 注册日志提供程序。
     * @param provider 要注册的提供程序实例。
     * @return 返回当前构建器。
     */
    public func addProvider(provider: ILoggerProvider) {
        services.addSingleton<ILoggerProvider>(provider)
        return this
    }

    /**
     * @brief 清除已注册的日志提供程序。
     * @return 返回当前构建器。
     */
    public func clearProviders() {
        services.removeIf { descriptor =>
            descriptor.serviceType == TypeInfo.of<ILoggerProvider>()
        }
        return this
    }

    /**
     * @brief 添加自定义过滤函数。
     * @param filter 判断是否允许输出日志的函数。
     * @return 返回当前构建器。
     */
    public func addFilter(filter: (?String, ?String, LogLevel) -> Bool) {
        configureFilter {
            options => options.addFilter(filter)
        }
    }

    /**
     * @brief 添加按分类和级别过滤的规则。
     * @param categoryLevelFilter 按分类和级别判断是否允许输出的函数。
     * @return 返回当前构建器。
     */
    public func addFilter(categoryLevelFilter: (?String, LogLevel) -> Bool) {
        configureFilter {
            options => options.addFilter(categoryLevelFilter)
        }
    }

    /**
     * @brief 添加仅按级别过滤的规则。
     * @param levelFilter 按级别判断是否允许输出的函数。
     * @return 返回当前构建器。
     */
    public func addFilter(levelFilter: (LogLevel) -> Bool) {
        configureFilter {
            options => options.addFilter(levelFilter)
        }
    }

    /**
     * @brief 添加按分类名和最低级别过滤的规则。
     * @param category 适用的分类名称。
     * @param level 允许输出的最低级别。
     * @return 返回当前构建器。
     */
    public func addFilter(category: ?String, level: LogLevel) {
        configureFilter {
            options => options.addFilter(category, level)
        }
    }

    /**
     * @brief 添加按分类名和级别判断函数过滤的规则。
     * @param category 适用的分类名称。
     * @param levelFilter 按级别判断是否允许输出的函数。
     * @return 返回当前构建器。
     */
    public func addFilter(category: ?String, levelFilter: (LogLevel) -> Bool) {
        configureFilter {
            options => options.addFilter(category, levelFilter)
        }
    }

    private func configureFilter(configureOptions: (LoggerFilterOptions) -> Unit) {
        this.services.configure(configureOptions)
        return this
    }
}
