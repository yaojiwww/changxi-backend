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
import std.collection.*

/*
施工队：根据图纸进行作业
 */
class CallSiteRuntimeResolver <: CallSiteVisitor<RuntimeResolverContext, Any> {
    private init() {
    }

    public static let Instance = CallSiteRuntimeResolver()

    public func resolve(callSite: ServiceCallSite, scope: ServiceProviderEngineScope): Any {
        if (scope.isRootScope && let Some(value) <- callSite.value) {
            return value
        }
        return visitCallSite(callSite, RuntimeResolverContext(scope, RuntimeResolverLock.None))
    }

    /*
    基于图纸类型的工序：工厂模式
     */
    protected func visitFactory(callSite: FactoryCallSite, context: RuntimeResolverContext): Any {
        return callSite.factory(context.scope)
    }

    /*
    基于图纸类型的工序：常量模式
     */
    protected func visitConstant(callSite: ConstantCallSite, _: RuntimeResolverContext): Any {
        return callSite.value.getOrThrow()
    }

    /*
    基于图纸类型的工序：构造器模式
     */
    protected func visitConstructor(callSite: ConstructorCallSite, context: RuntimeResolverContext): Any {
        let parameterValues = Array<Any>(callSite.parameterCallSites.size, repeat: 0)

        for ((index, parameterCallSite) in callSite.parameterCallSites |> enumerate) {
            parameterValues[index] = visitCallSite(parameterCallSite, context)
        }

        return callSite.constructorInfo.apply(parameterValues)
    }

    /*
    基于图纸类型的工序：集合模式
     */
    protected func visitCollection(callSite: CollectionCallSite, context: RuntimeResolverContext): Any {
        let array = IInstanceCollection.create(callSite.itemType, callSite.serviceCallSites.size)

        for ((index, callSite) in callSite.serviceCallSites |> enumerate) {
            array[index] = visitCallSite(callSite, context)
        }
        return array
    }

    /*
    基于图纸类型的工序：自解析模式
     */
    protected func visitServiceProvider(_: ServiceProviderCallSite, context: RuntimeResolverContext): Any {
        return context.scope
    }

    /*
    基于存放位置的工序：存放到释放集合
     */
    public override func visitDisposeCache(callSite: ServiceCallSite, context: RuntimeResolverContext): Any {
        return context.scope.captureDisposable(visitCallSiteMain(callSite, context))
    }

    /*
    基于存放位置的工序：存放到子容器
     */
    public override func visitScopeCache(callSite: ServiceCallSite, context: RuntimeResolverContext): Any {
        if (context.scope.isRootScope) {
            // 通过根容器解析Sccope级别的服务
            return visitRootCache(callSite, context)
        } else {
            return visitCache(callSite, context, context.scope, RuntimeResolverLock.Scope)
        }
    }

    /*
    基于存放位置的工序：存放到根容器
     */
    public override func visitRootCache(callSite: ServiceCallSite, context: RuntimeResolverContext): Any {
        if (let Some(value) <- callSite.value) {
            // 表示解析链中已施工图纸的产物
            return value
        }

        // 使用图纸锁
        let lock = callSite.lock
        let root = context.scope.rootProvider.root

        synchronized(lock) {
            if (let Some(value) <- callSite.value) {
                return value
            }
            let acquiredLocks = context.acquiredLocks.add(RuntimeResolverLock.Root)
            let resolved = visitCallSiteMain(callSite, RuntimeResolverContext(root, acquiredLocks))
            // 计算是否需要释放或者暂存
            root.captureDisposable(resolved)
            // 解析结果缓存到图纸上
            callSite.value = resolved
            return resolved
        }
    }

    /*
    计算缓存
     */
    private func visitCache(callSite: ServiceCallSite, context: RuntimeResolverContext,
        scope: ServiceProviderEngineScope, lockType: RuntimeResolverLock): Any {
        
        // 使用容器锁
        var lockTaken = false
        let sync = scope.sync

        //如果未持有lockType锁，防止同线程递归死锁
        if (!context.acquiredLocks.has(lockType)) {
            sync.lock()
            lockTaken = true
        }

        try {
            // 如果存在实例，那么直接返回
            if (let Some(resolvedServices) <- scope.resolvedServices) {
                if (let Some(resolved) <- resolvedServices.get(callSite.cache.key)) {
                    return resolved
                }
            } else {
                scope.resolvedServices = HashMap<ServiceCacheKey, Any>()
            }

            let acquiredLocks = context.acquiredLocks.add(lockType)
            let resolved = visitCallSiteMain(callSite, RuntimeResolverContext(scope, acquiredLocks))
            //计算是否需要释放或者暂存
            scope.captureDisposable(resolved)
            scope.resolvedServices?.add(callSite.cache.key, resolved)
            return resolved
        } finally {
            if (lockTaken) {
                sync.unlock()
            }
        }
    }
}

/*
定义施工上下文
 */
struct RuntimeResolverContext {
    RuntimeResolverContext(let scope: ServiceProviderEngineScope, let acquiredLocks: RuntimeResolverLock) {
    }
}

/*
定义一个锁标记
    1. 0000 0001表示子容器维度的锁
    2. 0000 0010表示根容器维度的锁
 */
struct RuntimeResolverLock {
    private var flags: Byte

    private init(flag: Byte) {
        this.flags = flag
    }

    public static let None = RuntimeResolverLock(0)

    public static let Scope = RuntimeResolverLock(1)

    public static let Root = RuntimeResolverLock(2)

    /*
    加锁
     */
    public func add(lock: RuntimeResolverLock) {
        return RuntimeResolverLock(flags | lock.flags)
    }

    /*
    是否存在指定的锁
     */
    public func has(lock: RuntimeResolverLock) {
        return (flags & lock.flags) != 0
    }
}
