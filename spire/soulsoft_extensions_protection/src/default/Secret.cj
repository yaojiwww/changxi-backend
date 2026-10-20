// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import stdx.encoding.base64.*

protected class Secret <: ISecret {
    private let _bytes: Array<Byte>

    public init(bytes: Array<Byte>) {
        _bytes = bytes
    }

    public prop size: Int64 {
        get() {
            _bytes.size
        }
    }

    public func bytes() {
        _bytes.clone()
    }

    public func writeSecretIntoBuffer(buffer: Array<Byte>): Unit {
        _bytes.copyTo(buffer)
    }

    public static func create(): ISecret {
        let bytes = SecureRandomUtil.generate(16)
        return Secret(bytes)
    }

    public func toString() {
        _bytes |> toBase64String
    }

    public static func fromStr(str: String): ISecret {
        let bytes = fromBase64String(str).getOrThrow()
        return Secret(bytes)
    }
}
