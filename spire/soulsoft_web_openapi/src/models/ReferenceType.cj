// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 引用类型。
 */
public enum ReferenceType <: Equatable<ReferenceType> & ToString {
    /**
     * @brief 表示标签引用类型。
     */
    Tag
    /**
     * @brief 表示链接引用类型。
     */
    | Link
    /**
     * @brief 表示架构引用类型。
     */
    | Schema

    /**
     * @brief 比较两个引用类型是否相等。
     * @param that 要比较的引用类型。
     * @return 如果两个引用类型相等则返回 `true`。
     */
    public operator func ==(that: ReferenceType): Bool {
        match ((this, that)) {
            case (Tag, Tag) => true
            case (Link, Link) => true
            case (Schema, Schema) => true
            case _ => false
        }
    }

    /**
     * @brief 返回引用类型对应的名称。
     * @return 当前引用类型对应的名称字符串。
     */
    public func toString(): String {
        match (this) {
            case Tag => "tags"
            case Link => "links"
            case Schema => "schemas"
        }
    }
}
