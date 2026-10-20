// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_options

/**
 * @brief 定义选项监视缓存接口。
 */
public interface IOptionsMonitorCache<TOptions> where TOptions <: Object {
    /**
     * @brief 获取指定名称的缓存项，不存在时创建并加入缓存。
     * @param name 选项名称。
     * @param createOptions 用于创建选项值的回调。
     * @return 返回缓存中的选项值。
     */
    func getOrAdd(name: String, createOptions: () -> TOptions): TOptions
}
