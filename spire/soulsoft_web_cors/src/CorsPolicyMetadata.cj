// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_cors

import soulsoft_web_cors.abstractions.*

/**
 * @brief 表示直接携带 CORS 策略的元数据。
 */
public class CorsPolicyMetadata <: ICorsPolicyMetadata {
    private let _policy: CorsPolicy

    /**
     * @brief 创建一个携带指定策略的元数据实例。
     * @param policy 要附加的 CORS 策略。
     */
    public init(policy: CorsPolicy) {
        _policy = policy
    }

    /**
     * @brief 返回当前元数据携带的 CORS 策略。
     * @return 当前元数据持有的 CORS 策略。
     */
    public prop policy: CorsPolicy {
        get() {
            _policy
        }
    }
}
