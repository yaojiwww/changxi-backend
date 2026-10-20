// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义创建数据保护器的提供程序接口。
 */
public interface IDataProtectionProvider {
    /**
     * @brief 创建指定用途链对应的数据保护器。
     * @param purpose 数据保护用途。
     * @return 返回对应用途的数据保护器。
     */
    func createProtector(purpose: String): IDataProtector
}
