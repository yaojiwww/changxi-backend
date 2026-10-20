// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication_jwtbearer

import std.collection.*
import stdx.encoding.base64.*
import soulsoft_identity_tokens.*
import soulsoft_extensions_options.*
import soulsoft_extensions_configuration.*

/**
 * @brief 根据应用配置填充 JWT Bearer 选项。
 */
public class JwtBearerConfigureOptions <: IConfigureNamedOptions<JwtBearerOptions> {
    private let _configuration: IConfiguration

    /**
     * @brief 创建一个 JWT Bearer 配置器。
     * @param configuration 应用配置。
     */
    public init(configuration: IConfiguration) {
        _configuration = configuration
    }

    /**
     * @brief 按方案名称配置 JWT Bearer 选项。
     * @param name 身份验证方案名称。
     * @param options JWT Bearer 选项。
     */
    public func configure(name: ?String, options: JwtBearerOptions): Unit {
        let section = getSchemeConfiguration(name.getOrThrow())
        if (section.getChildren().isEmpty()) {
            return
        }
        if (let Some(value) <- section.getValue<String>("authority")) {
            options.authority = value
        }
        if (let Some(value) <- section.getValue<String>("challenge")) {
            options.challenge = value
        }
        if (let Some(value) <- section.getValue<String>("metadataAddress")) {
            options.metadataAddress = value
        }
        if (let Some(value) <- section.getValue<Bool>("includeErrorDetails")) {
            options.includeErrorDetails = value
        }
        if (let Some(value) <- section.getValue<Bool>("saveToken")) {
            options.saveToken = value
        }
        if (let Some(value) <- section.getValue<Int64>("refreshInterval")) {
            options.refreshInterval = Duration.second * value
        }
        if (let Some(value) <- section.getValue<Int64>("automaticRefreshInterval")) {
            options.automaticRefreshInterval = Duration.second * value
        }
        if (let Some(value) <- section.getValue<Bool>("requireHttpsMetadata")) {
            options.requireHttpsMetadata = value
        }
        if (let Some(value) <- section.getValue<Bool>("validateIssuer")) {
            options.tokenValidationParameters.validateIssuer = value
        }
        if (let Some(value) <- section.getValue<Bool>("requireAudience")) {
            options.tokenValidationParameters.requireAudience = value
        }
        if (let Some(value) <- section.getValue<Bool>("validateAudience")) {
            options.tokenValidationParameters.validateAudience = value
        }
        if (let Some(value) <- section.getValue<Bool>("validateLifetime")) {
            options.tokenValidationParameters.validateLifetime = value
        }
        if (let Some(value) <- section.getValue<Bool>("validateTokenReplay")) {
            options.tokenValidationParameters.validateTokenReplay = value
        }
        if (let Some(value) <- section.getValue<Bool>("requireExpirationTime")) {
            options.tokenValidationParameters.requireExpirationTime = value
        }
        if (let Some(value) <- section.getValue<Int64>("clockSkew")) {
            options.tokenValidationParameters.clockSkew = Duration.second * value
        }
        if (let Some(value) <- section.getValue<String>("authenticationType")) {
            options.tokenValidationParameters.authenticationType = value
        }
        options.tokenValidationParameters.validTypes = section.getSection("validTypes").getChildren() |>
            filterMap {f => f.value} |> collectArray
        options.tokenValidationParameters.validIssuers = section.getSection("validIssuers").getChildren() |>
            filterMap {f => f.value} |> collectArray
        options.tokenValidationParameters.validAudiences = section.getSection("validAudiences").getChildren() |>
            filterMap {f => f.value} |> collectArray
        options.tokenValidationParameters.issuerSigningKeys = getIssuerSigningKeys(section,
            options.tokenValidationParameters.validIssuers)
    }

    /**
     * @brief 使用默认方案名称配置 JWT Bearer 选项。
     * @param options JWT Bearer 选项。
     */
    public func configure(options: JwtBearerOptions): Unit {
        configure(Options.defaultName, options)
    }

    private func getIssuerSigningKeys(configuration: IConfiguration, issuers: Collection<String>) {
        let keys = ArrayList<SecurityKey>()
        var signingKeys = configuration.getSection("signingKeys").getChildren()
        for (validIssuer in issuers) {
            let signingKey = signingKeys |> filter {f => f["issuer"] == validIssuer} |>
                filterMap {f => f.getValue<String>("value")} |> first
            if (let Some(bytes) <- signingKey.flatMap {f => fromBase64String(f)}) {
                let key = SymmetricSecurityKey(bytes)
                keys.add(key)
            }
        }
        return keys.toArray()
    }

    private func getSchemeConfiguration(authenticationScheme: String) {
        _configuration.getSection("authentication:schemes:${authenticationScheme}")
    }
}
