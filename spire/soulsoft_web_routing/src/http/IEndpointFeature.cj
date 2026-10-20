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
 * @brief 定义用于存储当前端点的 HTTP 特性接口。
 */
public interface IEndpointFeature {
    /**
     * @brief 获取或设置当前上下文关联的端点。
     */
    mut prop endpoint: ?Endpoint
}

protected class EndpointFeature <: IEndpointFeature {
    private var _endpoint: ?Endpoint = None

    public init(endpoint: ?Endpoint) {
        _endpoint = endpoint
    }

    public mut prop endpoint: ?Endpoint {
        get() {
            _endpoint
        }
        set(value) {
            _endpoint = value
        }
    }
}
