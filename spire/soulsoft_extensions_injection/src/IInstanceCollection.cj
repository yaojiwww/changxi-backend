// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

/*
Array、ArrayList不便于索引和创建
 */
interface IInstanceCollection {
    operator func [](index: Int64, value!: Any): Unit

    static func create(itemType: TypeInfo, size: Int64): IInstanceCollection {
        let arrayType = ClassTypeInfo.get("soulsoft_extensions_injection.InstanceCollection<${itemType.qualifiedName}>")
        return (arrayType.construct(size) as IInstanceCollection).getOrThrow()
    }
}

/*
定义一个引用类型的集合
 */
class InstanceCollection<T> <: Collection<T> & IInstanceCollection {
    private let _items: Array<T>

    public init(size: Int64) {
        _items = Array<T>(size, repeat: unsafe {
            zeroValue<T>()
        })
    }

    public prop size: Int64 {
        get() {
            return _items.size
        }
    }

    public func iterator(): Iterator<T> {
        _items.iterator()
    }

    public operator func [](index: Int64, value!: Any): Unit {
        _items[index] = (value as T).getOrThrow()
    }

    public func isEmpty() {
        return _items.isEmpty()
    }

    public func toArray() {
        _items
    }
}
