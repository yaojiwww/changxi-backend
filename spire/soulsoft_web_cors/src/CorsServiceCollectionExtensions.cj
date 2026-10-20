// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_web_cors.abstractions.*
import soulsoft_web_cors.infrastructure.*

/**
 * @brief 提供向服务集合注册 CORS 服务的扩展约定。
 */
public interface CorsServiceCollectionExtensions {
    /**
     * @brief 向服务集合注册 CORS 服务并配置选项。
     * @param configureOptions 用于配置 CORS 选项的回调。
     * @return 返回当前服务集合。
     */
    func addCors(configureOptions: (CorsOptions) -> Unit): ServiceCollection

    /**
     * @brief 使用默认配置向服务集合注册 CORS 服务。
     * @return 返回当前服务集合。
     */
    func addCors(): ServiceCollection {
        addCors {_ =>}
    }
}

extend ServiceCollection <: CorsServiceCollectionExtensions {
    /**
     * @brief 向服务集合注册 CORS 服务并配置选项。
     * @param configureOptions 用于配置 CORS 选项的回调。
     * @return 返回当前服务集合。
     */
    public func addCors(configureOptions: (CorsOptions) -> Unit): ServiceCollection {
        this.configure<CorsOptions>(configureOptions)
        this.tryAddTransient<ICorsPolicyProvider, CorsPolicyProvider> {
            sp => CorsPolicyProvider(sp.getOrThrow<IOptions<CorsOptions>>())
        }
        this.tryAddSingleton<ICorsService, CorsService> {sp => CorsService(sp.getOrThrow<IOptions<CorsOptions>>())}
        return this
    }
}
