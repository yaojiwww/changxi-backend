// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示安全密钥的抽象基类。
 * @description 每个密钥实例持有一个 `CryptoProviderFactory` 引用，上层组件可按需替换工厂以注入自定义加密实现。
 */
public abstract class SecurityKey {
    private var _cryptoProviderFactory: CryptoProviderFactory = CryptoProviderFactory.default

    /**
     * @brief 获取密钥标识符。
     * @return 当前密钥的唯一标识；未设置时返回 `None`。
     */
    public prop keyId: ?String

    /**
     * @brief 获取密钥位长度。
     * @return 密钥长度，单位为位。
     */
    public prop keySize: Int64

    /**
     * @brief 获取或设置与该密钥关联的加密工厂。
     * @description 默认使用全局工厂实例，也可替换为自定义工厂以注入不同的缓存策略或密钥实现。
     */
    public mut prop cryptoProviderFactory: CryptoProviderFactory {
        get() {
            _cryptoProviderFactory
        }
        set(value) {
            _cryptoProviderFactory = value
        }
    }

    /**
     * @brief 判断当前密钥是否支持指定算法。
     * @param algorithm 要检查的算法标识。
     * @return 支持该算法时返回 `true`。
     */
    public func isSupportedAlgorithm(algorithm: String): Bool {
        SupportedAlgorithms.isSupportedAlgorithm(algorithm, this)
    }
}
