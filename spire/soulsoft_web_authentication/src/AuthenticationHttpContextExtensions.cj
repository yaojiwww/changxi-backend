// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_identity_claims.*

/**
 * @brief 定义 HttpContext 的身份验证扩展操作。
 */
public interface AuthenticationHttpContextExtensions {
    /**
     * @brief 使用默认方案执行身份验证。
     * @return 身份验证结果。
     */
    func authenticate(): AuthenticateResult
    /**
     * @brief 使用指定方案执行身份验证。
     * @param scheme 身份验证方案名称。
     * @return 身份验证结果。
     */
    func authenticate(scheme: ?String): AuthenticateResult
    /**
     * @brief 使用默认方案发起质询。
     */
    func challenge(): Unit
    /**
     * @brief 使用指定方案发起质询。
     * @param scheme 身份验证方案名称。
     */
    func challenge(scheme: ?String): Unit
    /**
     * @brief 使用默认方案和指定属性发起质询。
     * @param properties 质询附带属性。
     */
    func challenge(properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用指定方案和属性发起质询。
     * @param scheme 身份验证方案名称。
     * @param properties 质询附带属性。
     */
    func challenge(scheme: ?String, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用默认方案执行禁止访问处理。
     */
    func forbid(): Unit
    /**
     * @brief 使用指定方案执行禁止访问处理。
     * @param scheme 身份验证方案名称。
     */
    func forbid(scheme: ?String): Unit
    /**
     * @brief 使用默认方案和指定属性执行禁止访问处理。
     * @param properties 禁止访问附带属性。
     */
    func forbid(properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用指定方案和属性执行禁止访问处理。
     * @param scheme 身份验证方案名称。
     * @param properties 禁止访问附带属性。
     */
    func forbid(scheme: ?String, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用指定方案登录用户。
     * @param scheme 身份验证方案名称。
     * @param principal 待登录的用户主体。
     */
    func signIn(scheme: ?String, principal: ClaimsPrincipal): Unit {
        signIn(scheme, principal, None)
    }
    /**
     * @brief 使用默认方案登录用户。
     * @param principal 待登录的用户主体。
     */
    func signIn(principal: ClaimsPrincipal): Unit {
        signIn(None, principal, None)
    }
    /**
     * @brief 使用默认方案和属性登录用户。
     * @param principal 待登录的用户主体。
     * @param properties 登录附带属性。
     */
    func signIn(principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit {
        signIn(None, principal, properties)
    }
    /**
     * @brief 使用指定方案和属性登录用户。
     * @param scheme 身份验证方案名称。
     * @param principal 待登录的用户主体。
     * @param properties 登录附带属性。
     */
    func signIn(scheme: ?String, principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用默认方案执行登出。
     */
    func signOut(): Unit {
        signOut(None, None)
    }
    /**
     * @brief 使用默认方案和属性执行登出。
     * @param properties 登出附带属性。
     */
    func signOut(properties: ?AuthenticationProperties): Unit {
        signOut(None, properties)
    }
    /**
     * @brief 使用指定方案执行登出。
     * @param scheme 身份验证方案名称。
     */
    func signOut(scheme: ?String): Unit {
        signOut(scheme, None)
    }
    /**
     * @brief 使用指定方案和属性执行登出。
     * @param scheme 身份验证方案名称。
     * @param properties 登出附带属性。
     */
    func signOut(scheme: ?String, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 从默认方案获取令牌值。
     * @param tokenName 令牌名称。
     * @return 令牌值；不存在时返回 None。
     */
    func getToken(tokenName: String): ?String
    /**
     * @brief 从指定方案获取令牌值。
     * @param scheme 身份验证方案名称。
     * @param tokenName 令牌名称。
     * @return 令牌值；不存在时返回 None。
     */
    func getToken(scheme: String, tokenName: String): ?String
}

extend HttpContext <: AuthenticationHttpContextExtensions {
    /**
     * @brief 使用默认方案执行身份验证。
     * @return 身份验证结果。
     */
    public func authenticate(): AuthenticateResult {
        authenticate(None)
    }

    /**
     * @brief 使用指定方案执行身份验证。
     * @param scheme 身份验证方案名称。
     * @return 身份验证结果。
     */
    public func authenticate(scheme: ?String): AuthenticateResult {
        getAuthenticationService().authenticate(this, scheme)
    }

    /**
     * @brief 使用默认方案发起质询。
     */
    public func challenge(): Unit {
        challenge(None, None)
    }

    /**
     * @brief 使用指定方案发起质询。
     * @param scheme 身份验证方案名称。
     */
    public func challenge(scheme: ?String): Unit {
        challenge(scheme, None)
    }

    /**
     * @brief 使用默认方案和指定属性发起质询。
     * @param properties 质询附带属性。
     */
    public func challenge(properties: ?AuthenticationProperties): Unit {
        challenge(None, properties)
    }

    /**
     * @brief 使用指定方案和属性发起质询。
     * @param scheme 身份验证方案名称。
     * @param properties 质询附带属性。
     */
    public func challenge(scheme: ?String, properties: ?AuthenticationProperties): Unit {
        getAuthenticationService().challenge(this, scheme, properties)
    }

    /**
     * @brief 使用默认方案执行禁止访问处理。
     */
    public func forbid(): Unit {
        forbid(None, None)
    }

    /**
     * @brief 使用指定方案执行禁止访问处理。
     * @param scheme 身份验证方案名称。
     */
    public func forbid(scheme: ?String): Unit {
        forbid(scheme, None)
    }

    /**
     * @brief 使用默认方案和指定属性执行禁止访问处理。
     * @param properties 禁止访问附带属性。
     */
    public func forbid(properties: ?AuthenticationProperties): Unit {
        forbid(None, properties)
    }

    /**
     * @brief 使用指定方案和属性执行禁止访问处理。
     * @param scheme 身份验证方案名称。
     * @param properties 禁止访问附带属性。
     */
    public func forbid(scheme: ?String, properties: ?AuthenticationProperties): Unit {
        getAuthenticationService().forbid(this, scheme, properties)
    }

    /**
     * @brief 使用指定方案和属性登录用户。
     * @param scheme 身份验证方案名称。
     * @param principal 待登录的用户主体。
     * @param properties 登录附带属性。
     */
    public func signIn(scheme: ?String, principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit {
        getAuthenticationService().signIn(this, scheme, principal, properties)
    }

    /**
     * @brief 使用指定方案和属性执行登出。
     * @param scheme 身份验证方案名称。
     * @param properties 登出附带属性。
     */
    public func signOut(scheme: ?String, properties: ?AuthenticationProperties): Unit {
        getAuthenticationService().signOut(this, scheme, properties)
    }

    private func getAuthenticationService() {
        return services.getOrThrow<IAuthenticationService>()
    }

    /**
     * @brief 从默认方案获取令牌值。
     * @param tokenName 令牌名称。
     * @return 令牌值；不存在时返回 None。
     */
    public func getToken(tokenName: String): ?String {
        authenticate().properties.flatMap {f => f.getTokenValue(tokenName)}
    }

    /**
     * @brief 从指定方案获取令牌值。
     * @param scheme 身份验证方案名称。
     * @param tokenName 令牌名称。
     * @return 令牌值；不存在时返回 None。
     */
    public func getToken(scheme: String, tokenName: String): ?String {
        authenticate(scheme).properties.flatMap {f => f.getTokenValue(tokenName)}
    }
}
