// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_routing.abstractions

/**
 * @brief 定义参数字面量节点匹配策略接口。
 */
public interface IParameterLiteralNodeMatchingPolicy <: IParameterPolicy {
    /**
     * @brief 检查字面量值是否满足参数策略。
     * @param parameterName 参数名称。
     * @param literal 待检查的字面量值。
     * @return 满足策略要求时返回 true。
     */
    func matchesLiteral(parameterName: String, literal: ?String): Bool
}
