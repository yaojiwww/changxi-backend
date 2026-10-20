// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

extend ApplicationBuilder {
    /**
     * @brief 按条件将请求分支到独立的中间件管道。
     * @param predicate 判断是否进入分支的条件。
     * @param configuration 分支管道的配置回调。
     * @return 配置后的应用程序构建器。
     */
    public func mapWhen(predicate: (HttpContext) -> Bool, configuration: (ApplicationBuilder) -> Unit): ApplicationBuilder {
        var branchBuilder = this.new()
        configuration(branchBuilder)
        var branch = branchBuilder.build()

        let options = MapWhenOptions(predicate, branch)
        return this.use {
            next =>
                let whenMiddleware = MapWhenMiddleware(next, options)
                return {
                    context => whenMiddleware.invoke(context, next)
                }
        }
    }
}
