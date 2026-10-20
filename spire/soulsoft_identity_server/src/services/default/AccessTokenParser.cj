/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import soulsoft_web_http.*
import soulsoft_identity_server.services.*

protected class TokenParser <: ITokenParser {
    public func tryParse(context: HttpContext): ?String {
        if (let Some(token) <- readFromRequestHeader(context)) {
            return token
        }

        if (let Some(token) <- readFromRequestBody(context)) {
            return token
        }

        return None
    }

    private func readFromRequestHeader(context: HttpContext): ?String {
        if (let Some(authorizationValue) <- context.request.headers.authorization.first) {
            if (!authorizationValue[0..6].equalsIgnoreAsciiCase("bearer") || authorizationValue.size < 7) {
                return None
            }
            return authorizationValue[7..]
        }

        return None
    }

    private func readFromRequestBody(context: HttpContext): ?String {
        if (let Some(token) <- context.request.form.get("access_token") && !token.isEmpty()) {
            return token
        }

        return None
    }
}
