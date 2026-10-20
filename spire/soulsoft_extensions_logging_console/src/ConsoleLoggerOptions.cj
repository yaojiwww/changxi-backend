// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_logging.*

/**
 * @brief 控制台日志公共选项。
 */
public class ConsoleLoggerOptions {
    /**
     * @brief 获取或设置当前使用的格式化器名称。
     */
    public var formatterName: ?String = None
    /**
     * @brief 获取或设置队列满时的处理模式。
     */
    public var queueFullMode: ConsoleLoggerQueueFullMode = ConsoleLoggerQueueFullMode.Wait
    /**
     * @brief 获取或设置队列最大长度。
     */
    public var maxQueueLength: Int64 = 2500
    /**
     * @brief 获取或设置写入标准错误流的最小日志级别。
     */
    public var logToStandardErrorThreshold: LogLevel = LogLevel.Off
}
