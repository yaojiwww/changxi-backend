// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_http

/**
 * @brief 定义按名称读取值的提供器接口。
 */
public interface IValueProvider {
    /**
     * @brief 获取指定名称的第一个值。
     * @param name 值名称。
     * @return 指定名称的第一个值；如果不存在则返回空。
     */
    func get(name: String): ?String
    /**
     * @brief 获取指定名称的所有值。
     * @param name 值名称。
     * @return 指定名称的所有值集合。
     */
    func getAll(name: String): Collection<String>
}
