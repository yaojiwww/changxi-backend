/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_claims.*
import soulsoft_web_authentication.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义用户会话服务接口。
 */
public interface IUserSession {
    /**
     * @brief 获取当前登录用户主体。
     * @return 返回当前用户主体；未登录时返回空。
     */
    func getUser(): ?ClaimsPrincipal
    /**
     * @brief 为指定用户创建登录会话。
     * @param user 需要登录的用户。
     * @param properties 认证属性。
     */
    func signIn(user: IdentityUser, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 退出当前用户会话。
     * @param properties 认证属性。
     */
    func signOut(properties: ?AuthenticationProperties): Unit
}
