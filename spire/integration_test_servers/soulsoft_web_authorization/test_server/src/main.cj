/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_web_authorization.*
import soulsoft_extensions_injection.*

/**
 * Authorization 集成测试服务器
 *
 * 启动三个测试服务器：
 * - portBase + 0: MiniAPI 基础授权（匿名、requireAuthorization()、allowAnonymous()、用户信息）
 * - portBase + 1: MiniAPI 策略授权（命名策略、内联策略、直接策略对象、Assertion、多要求）
 * - portBase + 2: MVC 控制器授权（类级 @Authorize、@AllowAnonymous 覆盖、命名策略方法级注解）
 *
 * 默认端口段：15070-15079
 * 可通过命令行参数覆盖：
 *   cjpm run -- --portBase 16070
 */

main(args: Array<String>): Int64 {
    let portBase = resolvePortBase(args)
    let serviceArgs = filterPortArgs(args)
    let f1 = spawn { runMiniApiBasicServer(serviceArgs, portBase + 0) }
    let f2 = spawn { runMiniApiPolicyServer(serviceArgs, portBase + 1) }
    let f3 = spawn { runMvcServer(serviceArgs, portBase + 2) }

    f1.get()
    f2.get()
    f3.get()

    return 0
}
