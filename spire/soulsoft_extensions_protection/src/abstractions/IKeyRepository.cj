// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import std.collection.*
import stdx.encoding.json.*

/**
 * @brief 定义密钥持久化仓储接口。
 */
public interface IKeyRepository {
    /**
     * @brief 读取仓储中的全部密钥文档。
     * @return 返回密钥文档列表。
     */
    func getAll(): ReadOnlyList<JsonObject>

    /**
     * @brief 保存一份密钥文档。
     * @param jsonObject 需要保存的密钥文档。
     * @param friendlyName 便于识别的友好名称。
     */
    func store(jsonObject: JsonObject, friendlyName: String): Unit
}
