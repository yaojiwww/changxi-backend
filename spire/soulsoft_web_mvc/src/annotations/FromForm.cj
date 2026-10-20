// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.annotations

import soulsoft_web_mvc.abstractions.*

/**
 * @brief 指示参数或成员从表单数据绑定。
 */
@Annotation[target: [Parameter , MemberVariable]]
public class FromForm <: IBindingSourceMetadata {
    /**
     * @brief 表示要绑定的表单字段名称。
     */
    public let name: ?String

    /**
     * @brief 创建表单绑定注解实例。
     */
    public const init() {
        this(name: None)
    }

    /**
     * @brief 创建指定表单字段名称的绑定注解实例。
     * @param name 要绑定的表单字段名称。
     */
    public const init(name!: ?String) {
        this.name = name
    }
}
