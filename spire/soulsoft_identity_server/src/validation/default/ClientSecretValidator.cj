/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import std.time.*
import soulsoft_web_http.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class ClientSecretValidator <: IClientSecretValidator {
    public ClientSecretValidator(let clientStore: IClientStore, let secretParserManager: ClientSecretParserManager) {}

    public func validate(context: HttpContext) {
        let parsedSecret = secretParserManager.tryParse(context).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient, "Failed to parse client credentials")
        }

        let client = clientStore.find(parsedSecret.clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient, "Client not found")
        }

        if (!client.enabled) {
            throw ValidationException(ValidationErrors.InvalidClient, "Invalid client credentials")
        }

        if (client.requireSecret && !validateParsedSecret(parsedSecret, client.clientSecrets)) {
            throw ValidationException(ValidationErrors.InvalidClient, "Client secret validation failed")
        }

        return ClientSecretValidationResult(client, parsedSecret)
    }

    private func validateParsedSecret(parsedSecret: ParsedSecret, secrets: Collection<Secret>) {
        if (let Some(clientSecret) <- parsedSecret.clientSecret) {
            let parsedSecrets = [clientSecret.sha256(), clientSecret.sha384(), clientSecret.sha512()]
            for (secret in secrets) {
                if (let Some(expiration) <- secret.expiration) {
                    if (DateTime.now().inUTC() > expiration) {
                        continue
                    }
                }
                if (parsedSecrets.contains(secret.value)) {
                    return true
                }
            }
        }
        return false
    }
}
