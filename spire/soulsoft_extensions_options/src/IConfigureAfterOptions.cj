// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 定义在基础配置之后执行附加配置的接口。
 */
public interface IConfigureAfterOptions<TOptions> where TOptions <: Object {
    /**
     * @brief 在基础配置完成后配置指定名称的选项实例。
     * @param name 选项名称。
     * @param options 待配置的选项实例。
     */
    func configureAfter(name: ?String, options: TOptions): Unit
}


