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
施工队：定义施工的基本流程和工序
 */
abstract class CallSiteVisitor<TContext, TResult> {
    
    /*
    作业的起始点：基于存放位置施工
    */
    protected open func visitCallSite(callSite: ServiceCallSite, context: TContext): TResult {
        match (callSite.cache.location) {
            case CallSiteResultCacheLocation.Root => visitRootCache(callSite, context)
            case CallSiteResultCacheLocation.Scope => visitScopeCache(callSite, context)
            case CallSiteResultCacheLocation.Dispose => visitDisposeCache(callSite, context)
            case CallSiteResultCacheLocation.Other => visitNoCache(callSite, context)
        }
    }

    /*
    后续作业点：基于图纸施工
    */
    protected open func visitCallSiteMain(callSite: ServiceCallSite, context: TContext): TResult {
        match ((callSite.kind, callSite)) {
            case (CallSiteKind.Constant, callSite: ConstantCallSite) => visitConstant(callSite, context)
            case (CallSiteKind.Collection, callSite: CollectionCallSite) => visitCollection(callSite, context)
            case (CallSiteKind.Factory, callSite: FactoryCallSite) => visitFactory(callSite, context)
            case (CallSiteKind.Constructor, callSite: ConstructorCallSite) => visitConstructor(callSite, context)
            case (CallSiteKind.ServiceProvider, callSite: ServiceProviderCallSite) => visitServiceProvider(callSite, context)
            case _ => throw UnsupportedException("Call site type ${ClassTypeInfo.of(callSite)} is not supported")
        }
    }

    /*
    基于存放位置的工序：不存放
    */
    protected open func visitNoCache(callSite: ServiceCallSite, context: TContext): TResult {
        visitCallSiteMain(callSite, context)
    }

    /*
    基于存放位置的工序：存放到释放集合
    */
    protected open func visitDisposeCache(callSite: ServiceCallSite, context: TContext): TResult {
        visitCallSiteMain(callSite, context)
    }

    /*
    基于存放位置的工序：存放到根容器
    */
    protected open func visitRootCache(callSite: ServiceCallSite, argument: TContext): TResult {
        visitCallSiteMain(callSite, argument)
    }

    /*
    基于存放位置的工序：存放到子容器
    */
    protected open func visitScopeCache(callSite: ServiceCallSite, argument: TContext): TResult {
        visitCallSiteMain(callSite, argument)
    }

    /*
    基于图纸类型的工序：工厂模式
    */
    protected func visitFactory(callSite: FactoryCallSite, argument: TContext): TResult

    /*
    基于图纸类型的工序：常量模式
    */
    protected func visitConstant(callSite: ConstantCallSite, argument: TContext): TResult

    /*
    基于图纸类型的工序：构造器模式
    */
    protected func visitConstructor(callSite: ConstructorCallSite, argument: TContext): TResult

    /*
    基于图纸类型的工序：迭代器模式
    */
    protected func visitCollection(callSite: CollectionCallSite, argument: TContext): TResult

    /*
    基于图纸类型的工序：自解析模式
    */
    protected func visitServiceProvider(callSite: ServiceProviderCallSite, argument: TContext): TResult
}
