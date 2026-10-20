// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

/**
 * @brief 提供静态配置管理器实现。
 */
public class StaticConfigurationManager<T> <: IConfigurationManager<T> where T <: Object {
    /**
     * @brief 创建静态配置管理器。
     * @param configuration 需要固定返回的配置对象。
     */
    public StaticConfigurationManager(private let configuration: T) {
    }

    /**
     * @brief 返回静态配置对象。
     * @return 返回当前配置对象。
     */
    public func getConfiguration(): T {
        return configuration
    }

    /**
     * @brief 请求刷新静态配置。
     * @note 静态配置管理器不会执行实际刷新。
     */
    public func requestRefresh(): Unit {
    }
}
