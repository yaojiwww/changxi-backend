/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_web_http.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义客户端密钥解析器接口。
 */
public interface IClientSecretParser {
    /**
     * @brief 返回当前解析器对应的认证方式名称。
     */
    prop authenticationMethod: String
    /**
     * @brief 尝试从当前请求中解析客户端密钥。
     * @param context 当前 HTTP 上下文。
     * @return 返回解析后的密钥；无法解析时返回空。
     */
    func tryParse(context: HttpContext): ?ParsedSecret
}
