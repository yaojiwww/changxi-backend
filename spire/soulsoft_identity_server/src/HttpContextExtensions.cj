/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import soulsoft_web_http.*
import soulsoft_web_authentication.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*

/**
 * @brief 定义 `HttpContext` 的 Identity Server 扩展接口。
 */
public interface HttpContextExtensions {
    /**
     * @brief 使用默认属性为当前用户执行登录。
     * @param user 需要登录的用户。
     */
    func signIn(user: IdentityUser): Unit {
        signIn(user, None)
    }

    /**
     * @brief 为当前用户执行登录。
     * @param user 需要登录的用户。
     * @param properties 登录使用的认证属性。
     */
    func signIn(user: IdentityUser, properties: ?AuthenticationProperties): Unit
}

extend HttpContext <: HttpContextExtensions {
    /**
     * @brief 为当前用户执行登录。
     * @param user 需要登录的用户。
     * @param properties 登录使用的认证属性。
     */
    public func signIn(user: IdentityUser, properties: ?AuthenticationProperties): Unit {
        let session = this.services.getOrThrow<IUserSession>()
        session.signIn(user, properties)
    }
}
