// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.collection.*

/**
 * @brief 表示日志过滤配置。
 */
public class LoggerFilterOptions {
    private var _minLevel = LogLevel.Trace
    private let _rules = ArrayList<LoggerFilterRule>()

    /**
     * @brief 获取或修改全局最低日志级别。
     */
    public mut prop minLevel: LogLevel {
        get() {
            _minLevel
        }
        set(value) {
            _minLevel = value
        }
    }

    /**
     * @brief 获取日志过滤规则列表。
     * @return 返回当前规则列表。
     */
    public prop rules: ArrayList<LoggerFilterRule> {
        get() {
            _rules
        }
    }
}
