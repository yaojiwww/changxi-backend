/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import soulsoft_identity_tokens.*
import soulsoft_identity_server.stores.*

/**
 * @brief 提供基于内存的签名凭据存储。
 */
public class SigningCredentialMemoryStore <: ISigningCredentialStore {
    /**
     * @brief 使用签名凭据集合创建内存存储。
     * @param signingCredentials 签名凭据集合。
     */
    public SigningCredentialMemoryStore(private let signingCredentials: Collection<SigningCredentials>) {
    }

    /**
     * @brief 返回全部签名凭据。
     * @return 返回内存中的签名凭据集合。
     */
    public func getAllSigningCredentials(): Collection<SigningCredentials> {
        return signingCredentials
    }
}
