/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_serialization.annotations

/**
 * @brief 表示多态序列化配置注解。
 */
@Annotation[target: [Type]]
public class JsonPolymorphic {
    private let _typeDiscriminatorPropertyName: String

    /**
     * @brief 创建一个多态序列化配置注解实例。
     * @param typeDiscriminatorPropertyName 多态类型标识字段名称。
     */
    public const init(typeDiscriminatorPropertyName!: String) {
        this._typeDiscriminatorPropertyName = typeDiscriminatorPropertyName
    }

    /**
     * @brief 返回多态类型标识字段名称。
     * @return 多态类型标识字段名称。
     */
    public prop typeDiscriminatorPropertyName: String {
        get() {
            _typeDiscriminatorPropertyName
        }
    }
}
