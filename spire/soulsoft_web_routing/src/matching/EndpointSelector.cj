// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_http.*

/**
 * @brief 定义最终端点选择器的抽象基类。
 */
public abstract class EndpointSelector {
    /**
     * @brief 从候选集合中选择最终端点。
     * @param context 当前 HTTP 上下文。
     * @param candidates 候选端点集合。
     */
    public func select(context: HttpContext, candidates: CandidateSet): Unit
}
