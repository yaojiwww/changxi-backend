// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.reflect.*

/**
 * @brief 表示选项验证失败时抛出的异常。
 */
public class OptionsValidationException <: Exception {
    /**
     * @brief 创建选项验证异常。
     * @param optionsName 验证失败的选项名称。
     * @param optionsType 验证失败的选项类型。
     * @param failureMessages 验证失败消息集合。
     */
    public OptionsValidationException(public let optionsName: String, public let optionsType: TypeInfo,
        public let failureMessages: Array<String>) {
        super(String.join(failureMessages, delimiter: "; "))
    }
}
