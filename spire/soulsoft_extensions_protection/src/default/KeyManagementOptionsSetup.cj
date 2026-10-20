// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import soulsoft_extensions_options.*

/**
 * @brief 提供密钥管理选项默认初始化实现。
 */
public class KeyManagementOptionsSetup <: IConfigureOptions<KeyManagementOptions>{
    /**
     * @brief 配置密钥管理默认选项。
     * @param options 需要初始化的密钥管理选项。
     */
    public func configure(options: KeyManagementOptions): Unit {
        options.authenticatedEncryptorFactories.add(AuthenticatedEncryptorFactory())
    }   
}
