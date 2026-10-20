// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_protection.abstractions.*

/**
 * @brief 定义数据保护服务注册扩展接口。
 */
public interface DataProtectionServiceCollectionExtensions {
    /**
     * @brief 使用默认选项注册数据保护服务。
     * @return 返回数据保护构建器。
     */
    func addDataProtection(): DataProtectionBuilder {
        addDataProtection {_ =>}
    }

    /**
     * @brief 注册数据保护服务并配置数据保护选项。
     * @param configureOptions 用于配置数据保护选项的委托。
     * @return 返回数据保护构建器。
     */
    func addDataProtection(configureOptions: (DataProtectionOptions) -> Unit): DataProtectionBuilder
}

extend ServiceCollection <: DataProtectionServiceCollectionExtensions {
    /**
     * @brief 注册数据保护核心服务并返回构建器。
     * @param configureOptions 用于配置数据保护选项的委托。
     * @return 返回数据保护构建器。
     */
    public func addDataProtection(configureOptions: (DataProtectionOptions) -> Unit): DataProtectionBuilder {
        this.configure(configureOptions)
        this.tryAddSingleton<IKeyRing, KeyRing>()
        this.tryAddSingleton<IActivator, Activator>()
        this.tryAddSingleton<IKeyManager, KeyManager>()
        this.tryAddSingleton<IKeyRingProvider, KeyRingProvider>()
        this.tryAddSingleton<IDefaultKeyResolver, DefaultKeyResolver>()
        this.tryAddSingleton<IDataProtectionProvider, KeyRingDataProtectionProvider>()
        this.addOptions<KeyManagementOptions>()
        this.addSingleton<IConfigureOptions<KeyManagementOptions>, KeyManagementOptionsSetup>()
        return DataProtectionBuilder(this)
    }
}
