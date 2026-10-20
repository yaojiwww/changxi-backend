// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import soulsoft_extensions_options.*

protected class KeyRingDataProtectionProvider <: IDataProtectionProvider {
    private let _applicationDiscriminator: ?String
    private let _keyRingProvider: IKeyRingProvider

    public init(keyRingProvider: IKeyRingProvider, options: IOptions<DataProtectionOptions>) {
        _keyRingProvider = keyRingProvider
        _applicationDiscriminator = options.value.applicationDiscriminator
    }

    public func createProtector(purpose: String): IDataProtector {
        if (let Some(applicationDiscriminator) <- _applicationDiscriminator) {
            return KeyRingDataProtector(_keyRingProvider, purpose, applicationDiscriminator)
        } else {
            return KeyRingDataProtector(_keyRingProvider, purpose)
        }
    }
}
