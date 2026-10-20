// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 根据条件将请求分派到分支管道的中间件。
 */
public class MapWhenMiddleware <: IMiddleware {
    /**
     * @brief 创建条件分支中间件实例。
     * @param next 条件不满足时继续执行的下一个委托。
     * @param options 条件分支配置选项。
     */
    public MapWhenMiddleware(let next: RequestDelegate, let options: MapWhenOptions) {
    }

    /**
     * @brief 根据条件执行分支委托或后续委托。
     * @param context 当前 HTTP 上下文。
     * @param next 后续请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        if (options.predicate(context)) {
            options.branch(context)
        } else {
            next(context)
        }
    }
}
