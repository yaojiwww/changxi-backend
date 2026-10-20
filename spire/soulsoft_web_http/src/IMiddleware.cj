// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义 HTTP 中间件的调用约定。
 */
public interface IMiddleware {
    /**
     * @brief 处理当前请求并按需调用后续委托。
     * @param context 当前 HTTP 上下文。
     * @param next 用于调用后续处理逻辑的委托。
     */
    func invoke(context: HttpContext, next: RequestDelegate): Unit
}
