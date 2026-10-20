// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols_oidc

import std.collection.*
import stdx.encoding.json.*
import soulsoft_identity_tokens.*
import stdx.serialization.serialization.*

/**
 * @brief 表示 OpenID Connect 发现文档配置。
 */
public class OpenIdConnectConfiguration {
    /**
     * @brief 表示发行者标识。
     */
    public var issuer = String.empty

    /**
     * @brief 表示 JSON Web Key Set 文档地址。
     */
    public var jwksUri = String.empty

    /**
     * @brief 表示服务条款地址。
     */
    public var opTosUri = String.empty

    /**
     * @brief 表示服务策略地址。
     */
    public var opPolicyUri = String.empty

    /**
     * @brief 表示令牌端点地址。
     */
    public var tokenEndpoint = String.empty

    /**
     * @brief 表示用户信息端点地址。
     */
    public var userInfoEndpoint = String.empty

    /**
     * @brief 表示结束会话端点地址。
     */
    public var endSessionEndpoint = String.empty

    /**
     * @brief 表示令牌撤销端点地址。
     */
    public var revocationEndpoint = String.empty

    /**
     * @brief 表示会话检查 iframe 地址。
     */
    public var checkSessionIframe = String.empty

    /**
     * @brief 表示服务文档地址。
     */
    public var serviceDocumentation = String.empty

    /**
     * @brief 表示客户端注册端点地址。
     */
    public var registrationEndpoint = String.empty

    /**
     * @brief 表示令牌自省端点地址。
     */
    public var introspectionEndpoint = String.empty

    /**
     * @brief 表示授权端点地址。
     */
    public var authorizationEndpoint = String.empty

    /**
     * @brief 表示是否支持 HTTP 登出。
     */
    public var httpLogoutSupported = false

    /**
     * @brief 表示是否支持登出会话。
     */
    public var logoutSessionSupported = false

    /**
     * @brief 表示是否支持 `claims` 参数。
     */
    public var claimsParameterSupported = false

    /**
     * @brief 表示是否支持 `request` 参数。
     */
    public var requestParameterSupported = false

    /**
     * @brief 表示是否支持 `request_uri` 参数。
     */
    public var requestUriParameterSupported = false

    /**
     * @brief 表示是否要求预注册 `request_uri`。
     */
    public var requireRequestUriRegistration = false

    /**
     * @brief 表示是否支持前端通道登出会话。
     */
    public var frontchannelLogoutSessionSupported = false

    /**
     * @brief 保存额外的扩展配置字段。
     */
    public var additionalData = HashMap<String, Any>()

    /**
     * @brief 表示支持的声明集合。
     */
    public var claimsSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的作用域集合。
     */
    public var scopesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示可用的签名密钥集合。
     */
    public var signingKeys: List<SecurityKey> = ArrayList<SecurityKey>()

    /**
     * @brief 表示支持的界面语言列表。
     */
    public var uiLocalesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的响应模式集合。
     */
    public var responseModesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的响应类型集合。
     */
    public var responseTypesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的认证上下文值集合。
     */
    public var acrValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的声明类型集合。
     */
    public var claimTypesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的授权类型集合。
     */
    public var grantTypesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的主题类型集合。
     */
    public var subjectTypesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的声明语言列表。
     */
    public var claimsLocalesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示支持的显示参数值集合。
     */
    public var displayValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示令牌端点支持的认证方法集合。
     */
    public var tokenEndpointAuthMethodsSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示令牌端点支持的签名算法集合。
     */
    public var tokenEndpointAuthSigningAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示 ID Token 支持的加密算法集合。
     */
    public var idTokenEncryptionAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示请求对象支持的签名算法集合。
     */
    public var requestObjectSigningAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示请求对象支持的加密算法集合。
     */
    public var requestObjectEncryptionAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示请求对象支持的加密方法集合。
     */
    public var requestObjectEncryptionEncValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示自省端点支持的认证方法集合。
     */
    public var introspectionEndpointAuthMethodsSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示 UserInfo 端点支持的加密算法集合。
     */
    public var userInfoEndpointEncryptionAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示 UserInfo 端点支持的加密方法集合。
     */
    public var userInfoEndpointEncryptionEncValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示 UserInfo 端点支持的签名算法集合。
     */
    public var userInfoEndpointSigningAlgValuesSupported: List<String> = ArrayList<String>()

    /**
     * @brief 表示自省端点支持的签名算法集合。
     */
    public var introspectionEndpointAuthSigningAlgValuesSupported: List<String> = ArrayList<String>()

    private func serialize(): DataModel {
        var dms = DataModelStruct()
        // Basic string fields
        dms.add(OpenIdProviderMetadataNames.Issuer, issuer, issuer.size > 0)
        dms.add(OpenIdProviderMetadataNames.JwksUri, jwksUri, jwksUri.size > 0)
        dms.add(OpenIdProviderMetadataNames.OpTosUri, opTosUri, opTosUri.size > 0)
        dms.add(OpenIdProviderMetadataNames.OpPolicyUri, opPolicyUri, opPolicyUri.size > 0)
        dms.add(OpenIdProviderMetadataNames.TokenEndpoint, tokenEndpoint, tokenEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.UserInfoEndpoint, userInfoEndpoint, userInfoEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.EndSessionEndpoint, endSessionEndpoint, endSessionEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.RevocationEndpoint, revocationEndpoint, revocationEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.CheckSessionIframe, checkSessionIframe, checkSessionIframe.size > 0)
        dms.add(OpenIdProviderMetadataNames.ServiceDocumentation, serviceDocumentation, serviceDocumentation.size > 0)
        dms.add(OpenIdProviderMetadataNames.RegistrationEndpoint, registrationEndpoint, registrationEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.IntrospectionEndpoint, introspectionEndpoint, introspectionEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.AuthorizationEndpoint, authorizationEndpoint, authorizationEndpoint.size > 0)
        dms.add(OpenIdProviderMetadataNames.FrontchannelLogoutSessionSupported, frontchannelLogoutSessionSupported)

        // Boolean fields - always include since they have default values
        dms.add(OpenIdProviderMetadataNames.HttpLogoutSupported, httpLogoutSupported)
        dms.add(OpenIdProviderMetadataNames.LogoutSessionSupported, logoutSessionSupported)
        dms.add(OpenIdProviderMetadataNames.ClaimsParameterSupported, claimsParameterSupported)
        dms.add(OpenIdProviderMetadataNames.RequestParameterSupported, requestParameterSupported)
        dms.add(OpenIdProviderMetadataNames.RequestUriParameterSupported, requestUriParameterSupported)
        dms.add(OpenIdProviderMetadataNames.RequireRequestUriRegistration, requireRequestUriRegistration)

        // Collection fields - all using .size > 0
        dms.add(OpenIdProviderMetadataNames.ClaimsSupported, claimsSupported, claimsSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.ScopesSupported, scopesSupported, scopesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.UILocalesSupported, uiLocalesSupported, uiLocalesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.ResponseModesSupported, responseModesSupported, responseModesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.ResponseTypesSupported, responseTypesSupported, responseTypesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.AcrValuesSupported, acrValuesSupported, acrValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.ClaimTypesSupported, claimTypesSupported, claimTypesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.GrantTypesSupported, grantTypesSupported, grantTypesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.SubjectTypesSupported, subjectTypesSupported, subjectTypesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.ClaimsLocalesSupported, claimsLocalesSupported, claimsLocalesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.DisplayValuesSupported, displayValuesSupported, displayValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.TokenEndpointAuthMethodsSupported, tokenEndpointAuthMethodsSupported, tokenEndpointAuthMethodsSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.TokenEndpointAuthSigningAlgValuesSupported, tokenEndpointAuthSigningAlgValuesSupported, tokenEndpointAuthSigningAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.IdTokenEncryptionAlgValuesSupported, idTokenEncryptionAlgValuesSupported, idTokenEncryptionAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.RequestObjectSigningAlgValuesSupported, requestObjectSigningAlgValuesSupported, requestObjectSigningAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.RequestObjectEncryptionAlgValuesSupported, requestObjectEncryptionAlgValuesSupported, requestObjectEncryptionAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.RequestObjectEncryptionEncValuesSupported, requestObjectEncryptionEncValuesSupported, requestObjectEncryptionEncValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.IntrospectionEndpointAuthMethodsSupported, introspectionEndpointAuthMethodsSupported, introspectionEndpointAuthMethodsSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.UserInfoEncryptionAlgValuesSupported, userInfoEndpointEncryptionAlgValuesSupported, userInfoEndpointEncryptionAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.UserInfoEncryptionEncValuesSupported, userInfoEndpointEncryptionEncValuesSupported, userInfoEndpointEncryptionEncValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.UserInfoSigningAlgValuesSupported, userInfoEndpointSigningAlgValuesSupported, userInfoEndpointSigningAlgValuesSupported.size > 0)
        dms.add(OpenIdProviderMetadataNames.IntrospectionEndpointAuthSigningAlgValuesSupported, introspectionEndpointAuthSigningAlgValuesSupported, introspectionEndpointAuthSigningAlgValuesSupported.size > 0)

        for ((name, value) in additionalData) {
            if (let data: String <- value) {
                dms.add(name, data, data.size > 0)
            } else if (let data: Bool <- value) {
                dms.add(name, data)
            } else if (let data: Int64 <- value) {
                dms.add(name, data)
            } else if(let data: Collection<String> <- value) {
                dms.add(name, data, data.size > 0)
            }
        }

        return dms
    }

    private static func deserialize(dm: DataModel): OpenIdConnectConfiguration {
        var dms = match(dm){
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        var configuration = OpenIdConnectConfiguration()

        // 基础字符串类型
        configuration.issuer = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.Issuer)) ?? String.empty
        configuration.jwksUri = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.JwksUri))  ?? String.empty
        configuration.opTosUri = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.OpTosUri))  ?? String.empty
        configuration.opPolicyUri = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.OpPolicyUri))  ?? String.empty
        configuration.tokenEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.TokenEndpoint))  ?? String.empty
        configuration.userInfoEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.UserInfoEndpoint)) ?? String.empty 
        configuration.endSessionEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.EndSessionEndpoint))  ?? String.empty
        configuration.revocationEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.RevocationEndpoint))  ?? String.empty
        configuration.checkSessionIframe = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.CheckSessionIframe))  ?? String.empty
        configuration.serviceDocumentation = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.ServiceDocumentation))  ?? String.empty
        configuration.registrationEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.RegistrationEndpoint))  ?? String.empty
        configuration.introspectionEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.IntrospectionEndpoint))  ?? String.empty
        configuration.authorizationEndpoint = Option<String>.deserialize(dms.get(OpenIdProviderMetadataNames.AuthorizationEndpoint))  ?? String.empty
        configuration.frontchannelLogoutSessionSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.FrontchannelLogoutSessionSupported)) ?? false

        // 布尔类型
        configuration.httpLogoutSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.HttpLogoutSupported)) ?? false
        configuration.logoutSessionSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.LogoutSessionSupported)) ?? false
        configuration.claimsParameterSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.ClaimsParameterSupported)) ?? false
        configuration.requestParameterSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.RequestParameterSupported)) ?? false
        configuration.requestUriParameterSupported = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.RequestUriParameterSupported)) ?? false
        configuration.requireRequestUriRegistration = Option<Bool>.deserialize(dms.get(OpenIdProviderMetadataNames.RequireRequestUriRegistration)) ?? false

        // claimsSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ClaimsSupported)) {
            configuration.claimsSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // scopesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ScopesSupported)) {
            configuration.scopesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // uiLocalesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.UILocalesSupported)) {
            configuration.uiLocalesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // responseModesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ResponseModesSupported)) {
            configuration.responseModesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // responseTypesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ResponseTypesSupported)) {
            configuration.responseTypesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // acrValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.AcrValuesSupported)) {
            configuration.acrValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // claimTypesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ClaimTypesSupported)) {
            configuration.claimTypesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // grantTypesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.GrantTypesSupported)) {
            configuration.grantTypesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // subjectTypesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.SubjectTypesSupported)) {
            configuration.subjectTypesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // claimsLocalesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.ClaimsLocalesSupported)) {
            configuration.claimsLocalesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // displayValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.DisplayValuesSupported)) {
            configuration.displayValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // tokenEndpointAuthMethodsSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.TokenEndpointAuthMethodsSupported)) {
            configuration.tokenEndpointAuthMethodsSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // tokenEndpointAuthSigningAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.TokenEndpointAuthSigningAlgValuesSupported)) {
            configuration.tokenEndpointAuthSigningAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // idTokenEncryptionAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.IdTokenEncryptionAlgValuesSupported)) {
            configuration.idTokenEncryptionAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // requestObjectSigningAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.RequestObjectSigningAlgValuesSupported)) {
            configuration.requestObjectSigningAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // requestObjectEncryptionAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.RequestObjectEncryptionAlgValuesSupported)) {
            configuration.requestObjectEncryptionAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // requestObjectEncryptionEncValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.RequestObjectEncryptionEncValuesSupported)) {
            configuration.requestObjectEncryptionEncValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // introspectionEndpointAuthMethodsSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.IntrospectionEndpointAuthMethodsSupported)) {
            configuration.introspectionEndpointAuthMethodsSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // userInfoEndpointEncryptionAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.UserInfoEncryptionAlgValuesSupported)) {
            configuration.userInfoEndpointEncryptionAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // userInfoEndpointEncryptionEncValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.UserInfoEncryptionEncValuesSupported)) {
            configuration.userInfoEndpointEncryptionEncValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // userInfoEndpointSigningAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.UserInfoSigningAlgValuesSupported)) {
            configuration.userInfoEndpointSigningAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        // introspectionEndpointAuthSigningAlgValuesSupported
        if (let seq: DataModelSeq <- dms.get(OpenIdProviderMetadataNames.IntrospectionEndpointAuthSigningAlgValuesSupported)) {
            configuration.introspectionEndpointAuthSigningAlgValuesSupported = seq.getItems() |> map { f => String.deserialize(f) } |> collectArrayList
        }

        return configuration
    }

    /**
     * @brief 从 JSON 字符串创建 OpenID Connect 配置。
     * @param json OpenID Connect 发现文档 JSON 字符串。
     * @return 返回解析后的配置对象。
     */
    public static func create(json: String): OpenIdConnectConfiguration {
        return deserialize(DataModel.fromJson(JsonValue.fromStr(json)))
    }

    /**
     * @brief 将 OpenID Connect 配置写出为 JSON 字符串。
     * @param configuration 需要写出的配置对象。
     * @return 返回序列化后的 JSON 字符串。
     */
    public static func write(configuration: OpenIdConnectConfiguration): String {
        return configuration.serialize().toJson().toJsonString()
    }
}
