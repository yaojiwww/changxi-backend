// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

import std.time.*

/**
 * @brief 定义令牌重放缓存接口。
 */
public interface ITokenReplayCache {
    /**
     * @brief 将令牌写入重放缓存。
     * @param token 要缓存的令牌字符串。
     * @param expires 该令牌的过期时间。
     * @return 写入成功时返回 `true`。
     */
    func add(token: String, expires: DateTime): Bool
    /**
     * @brief 检查令牌是否已存在于重放缓存中。
     * @param token 要检查的令牌字符串。
     * @return 缓存中存在该令牌时返回 `true`。
     */
    func contains(token: String): Bool
}
