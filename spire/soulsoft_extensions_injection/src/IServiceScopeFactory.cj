// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/**
 * @brief 定义创建服务作用域的能力。
 */
public interface IServiceScopeFactory {
    /**
     * @brief 创建一个新的服务作用域。
     * @return 新创建的服务作用域。
     */
    func createScope(): IServiceScope
}

