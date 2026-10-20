/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import soulsoft_web_http.*
import soulsoft_web_cors.abstractions.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.constants.*

class CorsPolicyResolver {
    private let allowedPaths = [ConstantEndpointPaths.TokenPath, ConstantEndpointPaths.UserInfoPath,
        ConstantEndpointPaths.DiscoveryPath, ConstantEndpointPaths.DiscoveryJwksPath]

    public CorsPolicyResolver(let corsOptions: CorsOptions, let options: IdentityServerOptions) {
    }

    public func resolver(context: HttpContext, policyName: ?String): ?CorsPolicy {
        let requestPath = context.request.path.value
        if (requestPath.size <= 1) {
            return None
        }

        if (!allowedPaths.contains(requestPath[1..])) {
            return None
        }

        if (let Some(policy) <- corsOptions.getPolicy(options.corsPolicyName)) {
            return policy
        }
        
        return None
    }
}
