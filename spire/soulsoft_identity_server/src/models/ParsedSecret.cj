/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

/**
 * @brief 表示解析后的客户端密钥信息。
 */
public class ParsedSecret {
    /**
     * @brief 创建解析后的客户端密钥信息。
     * @param clientId 客户端标识。
     * @param clientSecret 客户端密钥。
     * @param authenticationMethod 客户端认证方式。
     */
    public ParsedSecret(public let clientId: String, public let clientSecret: ?String,
        public let authenticationMethod: String) {
    }
}
