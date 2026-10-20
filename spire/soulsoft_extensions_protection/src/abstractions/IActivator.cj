// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义按类型名创建实例的激活器接口。
 */
public interface IActivator {
    /**
     * @brief 根据限定类型名创建实例。
     * @param qualifiedName 类型的限定名称。
     * @return 返回创建出的实例。
     */
    func createInstance(qualifiedName: String): Any
}
