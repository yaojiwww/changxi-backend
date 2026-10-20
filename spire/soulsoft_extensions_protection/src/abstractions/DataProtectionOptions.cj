// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 表示数据保护基础配置选项。
 */
public class DataProtectionOptions {
    /**
     * @brief 指定当前应用的数据保护隔离标识。
     */
    public var applicationDiscriminator: ?String = None
}
