// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

/**
 * @brief 表示控制台颜色策略。
 */
public enum LoggerColorBehavior <: Equatable<LoggerColorBehavior> {
    /**
     * @brief 使用默认颜色策略。
     */
    Default
    /**
     * @brief 启用颜色输出。
     */
    | Enabled
    /**
     * @brief 禁用颜色输出。
     */
    | Disabled

    /**
     * @brief 判断两个颜色策略是否相等。
     * @param that 另一个颜色策略。
     * @return 两个值是否相等。
     */
    public operator func ==(that: LoggerColorBehavior): Bool {
        return match ((this, that)) {
            case (Default, Default) => true
            case (Enabled, Enabled) => true
            case (Disabled, Disabled) => true
            case _ => false
        }
    }
}
