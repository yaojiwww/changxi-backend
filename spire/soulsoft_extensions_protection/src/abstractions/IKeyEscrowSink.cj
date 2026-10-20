// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import stdx.encoding.json.*

/**
 * @brief 定义密钥托管接收器接口。
 * @description 在新密钥被加密写入存储库之前，接收一份明文密钥材料副本。
 * @note 实现者需要保证明文密钥材料的传输与落地安全。
 */
public interface IKeyEscrowSink {
    /**
     * @brief 存储指定密钥的托管信息。
     * @param keyId 需要托管的密钥标识。
     * @param element 包含明文密钥材料的 JSON 对象。
     */
    func store(keyId: KeyIdentifier, element: JsonObject): Unit
}
