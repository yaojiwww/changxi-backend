// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_caching

/**
 * @brief 表示分布式缓存的全局配置选项。
 */
public class DistributedCacheOptions {
    private var _expirationScanFrequency = Duration.minute

    /**
     * @brief 创建默认的分布式缓存配置。
     */
    public init() {
    }

    /**
     * @brief 获取或设置过期缓存项的扫描频率。
     */
    public mut prop expirationScanFrequency: Duration {
        get() {
            _expirationScanFrequency
        }
        set(value) {
            _expirationScanFrequency = value
        }
    }
}
