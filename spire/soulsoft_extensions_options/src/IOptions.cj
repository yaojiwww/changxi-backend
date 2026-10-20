// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 定义访问选项值的公共接口。
 */
public interface IOptions<TOptions> where TOptions <: Object {
    /**
     * @brief 返回当前选项值。
     */
    prop value: TOptions
}
