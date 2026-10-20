// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 提供选项系统的公共静态辅助成员。
 */
public abstract class Options {
    /**
     * @brief 表示默认选项名称。
     */
    public static let defaultName = String.empty

    /**
     * @brief 将选项实例包装为 `IOptions`。
     * @param options 要包装的选项实例。
     * @return 返回包装后的选项对象。
     */
    public static func create<TOptions>(options: TOptions): IOptions<TOptions> where  TOptions <: Object {
        return OptionsWrapper<TOptions>(options)
    }
}
