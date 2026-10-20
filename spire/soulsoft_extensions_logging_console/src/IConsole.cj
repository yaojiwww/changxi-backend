// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

/**
 * @brief 表示控制台输出接口。
 */
public interface IConsole {
    /**
     * @brief 输出一条消息。
     * @param message 要写入的消息文本。
     */
    func write(message: String): Unit
}
