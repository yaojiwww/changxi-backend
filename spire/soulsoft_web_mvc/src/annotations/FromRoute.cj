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
 * @brief 指示参数从路由值绑定。
 */
@Annotation[target: [Parameter]]
public class FromRoute <: IBindingSourceMetadata {
    /**
     * @brief 表示要绑定的路由参数名称。
     */
    public let name: ?String

    /**
     * @brief 创建路由绑定注解实例。
     */
    public const init() {
        this(name: None)
    }

    /**
     * @brief 创建指定路由参数名称的绑定注解实例。
     * @param name 要绑定的路由参数名称。
     */
    public const init(name!: ?String) {
        this.name = name
    }
}
