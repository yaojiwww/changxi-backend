// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/**
 * @brief 表示一个可释放的服务作用域。
 */
public interface IServiceScope <: Resource {
    /**
     * @brief 返回当前作用域对应的服务提供者。
     * @return 当前作用域使用的服务提供者。
     */
    prop services: IServiceProvider
}
