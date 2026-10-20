// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.sync.*

// ICacheExpirationToken 的具体实现。
// 使用 AtomicBool 保证 hasChanged 读写的可见性，无需额外锁。
class KeyExpirationToken <: IKeyExpirationToken {
    private let _hasChanged = AtomicBool(false)

    public prop isCancel: Bool {
        get() { _hasChanged.load() }
    }

    // 触发令牌；由 KeyManager 在撤销操作完成后调用。
    func cancel(): Unit {
        _hasChanged.store(true)
    }
}

/**
 * 永不触发的哨兵令牌，专用于 `withTemporaryExtendedLifetime` 容错降级缓存。
 *
 * 对应 ASP.NET Core 的 `CancellationToken.None`：持有该令牌的缓存在时间到期前
 * 不受任何密钥撤销事件（`fireAndRenewToken()`）影响，确保容错窗口完整有效。
 */
class NeverExpiresToken <: IKeyExpirationToken {
    public prop isCancel: Bool {
        get() { false }
    }
}
