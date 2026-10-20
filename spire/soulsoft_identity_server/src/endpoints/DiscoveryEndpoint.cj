/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import soulsoft_web_http.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * @brief 提供 OpenID Connect 发现文档端点处理器。
 * @description 返回授权服务器的元数据信息。
 */
public class DiscoveryEndpoint <: EndpointHandler {
    private let responseGenerator: IDiscoveryResponseGenerator

    /**
     * @brief 使用发现文档响应生成器创建端点处理器。
     * @param responseGenerator 发现文档响应生成器。
     */
    public init(responseGenerator: IDiscoveryResponseGenerator) {
        this.responseGenerator = responseGenerator
    }

    /**
     * @brief 处理发现文档请求。
     * @param _ 当前 HTTP 上下文。
     * @return 返回发现文档响应结果。
     */
    public func handle(_: HttpContext): IEndpointResult {
        let configuration = responseGenerator.createDiscoveryResponse()
        let discoveryDocument = OpenIdConnectConfiguration.write(configuration)
        return json(discoveryDocument)
    }
}
