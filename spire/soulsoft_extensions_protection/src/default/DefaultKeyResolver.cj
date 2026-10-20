// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.sort.*
import std.time.*
import std.collection.*
import soulsoft_extensions_options.*

protected class DefaultKeyResolver <: IDefaultKeyResolver {
    private let _keyPropagationWindow: Duration
    private let _maxServerClockSkew: Duration

    public init(options: IOptions<KeyManagementOptions>) {
        _keyPropagationWindow = options.value.keyPropagationWindow
        _maxServerClockSkew = options.value.maxServerClockSkew
    }

    public func resolve(keys: Collection<IKey>): DefaultKeyResolution {
        let defaultKey = selectDefaultKey(keys)
        let fallbackKey = selectFallbackKey(keys, defaultKey)
        return DefaultKeyResolution(defaultKey, fallbackKey)
    }

    // 选择默认密钥：
    //   1. 已激活（含时钟偏差容忍），未撤销，未过期
    //   2. 主键按激活时间降序；同时间按 keyId 字符串升序（跨节点确定性）
    private func selectDefaultKey(keys: Collection<IKey>): ?IKey {
        let currentTime = DateTime.nowUTC()
        let maxActivationDate = currentTime + _maxServerClockSkew

        let list = keys |> filter {k => k.activationDate <= maxActivationDate} |> filter {k => !k.isRevoked} |>
            filter {k => k.expirationDate > currentTime} |> collectArray

        sort(list, by: {
            a, b => if (a.activationDate > b.activationDate) {
                Ordering.LT
            } else if (a.activationDate < b.activationDate) {
                Ordering.GT
            } else if (a.keyId.toString() < b.keyId.toString()) {
                Ordering.LT
            } else if (a.keyId.toString() > b.keyId.toString()) {
                Ordering.GT
            } else {
                Ordering.EQ
            }
        })

        return list.first
    }

    // 选择 fallback 密钥（当默认密钥不可用、需要生成新密钥时的保底选项）：
    //   - 排除已撤销密钥
    //   - 排除已被 selectDefaultKey 拒绝的候选键（避免重复使用坏密钥）
    //   - 优先：已传播（creationDate <= now - propagationWindow），按创建时间降序（最新的已传播键）
    //   - 其次：未传播，按创建时间升序（最老的，相对更稳定）
    private func selectFallbackKey(keys: Collection<IKey>, excludeKey: ?IKey): ?IKey {
        let currentTime = DateTime.nowUTC()
        let maxCreationDate = currentTime - _keyPropagationWindow

        let candidates = keys |> filter {k => !k.isRevoked} |> filter {
            k => if (let Some(ex) <- excludeKey) {
                k.keyId != ex.keyId
            } else {
                true
            }
        } |> collectArray

        // 已传播：优先使用，取最新
        let propagated = candidates |> filter {k => k.creationDate <= maxCreationDate} |> collectArray
        sort(propagated, key: {k => k.creationDate}, descending: true)
        if (propagated.size > 0) {
            return propagated.first
        }

        // 未传播：兜底使用，取最老
        let unpropagated = candidates |> filter {k => k.creationDate > maxCreationDate} |> collectArray
        sort(unpropagated, key: {k => k.creationDate})
        return unpropagated.first
    }
}
