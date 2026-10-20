// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.annotations

import soulsoft_web_http.*

/**
 * @brief 指示动作响应 HTTP DELETE 请求。
 */
@Annotation[target: [MemberFunction]]
public class HttpDelete <: HttpMethod {
    /**
     * @brief 创建不带模板的 DELETE 动作注解实例。
     */
    public const init() {
        super(HttpMethods.Delete, String.empty)
    }

    /**
     * @brief 创建带模板的 DELETE 动作注解实例。
     * @param template 要附加的路由模板。
     */
    public const init(template: String) {
        super(HttpMethods.Delete, template)
    }
}
