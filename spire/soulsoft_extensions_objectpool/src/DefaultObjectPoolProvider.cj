// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

import std.reflect.*
import std.runtime.*

/**
 * @brief 提供默认的对象池创建逻辑。
 */
public class DefaultObjectPoolProvider <: ObjectPoolProvider {
    /**
     * @brief 表示对象池允许保留的最大对象数。
     */
    public var maximumRetained: Int64

    /**
     * @brief 创建默认对象池提供程序实例。
     */
    public init() {
        maximumRetained = getProcessorCount() * 2
    }

    /**
     * @brief 使用指定策略创建对象池。
     * @param policy 对象池策略。
     * @return 新创建的对象池实例。
     */
    public func create<T>(policy: IPooledObjectPolicy<T>): ObjectPool<T> where T <: Object {
        if (TypeInfo.of<T>().isSubtypeOf(TypeInfo.of<Resource>())) {
            return DisposableObjectPool<T>(policy, maximumRetained)
        }

        return DefaultObjectPool<T>(policy, maximumRetained)
    }
}
