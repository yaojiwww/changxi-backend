/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package api

import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_cors.*
import soulsoft_web_hosting.*
import soulsoft_web_authorization.*
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*
import soulsoft_web_authentication_jwtbearer.*

// API 测试服务器主程序
// 功能：提供受保护的订单 API 端点，使用 JWT Bearer 认证
main(): Int64 {
    // 创建 Web 主机构建器
    let builder = WebHost.createBuilder()

    // ========================================
    // 服务配置阶段（Services Configuration）
    // 在此阶段向依赖注入容器注册所需的服务
    // ========================================

    // 服务1：添加路由服务
    // 作用：注册路由相关的服务到 DI 容器，支持端点路由功能
    builder.services.addRouting()

    // 服务2：配置 JWT Bearer 认证服务
    // 作用：注册认证服务，配置如何验证 JWT 令牌
    builder.services.addAuthentication(JwtBearerDefaults.Scheme).addJwtBearer(JwtBearerDefaults.Scheme) {
        options =>
            // 禁用 HTTPS 元数据要求（仅用于开发环境）
            // 生产环境应设置为 true 以确保安全性
            options.requireHttpsMetadata = false

            // 认证中心地址（Identity Server）
            // 用于获取 JWT 签名密钥和验证令牌
            options.authority = "http://127.0.0.1:5000"

            // 令牌刷新间隔（已注释）
            // 可选配置：定期从认证中心刷新密钥
            //options.refreshInterval = Duration.second * 10

            // 有效的受众列表
            // 只接受 audience 为 "order" 的令牌
            options.tokenValidationParameters.validAudiences = ["order"]
    }

    // 服务3：配置 CORS（跨域资源共享）服务
    // 作用：注册 CORS 策略，允许跨域请求访问 API
    builder.services.addCors {
        policy => policy.addPolicy("default") {
            // 允许任何请求头、任何 HTTP 方法、任何来源
            // 注意：生产环境应限制具体的源、方法和头部
            p => p.allowAnyHeader().allowAnyMethod().allowAnyOrigin()
        }
    }

    // 服务4：配置授权服务
    // 作用：注册授权策略，定义访问资源的权限要求
    builder.services.addAuthorizationBuilder().setDefaultPolicy {
        // 设置默认授权策略：要求令牌包含 scope="api" 声明
        policy => policy.requireClaim("scope", "api")
    }

    // ========================================
    // 构建主机并配置中间件管道
    // ========================================

    // 构建 Web 主机实例
    let host = builder.build()

    // ========================================
    // 中间件配置阶段（Middleware Pipeline）
    // 中间件按照添加顺序执行，顺序很重要！
    // 请求流向：Routing → CORS → Authentication → Authorization → Endpoint
    // ========================================

    // 中间件1：启用路由中间件
    // 作用：根据请求路径匹配对应的端点
    // 位置：必须在其他中间件之前，用于确定请求的目标端点
    host.useRouting()

    // 中间件2：启用 CORS 中间件
    // 作用：处理跨域请求，添加 CORS 响应头
    // 使用 "default" 策略（允许任何源、方法、头部）
    host.useCors("default")

    // 中间件3：启用认证中间件
    // 作用：验证请求中的 JWT 令牌，设置用户身份信息
    // 位置：必须在授权中间件之前调用
    host.useAuthentication()

    // 中间件4：启用授权中间件
    // 作用：根据授权策略检查用户是否有权限访问资源
    // 位置：必须在认证中间件之后、端点处理之前
    host.useAuthorization()

    // ========================================
    // 端点定义（Endpoint Mapping）
    // ========================================

    // 定义 POST /order 端点
    // 功能：创建订单
    // 需要授权：必须提供有效的 JWT 令牌且包含 scope="api" 声明
    host.mapPost("order") {
        context => context.response.write("订单创建成功")
    }.requireAuthorization()

    // 启动服务器，监听 http://127.0.0.1:8080
    host.run("http://127.0.0.1:8080")

    // 返回成功状态码
    return 0
}
