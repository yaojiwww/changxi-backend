// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_web_http.*

/**
 * @brief 表示允许匿名访问的标记注解。
 */
@Annotation[target: [Type, MemberFunction]]
public class AllowAnonymous <: IAllowAnonymous{
    /**
     * @brief 创建一个允许匿名访问标记。
     */
    public const init() {
    }
}
