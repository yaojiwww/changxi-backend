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
 * @brief 定义检查服务类型是否可解析的能力。
 */
public interface IServiceProviderIsService {
    /**
     * @brief 检查指定运行时类型是否已注册为可解析服务。
     * @param serviceType 要检查的服务类型。
     * @return 如果该类型可解析则返回 `true`，否则返回 `false`。
     */
    func isService(serviceType: TypeInfo): Bool

    /**
     * @brief 检查指定泛型类型是否已注册为可解析服务。
     * @return 如果该类型可解析则返回 `true`，否则返回 `false`。
     */
    func isService<T>(): Bool {
        return isService(TypeInfo.of<T>())
    }
}
