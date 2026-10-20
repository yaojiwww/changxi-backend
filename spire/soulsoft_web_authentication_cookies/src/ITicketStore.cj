// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_authentication.*

/**
 * @brief 定义认证票据的外部存储能力。
 */
public interface ITicketStore {
    /**
     * @brief 存储一个认证票据。
     * @param ticket 待存储的认证票据。
     * @return 票据对应的存储键。
     */
    func store(ticket: AuthenticationTicket): String
    /**
     * @brief 更新指定键对应的认证票据。
     * @param key 票据存储键。
     * @param ticket 新的认证票据。
     */
    func renew(key: String, ticket: AuthenticationTicket): Unit
    /**
     * @brief 读取指定键对应的认证票据。
     * @param key 票据存储键。
     * @return 认证票据；不存在时返回 None。
     */
    func retrieve(key: String): ?AuthenticationTicket
    /**
     * @brief 删除指定键对应的认证票据。
     * @param key 票据存储键。
     * @return 被删除的认证票据；不存在时返回 None。
     */
    func remove(key: String): ?AuthenticationTicket
}
