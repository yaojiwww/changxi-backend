// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

/**
 * @brief 定义端点约定构建器上的路由扩展接口。
 */
public interface RoutingEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点设置显示名称。
     * @param displayName 端点显示名称。
     * @return 当前端点约定构建器。
     */
    func withDisplayName(displayName: String): EndpointConventionBuilder
    /**
     * @brief 为端点追加元数据项。
     * @param items 要追加的元数据集合。
     * @return 当前端点约定构建器。
     */
    func withMetadata(items: Array<Any>): EndpointConventionBuilder
}

extend EndpointConventionBuilder <: RoutingEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点设置显示名称。
     * @param displayName 端点显示名称。
     * @return 当前端点约定构建器。
     */
    public func withDisplayName(displayName: String): EndpointConventionBuilder {
        add {b => b.displayName = displayName}
        return this
    }

    /**
     * @brief 向端点追加一批元数据对象。
     * @param items 要追加的元数据集合。
     * @return 当前端点约定构建器。
     */
    public func withMetadata(items: Array<Any>): EndpointConventionBuilder {
        add {
            b => b.metadata.add(all: items)
        }
        return this
    }
}
