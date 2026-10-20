// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 表示默认密钥解析结果。
 */
public struct DefaultKeyResolution {
    /**
     * @brief 创建默认密钥解析结果。
     * @param defaultKey 当前选中的默认密钥。
     * @param fallbackKey 默认密钥不可用时的回退密钥。
     */
    public DefaultKeyResolution(public let defaultKey: ?IKey, public let fallbackKey: ?IKey) {
    }
}
