// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 定义自定义加密提供者接口。
 * @description 实现该接口可为 `CryptoProviderFactory` 注入自定义签名算法或外部密钥系统实现。
 */
public interface ICryptoProvider {
    /**
     * @brief 判断当前提供者是否支持指定算法和密钥组合。
     * @param algorithm 待检查的算法标识。
     * @param key 待检查的安全密钥。
     * @param willCreateSignatures 是否用于签名方向。
     * @return 支持该组合时返回 `true`。
     */
    func isSupportedAlgorithm(algorithm: String, key: SecurityKey, willCreateSignatures: Bool): Bool

    /**
     * @brief 创建签名提供者。
     * @param algorithm 要使用的算法标识。
     * @param key 要使用的安全密钥。
     * @param willCreateSignatures 是否创建签名方向的提供者。
     * @return 创建出的签名提供者。
     */
    func createSignatureProvider(algorithm: String,key: SecurityKey,willCreateSignatures: Bool): SignatureProvider

    /**
     * @brief 释放签名提供者占用的资源。
     * @param provider 要释放的签名提供者。
     */
    func releaseSignatureProvider(provider: SignatureProvider): Unit
}
