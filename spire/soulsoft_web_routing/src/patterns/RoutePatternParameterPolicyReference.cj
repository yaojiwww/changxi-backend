// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import soulsoft_web_routing.abstractions.*

/**
 * @brief 表示路由参数策略引用。
 */
public class RoutePatternParameterPolicyReference {
    private let _content: ?String
    private let _parameterPolicy: ?IParameterPolicy

    init(content: String) {
        _content = Some(content)
        _parameterPolicy = None
    }

    init(parameterPolicy: IParameterPolicy) {
        _content = None
        _parameterPolicy = Some(parameterPolicy)
    }

    /**
     * @brief 返回字符串形式的策略内容。
     * @return 策略文本；不存在时返回 None。
     */
    public prop content: ?String {
        get() {
            _content
        }
    }

    /**
     * @brief 返回实例形式的参数策略对象。
     * @return 参数策略实例；不存在时返回 None。
     */
    public prop parameterPolicy: ?IParameterPolicy {
        get() {
            _parameterPolicy
        }
    }
}
