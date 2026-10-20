/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

/**
 * @brief 定义 OAuth 2.0 与 OpenID Connect 标准错误代码。
 */
public class ValidationErrors {
    private init() {
        
    }
    // ========== OAuth 2.0 核心错误 ==========

    /**
     * @brief 表示请求无效错误代码。
     */
    public static let InvalidRequest = "invalid_request"

    /**
     * @brief 表示客户端认证失败错误代码。
     */
    public static let InvalidClient = "invalid_client"

    /**
     * @brief 表示授权凭据无效错误代码。
     */
    public static let InvalidGrant = "invalid_grant"

    /**
     * @brief 表示客户端未授权错误代码。
     */
    public static let UnauthorizedClient = "unauthorized_client"

    /**
     * @brief 表示授权类型不受支持错误代码。
     */
    public static let UnsupportedGrantType = "unsupported_grant_type"

    /**
     * @brief 表示作用域无效错误代码。
     */
    public static let InvalidScope = "invalid_scope"

    /**
     * @brief 表示访问被拒绝错误代码。
     */
    public static let AccessDenied = "access_denied"

    /**
     * @brief 表示响应类型不受支持错误代码。
     */
    public static let UnsupportedResponseType = "unsupported_response_type"

    /**
     * @brief 表示服务器内部错误代码。
     */
    public static let ServerError = "server_error"

    /**
     * @brief 表示服务暂时不可用错误代码。
     */
    public static let TemporarilyUnavailable = "temporarily_unavailable"

    // ========== Token 端点错误 ==========

    /**
     * @brief 表示访问令牌无效错误代码。
     */
    public static let InvalidToken = "invalid_token"

    /**
     * @brief 表示权限不足错误代码。
     */
    public static let InsufficientScope = "insufficient_scope"

    // ========== OpenID Connect 特有错误 ==========

    /**
     * @brief 表示需要重新登录错误代码。
     */
    public static let LoginRequired = "login_required"

    /**
     * @brief 表示需要用户交互错误代码。
     */
    public static let InteractionRequired = "interaction_required"

    /**
     * @brief 表示需要用户同意错误代码。
     */
    public static let ConsentRequired = "consent_required"

    /**
     * @brief 表示请求 URI 无效错误代码。
     */
    public static let InvalidRequestUri = "invalid_request_uri"

    /**
     * @brief 表示请求对象无效错误代码。
     */
    public static let InvalidRequestObject = "invalid_request_object"

    /**
     * @brief 表示不支持 `request` 参数错误代码。
     */
    public static let RequestNotSupported = "request_not_supported"

    /**
     * @brief 表示不支持 `request_uri` 参数错误代码。
     */
    public static let RequestUriNotSupported = "request_uri_not_supported"

    /**
     * @brief 表示不支持动态客户端注册错误代码。
     */
    public static let RegistrationNotSupported = "registration_not_supported"
}
