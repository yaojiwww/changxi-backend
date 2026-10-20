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
 * @brief 表示为类型或处理函数启用 CORS 的元数据。
 */
@Annotation[target: [MemberFunction, Type]]
public class EnableCors <: IEnableCors {
    private let _policyName: ?String

    /**
     * @brief 创建一个使用默认策略的启用 CORS 元数据。
     */
    public const init() {
        this(None)
    }

    /**
     * @brief 创建一个使用指定策略名称的启用 CORS 元数据。
     * @param policyName 要启用的 CORS 策略名称。
     */
    public const init(policyName: ?String) {
        _policyName = policyName
    }

    /**
     * @brief 返回当前元数据指定的策略名称。
     * @return 当前元数据关联的策略名称。
     */
    public prop policyName: ?String {
        get() {
            _policyName
        }
    }
}
