// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 封装消息模板及参数，用于日志格式化。
 */
struct FormattedLogValues <: ToString {
    private let _format: ?String
    private let _values: Array<ToString>
    private static let NullFormat = '[null]'

    public init(format: ?String, values: Array<ToString>) {
        _format = format
        _values = values
    }

    public func toString() {
        // 由于cangjie没有C#里的{v:format}能力，暂时不支持values
        _format ?? NullFormat
    }
}
