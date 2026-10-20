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
 * @brief 表示为类型或处理函数禁用 CORS 的元数据。
 */
@Annotation[target: [MemberFunction, Type]]
public class DisableCors <: IDisableCors {

    /**
     * @brief 创建一个禁用 CORS 的元数据实例。
     */
    public const init() {
    }
}
