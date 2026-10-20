// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import soulsoft_web_http.*

/**
 * @brief 定义 HTTP 上下文上的端点访问扩展接口。
 */
public interface EndpointHttpContextExtensions {
    /**
     * @brief 为当前 HTTP 上下文设置已匹配端点。
     * @param endpoint 要设置的端点。
     */
    func setEndpoint(endpoint: Endpoint): Unit
    /**
     * @brief 返回当前 HTTP 上下文中已设置的端点。
     * @return 已匹配端点；不存在时返回 None。
     */
    func getEndpoint(): ?Endpoint
}

extend HttpContext <: EndpointHttpContextExtensions {
    /**
     * @brief 为当前 HTTP 上下文设置已匹配端点。
     * @param endpoint 要设置的端点。
     */
    public func setEndpoint(endpoint: Endpoint): Unit {
        if (let Some(feature) <- this.features.get<IEndpointFeature>()) {
            feature.endpoint = endpoint
        } else {
            this.features.set<IEndpointFeature>(EndpointFeature(endpoint))
        }
    }

    /**
     * @brief 返回当前 HTTP 上下文中已设置的端点。
     * @return 已匹配端点；不存在时返回 None。
     */
    public func getEndpoint(): ?Endpoint {
        if (let Some(feature) <- this.features.get<IEndpointFeature>()) {
            return feature.endpoint
        }
        return None
    }
}
