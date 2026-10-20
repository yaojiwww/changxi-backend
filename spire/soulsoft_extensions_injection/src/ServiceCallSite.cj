// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.sync.*
import std.reflect.*

/*
图纸
 */
abstract class ServiceCallSite {
    private let _key: ?String
    private let _lock = AtomicOptionReference<Mutex>()
    private let _kind: CallSiteKind //图纸类型
    private var _value: ?Any = None //生成的产物
    private let _cache: CallSiteResultCache //存放的位置

    protected init(key: ?String, kind: CallSiteKind, cache: CallSiteResultCache) {
        _key = key
        _kind = kind
        _cache = cache
        if (cache.location == CallSiteResultCacheLocation.Root) {
            _lock.swap(Mutex())
        }
    }

    public prop kind: CallSiteKind {
        get() {
            _kind
        }
    }

    public prop key: ?String {
        get() {
            _key
        }
    }

    public mut prop value: ?Any {
        get() {
            _value
        }
        set(value) {
            _value = value
        }
    }

    public prop lock: Mutex {
        get() {
            // 图纸在构建时，已经根据cache.location提前初始化_lock对象
            // 之所以还需要进行一次赋值，是为了考虑通过根容器来解析scope级别的服务，但是这种是不被推荐。
            if (let Some(lock) <- _lock.load()) {
                return lock
            }
            // 注意: 极小概率下多个线程可能创建多个Mutex实例，                                                                         
            // 但只有一个会被使用，不影响功能正确性 
            _lock.compareAndSwap(None, Mutex())
            return _lock.load().getOrThrow()
        }
    }

    public prop cache: CallSiteResultCache {
        get() {
            _cache
        }
    }

    public prop serviceType: TypeInfo

    public prop implementationType: ?TypeInfo
}
