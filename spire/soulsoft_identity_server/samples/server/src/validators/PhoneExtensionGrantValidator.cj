/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package server.validators

import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

public class PhoneExtensionGrantValidator <: IExtensionGrantValidator {
    public prop grantType: String {
        get() {
            "phone"
        }
    }
    public func validate(request: ExtensionGrantValidationRequest) {
        let phone = request.parameters.get("phone").getOrThrow {
            ValidationException(ValidationErrors.ServerError, "Missing phone parameter")
        }

        let code = request.parameters.get("code").getOrThrow {
            ValidationException(ValidationErrors.ServerError, "Missing code parameter")
        }

        return IdentityUser("1024")
    }
}
