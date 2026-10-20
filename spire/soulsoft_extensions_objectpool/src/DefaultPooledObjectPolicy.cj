// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

/**
 * @brief 提供基于工厂函数的默认对象池策略。
 * @param T 对象池管理的对象类型。
 */
public class DefaultPooledObjectPolicy<T> <: PooledObjectPolicy<T> where T <: Object {
    private let factory: () -> T

    /**
     * @brief 创建默认对象池策略实例。
     * @param factory 用于创建对象实例的工厂函数。
     */
    public init(factory: () -> T) {
        this.factory = factory
    }

    /**
     * @brief 创建一个新的对象实例。
     * @return 新创建的对象实例。
     */
    public func create(): T {
        factory()
    }

    /**
     * @brief 在对象归还时尝试重置对象状态。
     * @param obj 待归还的对象实例。
     * @return 如果对象可以重新进入对象池，则返回 true；否则返回 false。
     */
    public func release(obj: T): Bool {
        if (let resettable: IResettable <- obj) {
            return resettable.tryReset()
        }
        return true
    }
}
