// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_web_http.*

private let ALLOW_ANNOYMOUS = AllowAnonymous()

/**
 * @brief 定义端点约定构建器的授权扩展。
 */
public interface IAuthorizationEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点标记允许匿名访问。
     * @return 端点约定构建器。
     */
    func allowAnonymous(): EndpointConventionBuilder
    /**
     * @brief 为端点应用默认授权要求。
     * @return 端点约定构建器。
     */
    func requireAuthorization(): EndpointConventionBuilder
    /**
     * @brief 为端点应用指定名称的授权策略。
     * @param policyNames 授权策略名称集合。
     * @return 端点约定构建器。
     */
    func requireAuthorization(policyNames: Array<String>): EndpointConventionBuilder
    /**
     * @brief 为端点应用指定授权策略。
     * @param policy 授权策略。
     * @return 端点约定构建器。
     */
    func requireAuthorization(policy: AuthorizationPolicy): EndpointConventionBuilder
    /**
     * @brief 为端点应用授权元数据集合。
     * @param authorizeDatas 授权元数据集合。
     * @return 端点约定构建器。
     */
    func requireAuthorization(authorizeDatas: Array<IAuthorizeData>): EndpointConventionBuilder
    /**
     * @brief 使用配置回调为端点构建授权策略。
     * @param configurePolicy 用于构建授权策略的配置回调。
     * @return 端点约定构建器。
     */
    func requireAuthorization(configurePolicy: (AuthorizationPolicyBuilder) -> Unit): EndpointConventionBuilder
}

extend EndpointConventionBuilder <: IAuthorizationEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点标记允许匿名访问。
     * @return 端点约定构建器。
     */
    public func allowAnonymous(): EndpointConventionBuilder {
        add {endpoint => endpoint.metadata.add(ALLOW_ANNOYMOUS)}
        return this
    }

    /**
     * @brief 为端点应用默认授权要求。
     * @return 端点约定构建器。
     */
    public func requireAuthorization(): EndpointConventionBuilder {
        requireAuthorization(Authorize())
        return this
    }

    /**
     * @brief 为端点应用指定名称的授权策略。
     * @param policyNames 授权策略名称集合。
     * @return 端点约定构建器。
     */
    public func requireAuthorization(policyNames: Array<String>): EndpointConventionBuilder {
        let authorizeDatas = policyNames |> map {m => Authorize(m)} |> filterMap {f => f as IAuthorizeData} |>
            collectArrayList
        requireAuthorizationCore(authorizeDatas)
        return this
    }

    /**
     * @brief 为端点应用授权元数据集合。
     * @param authorizeDatas 授权元数据集合。
     * @return 端点约定构建器。
     */
    public func requireAuthorization(authorizeDatas: Array<IAuthorizeData>): EndpointConventionBuilder {
        requireAuthorizationCore(authorizeDatas)
        return this
    }

    /**
     * @brief 为端点应用指定授权策略。
     * @param policy 授权策略。
     * @return 端点约定构建器。
     */
    public func requireAuthorization(policy: AuthorizationPolicy): EndpointConventionBuilder {
        requirePolicyCore(policy)
        return this
    }

    /**
     * @brief 使用配置回调为端点构建授权策略。
     * @param configurePolicy 用于构建授权策略的配置回调。
     * @return 端点约定构建器。
     */
    public func requireAuthorization(configurePolicy: (AuthorizationPolicyBuilder) -> Unit): EndpointConventionBuilder {
        let policyBuilder = AuthorizationPolicyBuilder()
        configurePolicy(policyBuilder)
        requirePolicyCore(policyBuilder.build())
        return this
    }

    private func requirePolicyCore(policy: AuthorizationPolicy) {
        this.add {
            endpointBuilder =>
            if (!(endpointBuilder.metadata |> any {meta => meta is IAuthorizeData})) {
                endpointBuilder.metadata.add(Authorize())
            }
            endpointBuilder.metadata.add(policy)
        }
    }

    private func requireAuthorizationCore(authorizeDatas: Collection<IAuthorizeData>) {
        for (pattern in authorizeDatas) {
            add {endpoint => endpoint.metadata.add(pattern)}
        }
    }
}
