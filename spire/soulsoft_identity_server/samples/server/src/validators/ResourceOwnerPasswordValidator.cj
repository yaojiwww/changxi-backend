/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package server.validators

import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

public class ResourceOwnerPasswordValidator <: IResourceOwnerPasswordValidator {
    public func validate(request: ResourceOwnerPasswordValidationRequest) {
        if (!(request.username == "admin" && request.password == "1024")) {
            throw ValidationException(ValidationErrors.ServerError, "username or password is valid")
        }

        return IdentityUser("1024")
    }
}
