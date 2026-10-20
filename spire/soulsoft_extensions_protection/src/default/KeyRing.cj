// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.sync.*
import std.collection.*

protected class KeyRing <: IKeyRing {
    private let _defaultKey: IKey
    private let _keyHolderMap: HashMap<KeyIdentifier, KeyHolder>
    private let _defaultKeyHolder: KeyHolder

    public init(defaultKey: IKey, keys: Collection<IKey>, keyManager: IKeyManager) {
        _defaultKey = defaultKey
        _keyHolderMap = createKeyHolderMap(defaultKey, keys, keyManager)
        _defaultKeyHolder = _keyHolderMap[defaultKey.keyId]
    }

    public prop defaultKeyId: KeyIdentifier {
        get() {
            _defaultKey.keyId
        }
    }

    public prop defaultAuthenticatedEncryptor: IAuthenticatedEncryptor {
        get() {
            _defaultKeyHolder.createEncryptorInstance()
        }
    }

    private static func createKeyHolderMap(defaultKey: IKey, keys: Collection<IKey>, keyManager: IKeyManager) {
        let keyHolderMap = HashMap<KeyIdentifier, KeyHolder>()
        for (key in keys) {
            keyHolderMap.add(key.keyId, KeyHolder(key, keyManager))
        }
        if (!keyHolderMap.contains(defaultKey.keyId)) {
            keyHolderMap.add(defaultKey.keyId, KeyHolder(defaultKey, keyManager))
        }
        return keyHolderMap
    }

    public func getAuthenticatedEncryptorByKeyId(keyId: KeyIdentifier): ?IAuthenticatedEncryptor {
        if (let Some(holder) <- _keyHolderMap.get(keyId)) {
            return Some(holder.createEncryptorInstance())
        }
        return None
    }
}

private class KeyHolder {
    private let _lock = Mutex()
    private var _encryptor = AtomicOptionReference<Box<IAuthenticatedEncryptor>>()

    KeyHolder(let key: IKey, let keyManager: IKeyManager) {
    }

    public func createEncryptorInstance() {
        if (let Some(box) <- _encryptor.load()) {
            return box.value
        }
        synchronized(_lock) {
            if (let Some(box) <- _encryptor.load()) {
                return box.value
            }
            let encryptor = keyManager.createEncryptorInstance(key)
            _encryptor.swap(Box<IAuthenticatedEncryptor>(encryptor))
            return encryptor
        }
    }
}
