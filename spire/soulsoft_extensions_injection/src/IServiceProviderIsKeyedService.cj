// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

/**
 * @brief 定义检查带键服务是否可解析的能力。
 */
public interface IServiceProviderIsKeyedService <: IServiceProviderIsService {
    /**
     * @brief 检查指定键下的服务类型是否可解析。
     * @param serviceKey 要检查的服务键。
     * @param serviceType 要检查的服务类型。
     * @return 如果该键下的服务可解析则返回 `true`，否则返回 `false`。
     */
    func isKeyedService(serviceKey: String, serviceType: TypeInfo): Bool
}
