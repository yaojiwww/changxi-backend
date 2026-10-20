/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import stdx.encoding.json.*

protected class ValidationErrorResult {
    public ValidationErrorResult(let error: String, let errorDescription: ?String) {
    }

    public func toJson() {
        let obj = JsonObject()
        obj.put("error", JsonString(error))
        if (let Some(errorDescription) <- errorDescription) {
            obj.put("error_description", JsonString(errorDescription))
        }
        return obj
    }
}
