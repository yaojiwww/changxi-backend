/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_tokens.*

/**
 * @brief 定义签名密钥管理接口。
 */
public interface IKeyManager {
    /**
     * @brief 获取当前可用的活动签名密钥。
     * @return 返回活动签名凭据集合。
     */
    func getActiveSigningKeys(): Collection<SigningCredentials>
    /**
     * @brief 获取全部可用于验证的签名密钥。
     * @return 返回验证签名凭据集合。
     */
    func getAllValidationKeys(): Collection<SigningCredentials> {
        []
    }
}
