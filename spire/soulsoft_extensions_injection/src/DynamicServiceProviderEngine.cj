// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/*
该类表示它使用动态反射技术来解析服务
*/
class DynamicServiceProviderEngine <: ServiceProviderEngine {
    init() {
    }

    public func realizeService(callSite: ServiceCallSite): (ServiceProviderEngineScope) -> Any {
        return {
            // 后续可以在此处介入动态编译技术
            scope => CallSiteRuntimeResolver.Instance.resolve(callSite, scope)
        }
    }
}
