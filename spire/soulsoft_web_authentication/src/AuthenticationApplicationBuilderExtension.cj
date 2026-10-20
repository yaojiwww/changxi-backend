// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义应用构建器的身份验证中间件扩展。
 */
public interface AuthenticationApplicationBuilderExtension {
    /**
     * @brief 启用身份验证中间件。
     * @return 当前应用构建器。
     */
    func useAuthentication(): ApplicationBuilder
}

extend ApplicationBuilder <: AuthenticationApplicationBuilderExtension {
    /**
     * @brief 启用身份验证中间件。
     * @return 当前应用构建器。
     * @throws Exception 当身份验证所需服务未注册时抛出。
     */
    public func useAuthentication(): ApplicationBuilder {
        verifyOpenApiServicesAreRegistered()
        this.use<AuthenticationMiddleware>()
        return this
    }

    private func verifyOpenApiServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<IAuthenticationService>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addAuthentication' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}
