// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

/**
 * @brief 表示支持重置状态以便复用的对象。
 */
public interface IResettable {
    /**
     * @brief 尝试将当前对象重置为可复用状态。
     * @return 如果对象已成功重置并可重新进入对象池，则返回 true；否则返回 false。
     */
    func tryReset(): Bool
}
