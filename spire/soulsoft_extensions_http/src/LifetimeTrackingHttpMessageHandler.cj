// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import soulsoft_net_http.*

class LifetimeTrackingHttpMessageHandler <: DelegatingHandler {
    init(innerHandler: HttpMessageHandler) {
        super(innerHandler)
    }

    protected override func close(_: Bool) {
        //其生命周期由ActiveHandlerTrackingEntry单独跟踪
        //DelegatingHandler中的close会递归释放处理链，因此我们只需要释放头节点和头节点的innerHandler即可
    }
}
