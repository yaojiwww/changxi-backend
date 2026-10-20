/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.options

/**
 * @brief 表示身份服务器交互页面相关选项。
 */
public class InteractionOptions {
    /**
     * @brief 指定登录页面地址。
     */
    public var loginUrl = "/account/login"
    /**
     * @brief 指定返回地址参数名称。
     */
    public var returnUrlParameter = "returnUrl"
    /**
     * @brief 指定登出页面地址。
     */
    public var logoutUrl = "/account/login"
    /**
     * @brief 指定错误页面地址。
     */
    public var errorUrl = "/error"
    /**
     * @brief 指定同意页面地址。
     */
    public var consentUrl = "/account/consent"
}
