/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_tokens.*

/**
 * @brief 定义签名凭据存储接口。
 */
public interface ISigningCredentialStore {
    /**
     * @brief 获取全部签名凭据集合。
     * @return 返回签名凭据集合。
     */
    func getAllSigningCredentials(): Collection<SigningCredentials>
}
