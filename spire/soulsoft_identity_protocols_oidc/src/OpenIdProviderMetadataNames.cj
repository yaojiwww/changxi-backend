// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols_oidc

/**
 * @brief 定义 OpenID Provider 元数据字段名称常量。
 */
public class OpenIdProviderMetadataNames {
    /**
     * @brief 表示 `acr_values_supported` 元数据字段。
     */
    public static const AcrValuesSupported = "acr_values_supported"

    /**
     * @brief 表示 `authorization_endpoint` 元数据字段。
     */
    public static const AuthorizationEndpoint = "authorization_endpoint"

    /**
     * @brief 表示 `check_session_iframe` 元数据字段。
     */
    public static const CheckSessionIframe = "check_session_iframe"

    /**
     * @brief 表示 `claims_locales_supported` 元数据字段。
     */
    public static const ClaimsLocalesSupported = "claims_locales_supported"

    /**
     * @brief 表示 `claims_parameter_supported` 元数据字段。
     */
    public static const ClaimsParameterSupported = "claims_parameter_supported"

    /**
     * @brief 表示 `claims_supported` 元数据字段。
     */
    public static const ClaimsSupported = "claims_supported"

    /**
     * @brief 表示 `claim_types_supported` 元数据字段。
     */
    public static const ClaimTypesSupported = "claim_types_supported"

    /**
     * @brief 表示发现文档相对路径。
     */
    public static const Discovery = ".well-known/openid-configuration"

    /**
     * @brief 表示 `display_values_supported` 元数据字段。
     */
    public static const DisplayValuesSupported = "display_values_supported"

    /**
     * @brief 表示 `end_session_endpoint` 元数据字段。
     */
    public static const EndSessionEndpoint = "end_session_endpoint"

    /**
     * @brief 表示 `revocation_endpoint` 元数据字段。
     */
    public static const RevocationEndpoint = "revocation_endpoint"

    /**
     * @brief 表示 `frontchannel_logout_session_supported` 元数据字段。
     */
    public static const FrontchannelLogoutSessionSupported = "frontchannel_logout_session_supported"

    /**
     * @brief 表示 `frontchannel_logout_supported` 元数据字段。
     */
    public static const FrontchannelLogoutSupported = "frontchannel_logout_supported"

    /**
     * @brief 表示 `http_logout_supported` 元数据字段。
     */
    public static const HttpLogoutSupported = "http_logout_supported"

    /**
     * @brief 表示 `grant_types_supported` 元数据字段。
     */
    public static const GrantTypesSupported = "grant_types_supported"

    /**
     * @brief 表示 `id_token_encryption_alg_values_supported` 元数据字段。
     */
    public static const IdTokenEncryptionAlgValuesSupported = "id_token_encryption_alg_values_supported"

    /**
     * @brief 表示 `id_token_encryption_enc_values_supported` 元数据字段。
     */
    public static const IdTokenEncryptionEncValuesSupported = "id_token_encryption_enc_values_supported"

    /**
     * @brief 表示 `id_token_signing_alg_values_supported` 元数据字段。
     */
    public static const IdTokenSigningAlgValuesSupported = "id_token_signing_alg_values_supported"

    /**
     * @brief 表示 `introspection_endpoint` 元数据字段。
     */
    public static const IntrospectionEndpoint = "introspection_endpoint"

    /**
     * @brief 表示 `introspection_endpoint_auth_methods_supported` 元数据字段。
     */
    public static const IntrospectionEndpointAuthMethodsSupported = "introspection_endpoint_auth_methods_supported"

    /**
     * @brief 表示 `introspection_endpoint_auth_signing_alg_values_supported` 元数据字段。
     */
    public static const IntrospectionEndpointAuthSigningAlgValuesSupported = "introspection_endpoint_auth_signing_alg_values_supported"

    /**
     * @brief 表示 `jwks_uri` 元数据字段。
     */
    public static const JwksUri = "jwks_uri"

    /**
     * @brief 表示 `issuer` 元数据字段。
     */
    public static const Issuer = "issuer"

    /**
     * @brief 表示 `logout_session_supported` 元数据字段。
     */
    public static const LogoutSessionSupported = "logout_session_supported"

    /**
     * @brief 表示 Microsoft 多刷新令牌元数据字段。
     */
    public static const MicrosoftMultiRefreshToken = "microsoft_multi_refresh_token"

    /**
     * @brief 表示 `op_policy_uri` 元数据字段。
     */
    public static const OpPolicyUri = "op_policy_uri"

    /**
     * @brief 表示 `op_tos_uri` 元数据字段。
     */
    public static const OpTosUri = "op_tos_uri"

    /**
     * @brief 表示 `registration_endpoint` 元数据字段。
     */
    public static const RegistrationEndpoint = "registration_endpoint"

    /**
     * @brief 表示 `request_object_encryption_alg_values_supported` 元数据字段。
     */
    public static const RequestObjectEncryptionAlgValuesSupported = "request_object_encryption_alg_values_supported"

    /**
     * @brief 表示 `request_object_encryption_enc_values_supported` 元数据字段。
     */
    public static const RequestObjectEncryptionEncValuesSupported = "request_object_encryption_enc_values_supported"

    /**
     * @brief 表示 `request_object_signing_alg_values_supported` 元数据字段。
     */
    public static const RequestObjectSigningAlgValuesSupported = "request_object_signing_alg_values_supported"

    /**
     * @brief 表示 `request_parameter_supported` 元数据字段。
     */
    public static const RequestParameterSupported = "request_parameter_supported"

    /**
     * @brief 表示 `request_uri_parameter_supported` 元数据字段。
     */
    public static const RequestUriParameterSupported = "request_uri_parameter_supported"

    /**
     * @brief 表示 `require_request_uri_registration` 元数据字段。
     */
    public static const RequireRequestUriRegistration = "require_request_uri_registration"

    /**
     * @brief 表示 `response_modes_supported` 元数据字段。
     */
    public static const ResponseModesSupported = "response_modes_supported"

    /**
     * @brief 表示 `response_types_supported` 元数据字段。
     */
    public static const ResponseTypesSupported = "response_types_supported"

    /**
     * @brief 表示 `service_documentation` 元数据字段。
     */
    public static const ServiceDocumentation = "service_documentation"

    /**
     * @brief 表示 `scopes_supported` 元数据字段。
     */
    public static const ScopesSupported = "scopes_supported"

    /**
     * @brief 表示 `subject_types_supported` 元数据字段。
     */
    public static const SubjectTypesSupported = "subject_types_supported"

    /**
     * @brief 表示 `token_endpoint` 元数据字段。
     */
    public static const TokenEndpoint = "token_endpoint"

    /**
     * @brief 表示 `token_endpoint_auth_methods_supported` 元数据字段。
     */
    public static const TokenEndpointAuthMethodsSupported = "token_endpoint_auth_methods_supported"

    /**
     * @brief 表示 `token_endpoint_auth_signing_alg_values_supported` 元数据字段。
     */
    public static const TokenEndpointAuthSigningAlgValuesSupported = "token_endpoint_auth_signing_alg_values_supported"

    /**
     * @brief 表示 `ui_locales_supported` 元数据字段。
     */
    public static const UILocalesSupported = "ui_locales_supported"

    /**
     * @brief 表示 `userinfo_endpoint` 元数据字段。
     */
    public static const UserInfoEndpoint = "userinfo_endpoint"

    /**
     * @brief 表示 `userinfo_encryption_alg_values_supported` 元数据字段。
     */
    public static const UserInfoEncryptionAlgValuesSupported = "userinfo_encryption_alg_values_supported"

    /**
     * @brief 表示 `userinfo_encryption_enc_values_supported` 元数据字段。
     */
    public static const UserInfoEncryptionEncValuesSupported = "userinfo_encryption_enc_values_supported"

    /**
     * @brief 表示 `userinfo_signing_alg_values_supported` 元数据字段。
     */
    public static const UserInfoSigningAlgValuesSupported = "userinfo_signing_alg_values_supported"
}
