// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/**
 * @brief 定义通过服务提供者创建实例的工厂协议。
 */
public interface IServiceFactory<T> {
    /**
     * @brief 使用服务提供者创建一个实例。
     * @param sp 用于解析依赖的服务提供者。
     * @return 创建得到的实例。
     */
    static func createInstance(sp: IServiceProvider): T
}
