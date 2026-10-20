// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

/**
 * @brief 表示对象池提供程序的抽象基类。
 */
public abstract class ObjectPoolProvider {
    /**
     * @brief 使用对象工厂创建对象池。
     * @param factory 用于创建对象实例的工厂函数。
     * @return 新创建的对象池实例。
     */
    public open func create<T>(factory: () -> T): ObjectPool<T> where T <: Object {
        return create<T>(DefaultPooledObjectPolicy<T>(factory))
    }

    /**
     * @brief 使用指定策略创建对象池。
     * @param _ 对象池策略。
     * @return 新创建的对象池实例。
     */
    public func create<T>(_: IPooledObjectPolicy<T>): ObjectPool<T> where T <: Object
}
