// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

/**
 * @brief 定义身份验证方案注册与查询能力。
 */
public interface IAuthenticationSchemeProvider {
    /**
     * @brief 添加一个身份验证方案。
     * @param scheme 待添加的身份验证方案。
     */
    func addScheme(scheme: AuthenticationScheme): Unit
    /**
     * @brief 尝试添加一个身份验证方案。
     * @param scheme 待添加的身份验证方案。
     * @return 添加成功时返回 true。
     */
    func tryAddScheme(scheme: AuthenticationScheme): Bool
    /**
     * @brief 按名称移除身份验证方案。
     * @param name 待移除的方案名称。
     */
    func removeScheme(name: String): Unit
    /**
     * @brief 返回所有已注册的身份验证方案。
     * @return 已注册身份验证方案集合。
     */
    func getAllSchemes(): Collection<AuthenticationScheme>
    /**
     * @brief 按名称查找身份验证方案。
     * @param name 方案名称。
     * @return 对应的身份验证方案；不存在时返回 None。
     */
    func getScheme(name: String): ?AuthenticationScheme
    /**
     * @brief 返回默认身份验证方案。
     * @return 默认身份验证方案；未配置时返回 None。
     */
    func getDefaultAuthenticateScheme(): ?AuthenticationScheme
    /**
     * @brief 返回默认质询方案。
     * @return 默认质询方案；未配置时返回 None。
     */
    func getDefaultChallengeScheme(): ?AuthenticationScheme
    /**
     * @brief 返回默认禁止访问方案。
     * @return 默认禁止访问方案；未配置时返回 None。
     */
    func getDefaultForbidScheme(): ?AuthenticationScheme
    /**
     * @brief 返回可处理请求的方案集合。
     * @return 请求处理方案集合。
     */
    func getRequestHandlerSchemes(): Collection<AuthenticationScheme>
    /**
     * @brief 返回默认登录方案。
     * @return 默认登录方案；未配置时返回 None。
     */
    func getDefaultSignInScheme(): ?AuthenticationScheme
    /**
     * @brief 返回默认登出方案。
     * @return 默认登出方案；未配置时返回 None。
     */
    func getDefaultSignOutScheme(): ?AuthenticationScheme
}
