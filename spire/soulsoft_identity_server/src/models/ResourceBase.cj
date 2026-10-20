/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.collection.*

/**
 * @brief 表示资源定义的公共基类。
 */
public abstract class ResourceBase {
    /**
     * @brief 标识当前资源是否启用。
     */
    public var enabled: Bool = true
    /**
     * @brief 保存资源名称。
     */
    public var name: String = String.empty
    /**
     * @brief 保存资源描述信息。
     */
    public var description: ?String = None
    /**
     * @brief 保存资源显示名称。
     */
    public var displayName: ?String = None
    /**
     * @brief 保存资源关联的声明类型列表。
     */
    public var claimTypes: Array<String> = []
    /**
     * @brief 标识当前资源是否出现在发现文档中。
     */
    public var discoveryDocument = true
    /**
     * @brief 保存资源附加属性集合。
     */
    public var properties: HashMap<String, String> = HashMap<String, String>()
}
