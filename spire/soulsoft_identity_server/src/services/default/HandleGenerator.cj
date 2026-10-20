/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import stdx.encoding.hex.*
import stdx.crypto.crypto.*
import soulsoft_identity_server.services.*

protected class HandleGenerator <: IHandleGenerator {
    public func generate(length: Int32) {
        let random = SecureRandom()
        return toHexString(random.nextBytes(length))
    }
}
