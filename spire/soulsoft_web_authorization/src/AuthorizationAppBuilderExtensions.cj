// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_web_http.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义应用构建器的授权扩展。
 */
public interface AuthorizationApplicationBuilderExtensions {
    /**
     * @brief 向应用管道添加授权中间件。
     * @return 应用构建器。
     */
    func useAuthorization(): ApplicationBuilder
}

extend ApplicationBuilder <: AuthorizationApplicationBuilderExtensions {
    /**
     * @brief 向应用管道添加授权中间件。
     * @return 应用构建器。
     */
    public func useAuthorization(): ApplicationBuilder {
        this.use<AuthorizationMiddleware>()
        return this
    }

    private func verifyOpenApiServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<IAuthorizationHandlerProvider>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addAuthorization' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}
