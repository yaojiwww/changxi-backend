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
 * @brief 指示参数从依赖注入容器解析。
 */
@Annotation[target: [Parameter]]
public class FromServices <: IBindingSourceMetadata{
    /**
     * @brief 创建服务绑定注解实例。
     */
    public const init() {
    }
}
