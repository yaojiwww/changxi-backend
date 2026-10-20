/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import soulsoft_web_http.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_tokens.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * @brief 提供 JWKS 文档端点处理器。
 * @description 返回用于验证令牌签名的公钥集合。
 */
public class DiscoveryJwksEndpoint <: EndpointHandler {
    private let responseGenerator: IDiscoveryResponseGenerator

    /**
     * @brief 使用发现响应生成器创建 JWKS 端点处理器。
     * @param responseGenerator 发现响应生成器。
     */
    public init(responseGenerator: IDiscoveryResponseGenerator) {
        this.responseGenerator = responseGenerator
    }

    /**
     * @brief 处理 JWKS 文档请求。
     * @param _ 当前 HTTP 上下文。
     * @return 返回 JWKS 文档响应结果。
     */
    public func handle(_: HttpContext): IEndpointResult {
        let jsonWebKeySet = responseGenerator.createJwksResponse()
        let jwksDocument = JsonWebKeySetSerializer.writeAsJson(jsonWebKeySet)
        return json(jwksDocument)
    }
}
