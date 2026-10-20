// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_logging

import soulsoft_extensions_options.*

/**
 * @brief 配置默认日志最低级别。
 */
class DefaultLoggerLevelConfigureOptions <: IConfigureOptions<LoggerFilterOptions> {
    private let _level: LogLevel

    /**
     * @brief 使用指定最低级别创建配置项。
     * @param level 默认最低日志级别。
     */
    public init(level: LogLevel) {
        _level = level
    }

    /**
     * @brief 将默认最低级别写入过滤配置。
     * @param options 日志过滤配置。
     */
    public func configure(options: LoggerFilterOptions): Unit {
        options.minLevel = _level
    }
}
