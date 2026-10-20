// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 定义按名称访问选项值的监视接口。
 */
public interface IOptionsMonitor<TOptions> where TOptions <: Object {
    /**
     * @brief 返回默认名称对应的当前选项值。
     */
    prop currentValue: TOptions

    /**
     * @brief 按名称获取选项值。
     * @param name 选项名称。
     * @return 返回对应名称的选项值。
     */
    func get(name: String): TOptions
}
