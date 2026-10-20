// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_http.*

/**
 * @brief 提供基于端点元数据比较优先级的泛型比较器。
 */
public open class EndpointMetadataComparer<TMetadata> <: IEndpointComparer where TMetadata <: Any {

    /**
     * @brief 比较两个端点的目标元数据优先级。
     * @param x 第一个端点。
     * @param y 第二个端点。
     * @return 元数据优先级比较结果。
     */
    public func compare(x: Endpoint, y: Endpoint): Ordering {
        return compareMetadata(getMetadata(x), getMetadata(y))
    }

    /**
     * @brief 从端点元数据集合中提取目标元数据。
     * @param endpoint 待提取元数据的端点。
     * @return 提取到的元数据；不存在时返回 None。
     */
    protected open func getMetadata(endpoint: Endpoint): ?TMetadata {
        return endpoint.metadata.getMetadata<TMetadata>()
    }

    /**
     * @brief 比较两个端点元数据实例。
     * @param x 第一个元数据实例。
     * @param y 第二个元数据实例。
     * @return 比较结果；默认有元数据的端点优先。
     */
    protected open func compareMetadata(x: ?TMetadata, y: ?TMetadata): Ordering {
        match ((x, y)) {
            case (None, Some(_)) => Ordering.GT
            case (Some(_), None) => Ordering.LT
            case _ => Ordering.EQ
        }
    }
}
