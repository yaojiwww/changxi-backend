// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_protocols_oidc

import stdx.serialization.serialization.*

extend DataModelStruct {
    internal func add(name: String, value: String, flag: Bool) {
        if (flag) {
            this.add(Field(name, value.serialize()))
        }
    }

    internal func add(name: String, value: Bool, flag!: Bool = true) {
        if (flag) {
            this.add(Field(name, value.serialize()))
        }
    }

    internal func add(name: String, value: Int64, flag!: Bool = true) {
        if (flag) {
            this.add(Field(name, value.serialize()))
        }
    }
    
    internal func add(name: String, values: Collection<String>, flag: Bool) {
        if (flag) {
            let seq = DataModelSeq()
            for (value in values) {
                seq.add(value.serialize())
            }
            this.add(Field(name, seq))
        }
    }
}