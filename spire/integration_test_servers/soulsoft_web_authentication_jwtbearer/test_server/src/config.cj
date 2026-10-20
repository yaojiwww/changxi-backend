/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.time.*
import std.collection.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_web_hosting.*

// ========== JWT 配置常量 ==========

public const Issuer = "soulsoft-test-server"
public const Audience = "soulsoft-test-client"
public const SecretKey = "your-256-bit-secret-your-256-bit-secret"
public const DefaultPortBase: Int64 = 15060

// ========== 密钥和凭证创建 ==========

/**
 * 创建HMAC对称密钥
 */
public func createSymmetricKey(): SymmetricSecurityKey {
    return SymmetricSecurityKey(SecretKey.toArray())
}

/**
 * 创建签名凭证
 */
public func createSigningCredentials(): SigningCredentials {
    let key = createSymmetricKey()
    return SigningCredentials(key, SecurityAlgorithms.HmacSha256)
}

/**
 * 创建令牌验证参数
 */
public func createValidationParameters(): TokenValidationParameters {
    let key = createSymmetricKey()
    let params = TokenValidationParameters()
    params.validateIssuer = true
    params.validateAudience = true
    params.validateLifetime = true
    params.requireExpirationTime = true
    params.validIssuers = [Issuer]
    params.validAudiences = [Audience]
    params.issuerSigningKeys = [key]
    return params
}

/**
 * 解析测试服务器的端口基准值。
 *
 * 支持通过命令行参数传入：
 *   --portBase 15060
 *
 * 若未传入，则使用模块预留的默认端口段。
 */
public func resolvePortBase(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    return builder.configuration.getValue<Int64>("portBase") ?? DefaultPortBase
}

/**
 * 过滤掉会与多服务端口分配冲突的命令行参数。
 *
 * 多服务模块统一使用 --portBase 驱动端口，单个服务的最终监听端口
 * 由 portBase + offset 计算得到，因此这里会移除全局 urls/HTTP_PORTS。
 */
public func filterPortArgs(args: Array<String>): Array<String> {
    let filtered = ArrayList<String>()
    var index = 0
    while (index < args.size) {
        let current = args[index]
        if (current == "--portBase" || current == "--HTTP_PORTS" || current == "--urls") {
            index += if (index + 1 < args.size) { 2 } else { 1 }
            continue
        }
        filtered.add(current)
        index++
    }
    return filtered.toArray()
}

/**
 * 为指定端口创建独立的 WebHostBuilder。
 */
public func createPortBoundBuilder(args: Array<String>, port: Int64): WebHostBuilder {
    let builder = WebHost.createBuilder(filterPortArgs(args))
    builder.configuration["HTTP_PORTS"] = port.toString()
    return builder
}
