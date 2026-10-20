/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

/**
 * @brief 表示端点描述集合。
 */
public class EndpointFactory <: Iterable<EndpointDescriptor> {
    private let _items: Collection<EndpointDescriptor>

    /**
     * @brief 使用端点描述集合创建端点工厂。
     * @param items 端点描述集合。
     */
    public init(items: Collection<EndpointDescriptor>) {
        _items = items
    }

    /**
     * @brief 返回端点描述迭代器。
     * @return 返回端点描述迭代器。
     */
    public func iterator(): Iterator<EndpointDescriptor> {
        _items.iterator()
    }
}
