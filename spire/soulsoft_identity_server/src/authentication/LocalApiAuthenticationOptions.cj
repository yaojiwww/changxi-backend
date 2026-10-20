/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.authentication

import soulsoft_web_authentication.*

/**
 * @brief 表示本地 API 认证配置选项。
 */
public class LocalApiAuthenticationOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 表示是否保存令牌。
     */
    public var saveToken = false

    /**
     * @brief 表示认证类型名称。
     */
    public var authenticationType = "Local"
}
