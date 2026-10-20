// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 表示日志输出级别。
 */
public enum LogLevel <: Comparable<LogLevel> & ToString {
    /**
     * @brief 表示跟踪级日志。
     */
    Trace
    /**
     * @brief 表示调试级日志。
     */
    | Debug
    /**
     * @brief 表示信息级日志。
     */
    | Info
    /**
     * @brief 表示警告级日志。
     */
    | Warn
    /**
     * @brief 表示错误级日志。
     */
    | Error
    /**
     * @brief 表示致命级日志。
     */
    | Fatal
    /**
     * @brief 表示关闭日志输出。
     */
    | Off

    /**
     * @brief 比较两个日志级别的大小关系。
     * @param right 要比较的另一个日志级别。
     * @return 返回比较结果。
     */
    public func compare(right: LogLevel): Ordering {
        let leftValue = this.value()
        let rightValue = right.value()
        if (leftValue == rightValue) {
            Ordering.EQ
        } else if (leftValue > rightValue) {
            Ordering.GT
        } else {
            Ordering.LT
        }
    }

    /**
     * @brief 返回当前日志级别的字符串表示。
     * @return 返回日志级别名称。
     */
    public func toString(): String {
        return match (this) {
            case Trace => "Trace"
            case Debug => "Debug"
            case Info => "Info"
            case Warn => "Warn"
            case Error => "Error"
            case Fatal => "Fatal"
            case Off => "Off"
        }
    }

    private func value() {
        return match (this) {
            case Trace => 0
            case Debug => 1
            case Info => 2
            case Warn => 3
            case Error => 4
            case Fatal => 5
            case Off => 6
        }
    }
}
