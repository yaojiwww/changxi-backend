// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.abstractions

/**
 * @brief 提供路由模板元数据。
 */
public interface IRouteTemplateProvider {
    /**
     * @brief 返回当前元数据提供的路由模板。
     * @return 当前声明提供的路由模板；如果未设置则返回 `None`。
     */
    prop template: ?String
}
