// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 表示条件分支中间件的配置选项。
 */
public class MapWhenOptions {
    /**
     * @brief 创建条件分支配置选项实例。
     * @param predicate 判断是否进入分支的条件。
     * @param branch 条件满足时执行的分支委托。
     */
    public MapWhenOptions(public let predicate: (HttpContext) -> Bool, public let branch: RequestDelegate) {}
}
