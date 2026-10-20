// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义密钥环提供程序接口。
 */
public interface IKeyRingProvider {
    /**
     * @brief 获取当前可用的密钥环。
     * @return 返回当前密钥环。
     */
    func getCurrentKeyRing(): IKeyRing
}
