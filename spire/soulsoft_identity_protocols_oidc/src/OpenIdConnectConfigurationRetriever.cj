// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols_oidc

import soulsoft_identity_tokens.*
import soulsoft_identity_protocols.*

/**
 * @brief 提供 OpenID Connect 配置检索实现。
 */
public class OpenIdConnectConfigurationRetriever <: IConfigurationRetriever<OpenIdConnectConfiguration> {
    /**
     * @brief 读取并解析 OpenID Connect 配置。
     * @param address 发现文档地址。
     * @param retriever 用于读取文档内容的检索器。
     * @return 返回解析后的配置对象。
     */
    public func get(address: String, retriever: IDocumentRetriever): OpenIdConnectConfiguration {
        let json = retriever.getDocument(address)
        let configuration = OpenIdConnectConfiguration.create(json)
        if (!configuration.jwksUri.isEmpty()) {
            let jwksJson = retriever.getDocument(configuration.jwksUri)
            let jsonWebKey = JsonWebKeySet.create(jwksJson)
            for (signingKey in jsonWebKey.getSigningKeys()) {
                configuration.signingKeys.add(signingKey)
            }
        }
        return configuration
    }

    /**
     * @brief 读取并解析 OpenID Connect 配置。
     * @param address 发现文档地址。
     * @param documentRetriever 用于读取文档内容的检索器。
     * @return 返回解析后的配置对象。
     */
    public func getConfiguration(address: String, documentRetriever: IDocumentRetriever): OpenIdConnectConfiguration {
        return get(address, documentRetriever)
    }
}
