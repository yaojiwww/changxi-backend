// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_caching

import std.time.*

/**
 * @brief 表示缓存条目的过期配置。
 */
public class DistributedCacheEntryOptions {
    /**
     * @brief 创建缓存条目的过期配置。
     * @param slidingExpiration 相对上次访问时间的滑动过期时长。
     * @param absoluteExpiration 缓存条目的绝对过期时间。
     * @param absoluteExpirationRelativeToNow 相对当前时间的绝对过期时长。
     */
    public DistributedCacheEntryOptions(public var slidingExpiration!: ?Duration = None,
        public var absoluteExpiration!: ?DateTime = None, public var absoluteExpirationRelativeToNow!: ?Duration = None) {
    }
}
