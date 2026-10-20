/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import std.reflect.*

/**
 * @brief 表示端点路由描述信息。
 */
public class EndpointDescriptor {
    /**
     * @brief 创建端点描述信息。
     * @param name 端点名称。
     * @param path 端点路径。
     * @param typeInfo 端点处理器类型信息。
     */
    public EndpointDescriptor(public let name: String, public let path: String, public let typeInfo: TypeInfo) {
    }
}
