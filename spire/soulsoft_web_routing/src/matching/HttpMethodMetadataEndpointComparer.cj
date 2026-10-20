// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_routing.http.*


/**
 * 对应 C# HttpMethodMatcherPolicy.HttpMethodMetadataEndpointComparer。
 * 继承 EndpointMetadataComparer<IHttpMethodMetadata>，重写 compareMetadata。
 * 忽略方法列表为空的元数据（等价于无约束端点），有具体 HTTP 方法的端点优先级更高。
 */
class HttpMethodMetadataEndpointComparer <: EndpointMetadataComparer<IHttpMethodMetadata> {
    static let instance: IEndpointComparer = HttpMethodMetadataEndpointComparer()

    protected override func compareMetadata(x: ?IHttpMethodMetadata, y: ?IHttpMethodMetadata): Ordering {
        // 忽略方法列表为空的元数据（等价于无约束端点）
        let nx: ?IHttpMethodMetadata = match (x) {
            case Some(m) where m.httpMethods.size > 0 => x
            case _ => None
        }
        let ny: ?IHttpMethodMetadata = match (y) {
            case Some(m) where m.httpMethods.size > 0 => y
            case _ => None
        }
        return super.compareMetadata(nx, ny)
    }
}