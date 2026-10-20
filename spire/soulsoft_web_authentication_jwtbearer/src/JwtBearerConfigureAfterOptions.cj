// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication_jwtbearer

import soulsoft_net_http.*
import soulsoft_identity_protocols.*
import soulsoft_extensions_options.*
import soulsoft_identity_protocols_oidc.*

/**
 * @brief 在基础配置完成后补齐 JWT Bearer 运行时依赖。
 */
public class JwtBearerConfigureAfterOptions <: IConfigureAfterOptions<JwtBearerOptions> {
    /**
     * @brief 在配置完成后补齐 JWT Bearer 选项。
     * @param _ 方案名称。
     * @param options JWT Bearer 选项。
     * @throws IllegalArgumentException 当元数据地址未使用 HTTPS 且要求 HTTPS 时抛出。
     */
    public func configureAfter(_: ?String, options: JwtBearerOptions): Unit {
        if (options.configurationManager.isSome()) {
            return
        }

        //如果有配资源
        if (let Some(configuration) <- options.configuration) {
            options.configurationManager = StaticConfigurationManager<OpenIdConnectConfiguration>(configuration)
        } else if (!(options.metadataAddress.isEmpty() && options.authority.isEmpty())) {
            if (options.metadataAddress.isEmpty() && !options.authority.isEmpty()) {
                options.metadataAddress = options.authority
                if (!options.metadataAddress.endsWith("/")) {
                    options.metadataAddress += "/"
                }
                options.metadataAddress += ".well-known/openid-configuration"
            }

            if (options.requireHttpsMetadata && !options.metadataAddress.toAsciiLower().startsWith("https://")) {
                throw IllegalArgumentException(
                    "The MetadataAddress or Authority must use HTTPS unless disabled for development by setting RequireHttpsMetadata=false.")
            }
            if (options.backchannel.isNone()) {
                let client = if (let Some(handler) <- options.backchannelHttpHandler) {
                    HttpClient(handler)
                } else {
                    HttpClient.create {
                        builder => builder.readTimeout(options.backchannelTimeout)
                    }
                }
                client.defaultRequestHeaders.add(HeaderNames.UserAgent, "Cangjie JwtBearer handler")
                options.backchannel = client
            }

            let documentRetriever = HttpDocumentRetriever(options.backchannel.getOrThrow(),
                requireHttps: options.requireHttpsMetadata)

            options.configurationManager = ConfigurationManager<OpenIdConnectConfiguration>(options.metadataAddress,
                documentRetriever, OpenIdConnectConfigurationRetriever(), refreshInterval: options.refreshInterval,
                automaticRefreshInterval: options.automaticRefreshInterval)
        }
    }
}
