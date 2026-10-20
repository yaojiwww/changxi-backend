// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

/**
 * @brief 定义协议配置管理器接口。
 */
public interface IConfigurationManager<T> where T <: Object {
    /**
     * @brief 请求刷新当前配置缓存。
     */
    func requestRefresh(): Unit

    /**
     * @brief 获取当前有效配置。
     * @return 返回当前配置对象。
     */
    func getConfiguration(): T
}
