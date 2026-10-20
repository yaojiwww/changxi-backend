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
 * @brief 为控制器提供路由模板。
 */
@Annotation[target: [Type]]
public class Route <: IRouteTemplateProvider {
    private let _template: String

    /**
     * @brief 使用指定模板创建路由注解实例。
     * @param template 要应用的路由模板。
     */
    public const init(template: String) {
        this._template = template
    }

    /**
     * @brief 返回路由模板。
     * @return 当前注解携带的路由模板。
     */
    public prop template: ?String {
        get() {
            _template
        }
    }
}
