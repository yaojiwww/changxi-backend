// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

/**
 * @brief 提供对象池策略的抽象基类。
 * @param T 对象池管理的对象类型。
 */
public abstract class PooledObjectPolicy<T> <: IPooledObjectPolicy<T> where T <: Object {
    /**
     * @brief 创建一个新的池化对象实例。
     * @return 新创建的对象实例。
     */
    public func create(): T

    /**
     * @brief 处理对象归还到对象池前的策略逻辑。
     * @param _ 待归还的对象实例。
     * @return 如果对象可以被重新保留到池中，则返回 true；否则返回 false。
     */
    public func release(_: T): Bool
}
