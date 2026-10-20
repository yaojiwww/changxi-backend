// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 定义创建选项实例的工厂接口。
 */
public interface IOptionsFactory<TOptions> where TOptions <: Object {
    /**
     * @brief 按名称创建选项实例。
     * @param name 选项名称。
     * @return 返回创建得到的选项实例。
     */
    func create(name: String): TOptions
}
