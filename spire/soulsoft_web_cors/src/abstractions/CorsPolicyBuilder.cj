// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

/**
 * @brief 提供链式构建 CORS 策略的能力。
 */
public class CorsPolicyBuilder {
    private let _policy = CorsPolicy()

    /**
     * @brief 创建一个预置允许源的 CORS 策略构建器。
     * @param origins 初始允许的请求源列表。
     */
    public init(origins: Array<String>) {
        withOrigins(origins)
    }

    /**
     * @brief 向策略中追加允许的请求源。
     * @param origins 要追加的请求源列表。
     * @return 返回当前构建器。
     */
    public func withOrigins(origins: Array<String>): CorsPolicyBuilder {
        for (origin in origins) {
            _policy.origins.add(getNormalizedOrigin(origin))
        }
        return this
    }

    private static func getNormalizedOrigin(origin: String): String {
        // 转为小写，处理 host 大小写差异（如 http://Example.com）
        let lower = origin.toAsciiLower()
        // 去掉 http 默认端口 80
        if (lower.startsWith("http://") && lower.endsWith(":80")) {
            return lower.removeSuffix(":80")
        }
        // 去掉 https 默认端口 443
        if (lower.startsWith("https://") && lower.endsWith(":443")) {
            return lower.removeSuffix(":443")
        }
        return lower
    }

    /**
     * @brief 向策略中追加允许的请求头。
     * @param headers 要追加的请求头列表。
     * @return 返回当前构建器。
     */
    public func withHeaders(headers: Array<String>): CorsPolicyBuilder {
        _policy.headers.add(all: headers)
        return this
    }

    /**
     * @brief 向策略中追加允许暴露的响应头。
     * @param headers 要追加的响应头列表。
     * @return 返回当前构建器。
     */
    public func withExposedHeaders(headers: Array<String>): CorsPolicyBuilder {
        _policy.exposedHeaders.add(all: headers)
        return this
    }

    /**
     * @brief 向策略中追加允许的请求方法。
     * @param methods 要追加的请求方法列表。
     * @return 返回当前构建器。
     */
    public func withMethods(methods: Array<String>): CorsPolicyBuilder {
        _policy.methods.add(all: methods)
        return this
    }

    /**
     * @brief 将策略配置为允许任意请求源。
     * @return 返回当前构建器。
     */
    public func allowAnyOrigin(): CorsPolicyBuilder {
        _policy.origins.clear()
        _policy.origins.add(CorsConstants.AnyOrigin)
        return this
    }

    /**
     * @brief 将策略配置为允许任意请求方法。
     * @return 返回当前构建器。
     */
    public func allowAnyMethod(): CorsPolicyBuilder {
        _policy.methods.clear()
        _policy.methods.add(CorsConstants.AnyMethod)
        return this
    }

    /**
     * @brief 将策略配置为允许任意请求头。
     * @return 返回当前构建器。
     */
    public func allowAnyHeader(): CorsPolicyBuilder {
        _policy.headers.clear()
        _policy.headers.add(CorsConstants.AnyHeader)
        return this
    }

    /**
     * @brief 将策略配置为允许携带凭据。
     * @return 返回当前构建器。
     */
    public func allowCredentials(): CorsPolicyBuilder {
        _policy.supportsCredentials = true
        return this
    }

    /**
     * @brief 将策略配置为不允许携带凭据。
     * @return 返回当前构建器。
     */
    public func disallowCredentials(): CorsPolicyBuilder {
        _policy.supportsCredentials = false
        return this
    }

    /**
     * @brief 设置预检响应可缓存的最大时长。
     * @param preflightMaxAge 预检响应可缓存的最大时长。
     * @return 返回当前构建器。
     * @throws IllegalArgumentException 当时长为负值时抛出。
     */
    public func setPreflightMaxAge(preflightMaxAge: Duration): CorsPolicyBuilder {
        _policy.preflightMaxAge = preflightMaxAge
        return this
    }

    /**
     * @brief 设置自定义的源地址判定函数。
     * @param isOriginAllowed 用于判定源地址是否允许的函数。
     * @return 返回当前构建器。
     */
    public func setIsOriginAllowed(isOriginAllowed: (String) -> Bool): CorsPolicyBuilder {
        _policy.isOriginAllowed = isOriginAllowed
        return this
    }

    /**
     * @brief 将策略配置为允许已配置通配符域名下的子域。
     * @return 返回当前构建器。
     */
    public func setIsOriginAllowedToAllowWildcardSubdomains(): CorsPolicyBuilder {
        let policy = _policy
        _policy.isOriginAllowed = {origin => CorsPolicyBuilder.isOriginAnAllowedSubdomain(policy, origin)}
        return this
    }

    private static func isOriginAnAllowedSubdomain(policy: CorsPolicy, origin: String): Bool {
        // 直接匹配
        for (o in policy.origins) {
            if (o == origin) {
                return true
            }
        }
        // 通配符子域名匹配
        for (wildcardOrigin in policy.origins) {
            if (!wildcardOrigin.contains("://*.")) {
                continue
            }
            let domainOrigin = wildcardOrigin.replace("*.", "")
            if (isSubdomainOf(origin, domainOrigin)) {
                return true
            }
        }
        return false
    }

    private static func isSubdomainOf(origin: String, domainOrigin: String): Bool {
        let (oScheme, oHost, oPort) = parseOriginParts(origin)
        let (dScheme, dHost, dPort) = parseOriginParts(domainOrigin)
        if (oScheme.isEmpty() || dScheme.isEmpty() || dHost.isEmpty()) {
            return false
        }
        return oScheme == dScheme && oPort == dPort && oHost.endsWith("." + dHost)
    }

    private static func parseOriginParts(origin: String): (String, String, String) {
        if (let Some(sepIdx) <- origin.indexOf("://")) {
            let scheme = origin[0..sepIdx]
            let hostPort = origin[(sepIdx + 3)..]
            if (let Some(portIdx) <- hostPort.lastIndexOf(":")) {
                return (scheme, hostPort[0..portIdx], hostPort[(portIdx + 1)..])
            }
            return (scheme, hostPort, "")
        }
        return ("", "", "")
    }

    /**
     * @brief 构建并返回当前配置的 CORS 策略。
     * @return 返回构建完成的 CORS 策略。
     * @throws UnsupportedException 当策略同时允许任意源和凭据时抛出。
     */
    public func build(): CorsPolicy {
        if (_policy.allowAnyOrigin && _policy.supportsCredentials) {
            throw UnsupportedException(
                "The CORS protocol does not allow specifying a wildcard (any) origin and credentials at the same time. Configure the CORS policy by listing individual origins if credentials needs to be supported.")
        }
        return _policy
    }
}
