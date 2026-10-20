// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

/**
 * @brief 提供向服务集合注册 HTTP 上下文访问器的扩展约定。
 */
public interface HttpContextAccessorExtensions {
    /**
     * @brief 向服务集合注册 HTTP 上下文访问器。
     * @return 返回当前服务集合。
     */
    func addHttpContextAccessor(): ServiceCollection
}

extend ServiceCollection <: HttpContextAccessorExtensions{
    /**
     * @brief 向服务集合注册 HTTP 上下文访问器。
     * @return 返回当前服务集合。
     */
    public func addHttpContextAccessor(): ServiceCollection {
        this.addScoped<IHttpContextAccessor, HttpContextAccessor>{_ => HttpContextAccessor()}
        return this
    }
}
