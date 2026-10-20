// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_options.exceptions

import std.collection.*

/**
 * @brief 表示聚合多个异常的异常类型。
 */
public class AggregateException <: Exception {
    /**
     * @brief 保存聚合的异常集合。
     */
    public let exceptions: Collection<Exception>

    /**
     * @brief 创建聚合异常实例。
     * @param exceptions 需要聚合的异常集合。
     */
    public init(exceptions: Collection<Exception>) {
        super(buildMessage(exceptions))
        this.exceptions = exceptions
    }

    private static func buildMessage(exceptions: Collection<Exception>): String {
        let header = "Multiple exceptions occurred (${exceptions.size}):"
        return header + "\r\n" + String.join(exceptions |> map { e => e.message } |> collectArray, delimiter: "\r\n")
    }
}
