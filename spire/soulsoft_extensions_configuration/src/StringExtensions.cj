/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

extend String {
    func toLowerStr(): String {
        return this.toAsciiLower()
    }

    func startsWithIgnoreAsciiCase(prefix: String): Bool {
        return this.toLowerStr().startsWith(prefix.toLowerStr())
    }
}
