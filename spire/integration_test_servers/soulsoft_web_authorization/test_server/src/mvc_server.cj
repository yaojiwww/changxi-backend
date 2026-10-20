/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import soulsoft_web_http.*
import soulsoft_web_mvc.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_web_authorization.*
import soulsoft_web_authentication.*
import soulsoft_web_authentication_jwtbearer.*
import soulsoft_extensions_injection.*
import test_server.controllers.*

// ========== MVC 控制器授权服务器 (portBase + 2) ==========
// 覆盖：
//   - 类级 @Authorize（AuthController）：所有 action 需要认证
//   - 方法级 @AllowAnonymous 覆盖类级 @Authorize（AuthController.anonymousAction）
//   - 类级 @AllowAnonymous（PublicController）：整个 controller 匿名可访
//   - 方法级 @Authorize["PolicyName"]（PolicyController）：命名策略授权
//   - 无注解 action 不触发授权检查（PolicyController.open）
//   - 令牌生成 controller（TokenController）：匿名访问

public func runMvcServer(args: Array<String>, port: Int64): Unit {
    let builder = createPortBoundBuilder(args, port)

    // 注册 MVC 服务并加载 controller 程序集
    let mvcBuilder = builder.services.addControllers()
    mvcBuilder.addApplicationPart("test_server.controllers")

    // 配置 JWT 认证
    builder.services.addAuthentication(JwtBearerDefaults.Scheme)
        .addJwtBearer(JwtBearerDefaults.Scheme) { options =>
            options.tokenValidationParameters = createValidationParameters()
            options.includeErrorDetails = true
        }

    // 配置授权策略
    builder.services.addAuthorization() { options =>
        // 基于 Claim 的命名策略
        options.addPolicy("AdminOnly") { policy =>
            policy.requireClaim("role", ["admin"])
        }
        options.addPolicy("UserOnly") { policy =>
            policy.requireClaim("role", ["user"])
        }
        // 基于 requireRole 的命名策略
        options.addPolicy("AdminRole") { policy =>
            policy.requireRole(["admin"])
        }
    }

    let host = builder.build()

    host.useRouting()
    host.useAuthentication()
    host.useAuthorization()

    host.mapControllers()

    host.run()
}
