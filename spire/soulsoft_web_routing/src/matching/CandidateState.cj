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
 * @brief 表示单个候选端点的最终匹配状态。
 */
public struct CandidateState {
    CandidateState(let endpoint: Endpoint, let score: Int64, let isValid: Bool,
        let values: ?RouteValueDictionary) {
    }
}
