// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

import soulsoft_web_http.*

/**
 * @brief 定义携带 CORS 策略元数据的能力。
 */
public interface ICorsPolicyMetadata <: ICorsMetadata {
    /**
     * @brief 返回当前元数据关联的 CORS 策略。
     * @return 当前元数据关联的 CORS 策略。
     */
    prop policy: CorsPolicy
}
