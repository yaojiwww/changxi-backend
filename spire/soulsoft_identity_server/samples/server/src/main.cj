/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

/*
 * Identity Server 测试服务器主程序
 *
 * 本文件实现了一个完整的 OAuth 2.0 / OpenID Connect 认证授权服务器，包括：
 * - 令牌端点（Token Endpoint）
 * - 授权端点（Authorization Endpoint）
 * - 用户认证（登录）
 * - 用户授权同意（Consent）
 * - 多种签名算法支持（RSA、ECDSA、对称密钥）
 * - 多种授权模式（密码模式、扩展授权模式等）
 */
package server

import server.services.*
import server.validators.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*
import soulsoft_web_routing.*
import soulsoft_identity_tokens.*
import soulsoft_identity_server.*
import soulsoft_web_staticfiles.*
import soulsoft_web_authorization.*
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*
import soulsoft_web_authentication_cookies.*
import soulsoft_identity_server.authentication.*

/**
 * 程序入口函数
 *
 * 主要流程：
 * 1. 创建 WebHost 构建器
 * 2. 配置安全密钥（RSA、ECDSA、对称密钥）
 * 3. 配置 Identity Server 服务
 * 4. 配置认证和授权服务
 * 5. 构建并配置中间件管道
 * 6. 定义路由端点
 * 7. 启动服务器
 */
main(): Int64 {
    // 创建 Web 主机构建器
    let builer = WebHost.createBuilder()

    // ========== 配置签名密钥 ==========
    // 用于令牌签名和验证的加密密钥，支持多种算法

    // RSA 非对称加密密钥（SHA-256）
    // 从 PEM 文件加载公钥和私钥，用于 JWT 签名
    let rsaSecurityKey = RsaSecurityKey.fromPemFiles("rsa256_public.pem", "rsa256_private.pem")

    // 对称加密密钥
    // 使用共享密钥进行签名和验证，适用于内部系统
    let symmetricSecurityKey = SymmetricSecurityKey(
        "fffffffffffffffgaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaahashhhhhhhhhhhhh".toArray())

    // ECDSA 椭圆曲线加密密钥
    // 提供更高的安全性和更小的密钥尺寸
    let ecdsaSecurityKey = ECDsaSecurityKey.fromPemFiles("ecdsa256_public.pem", "ecdsa256_private.pem")

    // ========== 配置 Identity Server 服务 ==========
    // 添加 Identity Server 核心服务，并配置相关选项
    builer.services.addIdentityServer(
        {
            configureOptions =>
                // 令牌颁发者标识
                configureOptions.issuer = "soulsoft"
                // 令牌颁发者 URI，用于发现端点
                configureOptions.issuerUri = "http://localhost:5000"
                // 用户交互页面配置
                configureOptions.interaction.loginUrl = "/account/login.html"
                configureOptions.interaction.consentUrl = "/account/consent.html"
        }
    )
        // 从配置文件加载客户端定义
        .addInMemoryClients(builer.configuration.getSection("identityserver:clients"))
        // 从配置文件加载 API 作用域定义
        .addInMemoryApiScopes(
        builer.configuration.getSection("identityserver:apiScopes"))
            // 从配置文件加载 API 资源定义
            .addInMemoryApiResources(
        builer.configuration.getSection("identityserver:apiResources"))
            // 从配置文件加载身份资源定义（如 openid、profile 等）
            .addInMemoryIdentityResources(
        builer.configuration.getSection("identityserver:identityResources"))
            // 添加令牌签名凭据（使用 RSA-SHA256 算法）
            .addInMemorySigningCredentials(
        [SigningCredentials(rsaSecurityKey, SecurityAlgorithms.RsaSha256)])
            // 注册用户配置文件服务，用于获取用户声明
            .addProfileService<ProfileService>()
        // 注册扩展授权验证器：邮箱授权
        .addExtensionGrantValidator<EmailExtensionGrantValidator>("email")
        // 注册扩展授权验证器：手机号授权
        .addExtensionGrantValidator<PhoneExtensionGrantValidator>("phone")
        // 注册资源所有者密码凭据授权验证器
        .addPasswordGrantValidator<ResourceOwnerPasswordValidator>()

    // 添加路由服务
    builer.services.addRouting()

    // ========== 配置认证和授权 ==========
    // 添加认证方案，并且指定 LocalApi 为默认方案
    // - Cookie 认证：用于用户登录会话管理
    // - LocalApi 认证：用于本地 API 访问控制
    builer.services.addAuthentication(LocalApiAuthenticationDefaults.Scheme).addCookie().addLocalApi()

    // 添加授权策略
    // 定义基于 Cookie 的授权策略，要求用户必须通过 Cookie 认证
    builer.services.addAuthorizationBuilder().addPolicy(CookieAuthenticationDefaults.Scheme) {
        policy =>
            policy.addAuthenticationSchemes(CookieAuthenticationDefaults.Scheme)
            policy.requireAuthenticatedUser()
    }

    // ========== 构建主机并配置中间件管道 ==========
    // 中间件按照添加顺序依次执行，形成请求处理管道
    // 请求流向：客户端 → IdentityServer → FileServer → Routing → Authentication → Authorization → 端点处理器
    // 响应流向：端点处理器 → Authorization → Authentication → Routing → FileServer → IdentityServer → 客户端
    let host = builer.build()

    // 1. Identity Server 中间件
    // 职责：处理 OAuth 2.0 / OpenID Connect 协议端点
    // 包括：/connect/token（令牌端点）、/connect/authorize（授权端点）、
    //       /connect/userinfo（用户信息端点）、/.well-known/openid-configuration（发现端点）等
    // 位置：必须在路由之前，以便拦截协议相关的请求
    host.useIdentityServer()

    // 2. 静态文件服务中间件
    // 职责：提供静态资源文件（HTML、CSS、JavaScript、图片等）
    // 包括：登录页面（/account/login.html）、授权同意页面（/account/consent.html）等
    // 位置：在路由之前，避免静态文件请求进入路由处理
    host.useFileServer()

    // 3. 路由中间件
    // 职责：根据请求路径匹配对应的端点处理器
    // 功能：解析 URL 路径，将请求分发到正确的处理函数
    // 位置：必须在认证和授权之前，为后续中间件提供路由信息
    host.useRouting()

    // 4. 认证中间件
    // 职责：验证用户身份，解析认证凭据（Cookie、JWT、Bearer Token 等）
    // 功能：从请求中提取认证信息，填充 context.user 对象
    // 位置：必须在授权之前，因为授权需要依赖用户身份信息
    // 注意：此中间件不会阻止请求，只是识别用户身份
    host.useAuthentication()

    // 5. 授权中间件
    // 职责：验证用户是否有权限访问请求的资源
    // 功能：根据授权策略检查用户权限，决定是否允许访问
    // 位置：必须在认证之后、端点处理之前
    // 注意：如果授权失败，会返回 403 Forbidden 或 401 Unauthorized
    host.useAuthorization()

    // ========== 定义路由端点 ==========

    /**
     * POST /account/login - 用户登录端点
     *
     * 功能：处理用户登录请求，验证用户名和密码
     * 请求参数：
     *   - username: 用户名
     *   - password: 密码
     *   - returnUrl: 登录成功后的返回地址（可选）
     * 响应：
     *   - 成功：重定向到 returnUrl 或首页
     *   - 失败：重定向回登录页面，并附带错误信息
     */
    host.mapPost("account/login") {
        context =>
            let username = context.request.form.get("username").getOrThrow()
            let password = context.request.form.get("password").getOrThrow()
            let returnUrl = context.request.form.get("returnUrl") ?? String.empty

            // 验证用户名和密码（示例：硬编码验证）
            // 生产环境应使用数据库验证或其他安全的验证方式
            if (!(username == 'admin' && password == '1024')) {
                let errorUrl = "/account/login.html?returnUrl=${HttpUtility.urlEncode(returnUrl)}&username=${HttpUtility.urlEncode(username)}&error=${HttpUtility.urlEncode("用户名或密码错误")}"
                context.response.redirect(errorUrl)
                return
            }

            // 创建身份声明并登录用户
            // 用户 ID 为 "1024"
            let user = IdentityUser("1024")
            context.signIn(user)

            // 重定向到返回地址或首页
            if (!returnUrl.isEmpty()) {
                context.response.redirect(returnUrl)
            } else {
                context.response.redirect("/")
            }
    }

    /**
     * POST /account/consent/data - 获取授权同意上下文数据
     *
     * 功能：获取授权请求的详细信息，用于展示授权同意页面
     * 请求参数：
     *   - returnUrl: 授权请求的返回地址
     * 响应：JSON 格式的授权上下文数据，包括：
     *   - 客户端信息
     *   - 请求的作用域
     *   - 用户信息等
     * 权限要求：需要 Cookie 认证
     */
    host.mapPost("account/consent/data") {
        context =>
            let returnUrl = context.request.form.get("returnUrl").getOrThrow()
            let consentService = context.services.getOrThrow<IConsentService>()
            let result = consentService.getConsentContext(returnUrl)
            context.response.writeAsJson(result.toJson())
    }.requireAuthorization(CookieAuthenticationDefaults.Scheme)

    /**
     * POST /account/consent - 处理用户授权同意
     *
     * 功能：记录用户对客户端应用的授权同意，并继续授权流程
     * 请求参数：
     *   - scope: 用户同意授权的作用域列表（空格分隔）
     *   - returnUrl: 授权请求的返回地址
     * 响应：重定向回授权端点，继续 OAuth 流程
     * 权限要求：需要 Cookie 认证
     */
    host.mapPost("account/consent") {
        context =>
            let scopes = context.request.form.get("scope").getOrThrow().split(' ')
            let returnUrl = context.request.form.get("returnUrl").getOrThrow()
            let consentService = context.services.getOrThrow<IConsentService>()
            let result = consentService.getConsentContext(returnUrl)
            // 创建授权同意记录
            consentService.createConsent(context.user, result.client, scopes)
            // 重定向回授权端点
            context.response.redirect(returnUrl)
    }.requireAuthorization(CookieAuthenticationDefaults.Scheme)

    /**
     * GET /hello - 测试端点
     *
     * 功能：简单的测试端点，用于验证授权功能
     * 响应：返回 "hello" 文本
     * 权限要求：需要认证（任何有效的认证方案）
     */
    host.mapGet("hello") {
        context => context.response.write("hello")
    }.requireAuthorization()

    // ========== 启动服务器 ==========
    // 在 127.0.0.1:5000 上启动 HTTP 服务器
    host.run("http://127.0.0.1:5000")

    return 0
}
