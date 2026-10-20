/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import soulsoft_web_http.*
import stdx.encoding.base64.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.constants.*

protected class BasicClientSecretParser <: IClientSecretParser {
    public prop authenticationMethod: String {
        get() {
            ClientAuthenticationTypes.Basic
        }
    }

    public func tryParse(context: HttpContext): ?ParsedSecret {
        let authorizationValue = context.request.headers.authorization.first ?? String.empty
        if (authorizationValue == String.empty) {
            return None
        }

        if (!authorizationValue[0..6].equalsIgnoreAsciiCase("basic ")) {
            return None
        }

        if (let Some((clientId, clientSecret)) <- tryParseClientSecret(authorizationValue[6..])) {
            return ParsedSecret(clientId, clientSecret, authenticationMethod)
        }

        return None
    }

    private func tryParseClientSecret(value: String): ?(String, ?String) {
        if (let Some(bytes) <- fromBase64String(value)) {
            unsafe {
                let value = String.withRawData(bytes)
                if (let Some(index) <- value.indexOf(':')) {
                    let clientId = value[0..index]
                    let clientSecret: ?String = if (value.size > index + 1 && !value[index + 1..].isEmpty()) {
                        value[index + 1..]
                    } else {
                        None
                    }
                    return (clientId, clientSecret)
                }
            }
        }

        return None
    }
}
