/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.annotations

/**
 * @brief 表示序列化字段名注解。
 */
@Annotation[target: [MemberVariable, MemberProperty]]
public class JsonPropertyName {
    private let _name: String

    /**
     * @brief 创建一个字段名注解实例。
     * @param name 字段映射使用的名称。
     */
    public const init(name: String) {
        this._name = name
    }

    /**
     * @brief 返回当前字段映射名称。
     * @return 字段映射名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }
}
