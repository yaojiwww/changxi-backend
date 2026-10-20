/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import std.time.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_web_authorization.*
import soulsoft_extensions_injection.*

/**
 * JWT Bearer 认证集成测试服务器
 *
 * 启动三个测试服务器：
 * - portBase + 0: 基础JWT认证（令牌生成、受保护端点、用户信息）
 * - portBase + 1: 角色授权（AdminOnly/UserOnly策略）
 * - portBase + 2: 错误处理（过期令牌、无效签名、详细验证）
 *
 * 默认端口段：15060-15069
 * 可通过命令行参数覆盖：
 *   cjpm run -- --portBase 16060
 */

main(args: Array<String>): Int64 {
    let portBase = resolvePortBase(args)
    let serviceArgs = filterPortArgs(args)
    let f1 = spawn { runBasicJwtServer(serviceArgs, portBase + 0) }
    let f2 = spawn { runRoleBasedServer(serviceArgs, portBase + 1) }
    let f3 = spawn { runErrorHandlingServer(serviceArgs, portBase + 2) }

    f1.get()
    f2.get()
    f3.get()

    return 0
}

// ========== 共享配置函数 ==========

func configureJwtAuthentication(builder: WebHostBuilder): Unit {
    builder.services.addRouting()

    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.tokenValidationParameters = createValidationParameters()
            options.includeErrorDetails = true
        }

    builder.services.addAuthorization()
}
