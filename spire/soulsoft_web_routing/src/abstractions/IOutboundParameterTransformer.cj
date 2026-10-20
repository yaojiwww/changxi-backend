// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.abstractions

/**
 * @brief 定义出站路由参数转换器接口。
 * @description 该接口用于在生成 URI 时将路由参数值转换为目标字符串表示。
 */
public interface IOutboundParameterTransformer <: IParameterPolicy {
    /**
     * @brief 将路由参数值转换为出站字符串。
     * @param value 原始路由参数值。
     * @return 转换后的字符串；无法转换时返回 None。
     */
    func transformOutbound(value: String): ?String
}
