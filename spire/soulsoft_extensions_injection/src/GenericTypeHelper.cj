// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

class GenericTypeHelper {
    // DRY: 消除魔法字符串；Collection 属于 std.core，qualifiedName 无包名前缀
    private static let COLLECTION_PREFIX: String = "Collection<"

    /**
     * 判断是否是 Collection<T> 泛型类型
     */
    public static func isCollectionGenericType(typeInfo: TypeInfo): Bool {
        let name = typeInfo.qualifiedName
        name.startsWith(COLLECTION_PREFIX) && name.endsWith(">")
    }

    /**
     * 获取 Collection<T> 中泛型参数 T 的 TypeInfo
     *
     * 前提：调用方已通过 isCollectionGenericType 校验
     * 限制：不支持嵌套泛型，如 Collection<Map<K, V>>
     * 异常：InfoNotFoundException - 若内部类型名无法解析
     */
    public static func getCollectionGenericParameters(typeInfo: TypeInfo): TypeInfo {
        let name = typeInfo.qualifiedName
        // 用 COLLECTION_PREFIX.size 替代魔法数字，保持 DRY
        let innerName = name[COLLECTION_PREFIX.size..name.size - 1]
        TypeInfo.get(innerName)
    }
}
