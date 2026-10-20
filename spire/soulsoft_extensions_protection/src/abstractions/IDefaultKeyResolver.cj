// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义默认密钥解析器接口。
 */
public interface IDefaultKeyResolver {
    /**
     * @brief 从密钥集合中解析默认密钥和回退密钥。
     * @param keys 可供选择的密钥集合。
     * @return 返回默认密钥解析结果。
     */
    func resolve(keys: Collection<IKey>): DefaultKeyResolution
}
