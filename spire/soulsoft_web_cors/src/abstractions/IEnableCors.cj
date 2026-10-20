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
 * @brief 定义启用 CORS 所需的元数据。
 */
public interface IEnableCors <: ICorsMetadata {
    /**
     * @brief 返回当前元数据指定的 CORS 策略名称。
     * @return 当前元数据关联的策略名称；如果为空则表示使用默认策略。
     */
    prop policyName: ?String
}
