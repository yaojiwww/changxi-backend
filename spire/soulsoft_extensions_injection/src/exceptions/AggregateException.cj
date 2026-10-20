// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection.exceptions

import std.collection.*

/**
 * @brief 表示聚合了多个异常的错误。
 */
public class AggregateException <: Exception {
    /**
     * @brief 返回当前聚合异常中包含的异常集合。
     */
    public let exceptions: Collection<Exception>

    /**
     * @brief 创建一个聚合异常实例。
     * @param message 聚合异常的摘要消息。
     * @param exceptions 要聚合的异常集合。
     */
    public init(message: String, exceptions: Collection<Exception>) {
        super(buildMessage(message, exceptions))
        this.exceptions = exceptions
    }

    private static func buildMessage(message: String, exceptions: Collection<Exception>) {
        message + "\r\n" + String.join(exceptions |> map { e => e.message } |> collectArray, delimiter: "\r\n")
    }
}
