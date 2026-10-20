// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 提供 `IOptions` 的简单包装实现。
 */
public class OptionsWrapper<TOptions> <: IOptions<TOptions> where TOptions <: Object {
    private let _value: TOptions

    /**
     * @brief 创建选项包装实例。
     * @param options 要包装的选项实例。
     */
    public init(options: TOptions) {
        _value = options
    }

    /**
     * @brief 返回当前包装的选项值。
     * @return 返回当前包装的选项值。
     */
    public prop value: TOptions {
        get() {
            _value
        }
    }
}
