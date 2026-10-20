// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 定义按方案解析身份验证处理器的服务。
 */
public interface IAuthenticationHandlerProvider {
    /**
     * @brief 获取指定方案的身份验证处理器。
     * @param context 当前 HTTP 上下文。
     * @param schemeName 目标方案名称。
     * @return 对应的身份验证处理器；不存在时返回 None。
     */
    func getHandler(context: HttpContext, schemeName: String): ?IAuthenticationHandler
}
