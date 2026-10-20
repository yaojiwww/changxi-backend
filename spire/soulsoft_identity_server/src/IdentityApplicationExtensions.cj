/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import soulsoft_web_http.*
import soulsoft_web_cors.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.hosting.*

/**
 * @brief 定义 Identity Server 应用管道扩展接口。
 */
public interface IdentityApplicationExtensions {
    /**
     * @brief 将 Identity Server 中间件加入应用管道。
     */
    func useIdentityServer(): Unit
}

extend ApplicationBuilder <: IdentityApplicationExtensions {
    /**
     * @brief 将 Identity Server 中间件加入应用管道。
     * @throws IllegalStateException 当未注册所需服务时抛出。
     */
    public func useIdentityServer(): Unit {
        this.useCors()
        checkRequiredServices()
        use<IdentityServerMiddleware>()
    }

    private func checkRequiredServices() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        callSiteFactory.isService<IdentityServerOptions>()
        if (!callSiteFactory.isService<IdentityServerOptions>()) {
            throw IllegalStateException(
                "Unable to find the required services. Please add all the required services by calling 'IdentityServerBuilder.addSigningCredential' in the application startup code.")
        }
    }
}
