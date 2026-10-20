// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication

/**
 * @brief 定义可直接处理当前请求的身份验证处理器。
 */
public interface IAuthenticationRequestHandler <: IAuthenticationHandler {
    /**
     * @brief 处理当前请求。
     * @return 如果请求已被处理则返回 true。
     */
    func handleRequest(): Bool
}
