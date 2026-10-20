/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.options.*

/**
 * @brief 提供 Identity Server 端点路由实现。
 */
public class EndpointRouter <: IEndpointRouter {
    private let _options: IdentityServerOptions
    private let _descriptors: EndpointFactory

    /**
     * @brief 创建端点路由器。
     * @param options Identity Server 选项。
     * @param descriptors 可用端点描述集合。
     */
    public init(options: IdentityServerOptions, descriptors: EndpointFactory) {
        _options = options
        _descriptors = descriptors
    }

    /**
     * @brief 根据当前请求路由到端点处理器。
     * @param context 当前 HTTP 上下文。
     * @return 返回匹配到的端点处理器；未匹配时返回空。
     */
    public func routing(context: HttpContext): ?IEndpointHandler {
        if (let Some(endpoint) <- tryMatch(context)) {
            if (!_options.endpoints.isEnable(endpoint.name)) {
                return None
            }
            return createHandler(context, endpoint.typeInfo)
        }
        return None
    }

    private func tryMatch(context: HttpContext) {
        let path = context.request.path.value
        return _descriptors |> filter {f => f.path.equalsIgnoreAsciiCase(path)} |> first
    }

    private func createHandler(context: HttpContext, typeInfo: TypeInfo) {
        let instance = ActivatorUtilities.createInstance(context.services, typeInfo)
        return (instance as IEndpointHandler).getOrThrow()
    }
}
