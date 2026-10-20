// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*
import std.collection.concurrent.*

/*
施工验证：
1. 记录下所有的Scoped级别的服务
2. 如果根容器依赖了Scoped级别的服务，那么抛出异常
 */
class CallSiteValidator <: CallSiteVisitor<CallSiteValidatorState, ?TypeInfo> {
    private let _scopedServices = ConcurrentHashMap<ServiceCacheKey, ?TypeInfo>()

    public func validateCallSite(callSite: ServiceCallSite): Unit {
        visitCallSite(callSite, CallSiteValidatorState.Default)
    }

    // 每次解析时验证
    public func validateResolution(callSite: ServiceCallSite, scope: IServiceScope, rootScope: IServiceScope) {
        // 如果使用根容器解析作用域服务
        if (refEq((scope as Object).getOrThrow(), (rootScope as Object).getOrThrow()) && let Some(Some(scopedService)) <- _scopedServices
            .get(callSite.cache.key)) {
            if (callSite.serviceType == scopedService) {
                throw UnsupportedException(
                    "Cannot resolve scoped service '${callSite.serviceType}' from root provider.")
            }

            throw UnsupportedException(
                "Cannot resolve '${callSite.serviceType}' from root provider because it requires scoped service '${scopedService}'.")
        }
    }

    /*
    记录下所有的Scoped类型的服务
     */
    protected override func visitCallSite(callSite: ServiceCallSite, state: CallSiteValidatorState): ?TypeInfo {
        var firstScopedServiceInCallSiteTree: ?TypeInfo = None

        if (let Some(cached) <- _scopedServices.get(callSite.cache.key)) {
            firstScopedServiceInCallSiteTree = cached
        } else {
            firstScopedServiceInCallSiteTree = super.visitCallSite(callSite, state)
            _scopedServices[callSite.cache.key] = firstScopedServiceInCallSiteTree
        }

        /*
        如果上下文中存在单例，并且依赖了作用域级别的服务
        只有作用域级别的服务firstScopedServiceInCallSiteTree才是非None的
         */
        if (firstScopedServiceInCallSiteTree.isSome() && let Some(singleton) <- state.singleton) {
            throw UnsupportedException(
                "Cannot consume scoped service '${callSite.serviceType}' from singleton '${singleton.serviceType}'.")
        }

        return firstScopedServiceInCallSiteTree
    }

    /*
    重点计算构造器中的依赖项
     */
    protected func visitConstructor(callSite: ConstructorCallSite, state: CallSiteValidatorState): ?TypeInfo {
        var result: ?TypeInfo = None

        for (pattern in callSite.parameterCallSites) {
            let scoped = visitCallSite(pattern, state)
            // 如果构造器中依赖了一个Scoped级别的服务，那么它一定非None
            result = result ?? scoped
        }

        return result
    }

    protected func visitCollection(callSite: CollectionCallSite, state: CallSiteValidatorState): ?TypeInfo {
        var result: ?TypeInfo = None

        for (pattern in callSite.serviceCallSites) {
            let scoped = visitCallSite(pattern, state)
            // 如果构造器中依赖了一个Scoped级别的服务，那么它一定非None
            result = result ?? scoped
        }

        return result
    }

    /*
    标记单例上下文
     */
    protected func visitRootCache(callSite: ServiceCallSite, _: CallSiteValidatorState): ?TypeInfo {
        return visitCallSiteMain(callSite, CallSiteValidatorState(callSite))
    }

    /*
    Scoped服务的需要缓存
     */
    protected func visitScopeCache(callSite: ServiceCallSite, state: CallSiteValidatorState): ?TypeInfo {
        if (callSite.serviceType == TypeInfo.of<IServiceScopeFactory>()) {
            return None
        }

        visitCallSiteMain(callSite, state)

        return callSite.serviceType
    }

    /*
    工厂方法不考虑，由开发者自己负责
     */
    protected func visitFactory(_: FactoryCallSite, _: CallSiteValidatorState): ?TypeInfo {
        return None
    }

    /*
    常量不能注册为Scoped
     */
    protected func visitConstant(_: ConstantCallSite, _: CallSiteValidatorState): ?TypeInfo {
        return None
    }

    /*
    不考虑
     */
    protected func visitServiceProvider(_: ServiceProviderCallSite, _: CallSiteValidatorState): ?TypeInfo {
        return None
    }
}

struct CallSiteValidatorState {
    CallSiteValidatorState(let singleton: ?ServiceCallSite) {
    }

    public static let Default = CallSiteValidatorState(None)
}
