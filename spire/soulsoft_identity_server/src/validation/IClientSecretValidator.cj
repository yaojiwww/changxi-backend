/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_web_http.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义客户端密钥验证器接口。
 */
public interface IClientSecretValidator {
    /**
     * @brief 验证当前请求中的客户端密钥。
     * @param context 当前 HTTP 上下文。
     * @return 返回客户端密钥验证结果。
     */
    func validate(context: HttpContext): ClientSecretValidationResult
}

/**
 * @brief 表示客户端密钥验证结果。
 */
public class ClientSecretValidationResult {
    /**
     * @brief 保存验证通过的客户端。
     */
    public let client: Client
    /**
     * @brief 保存解析后的客户端密钥。
     */
    public let secret: ParsedSecret

    /**
     * @brief 创建客户端密钥验证结果。
     * @param client 验证通过的客户端。
     * @param secret 解析后的客户端密钥。
     */
    public init(client: Client, secret: ParsedSecret) {
        this.client = client
        this.secret = secret
    }
}
