/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_server.models.*

/**
 * @brief 管理并协调客户端密钥解析器集合。
 */
public class ClientSecretParserManager {
    /**
     * @brief 使用客户端密钥解析器集合创建管理器。
     * @param providers 客户端密钥解析器集合。
     */
    public ClientSecretParserManager(private let providers: Collection<IClientSecretParser>) {
    }

    /**
     * @brief 按顺序尝试解析请求中的客户端密钥。
     * @param context 当前 HTTP 上下文。
     * @return 返回解析成功的客户端密钥信息；如果全部失败则返回 `None`。
     */
    public func tryParse(context: HttpContext): ?ParsedSecret {
        for (provider in providers) {
            if (let Some(parsedSecred) <- provider.tryParse(context)) {
                return parsedSecred
            }
        }
        return None
    }

    /**
     * @brief 返回所有解析器支持的认证方法列表。
     * @return 返回认证方法名称数组。
     */
    public func getauthenticationMethods(): Array<String> {
        providers |> map {f => f.authenticationMethod} |> collectArray
    }
}
