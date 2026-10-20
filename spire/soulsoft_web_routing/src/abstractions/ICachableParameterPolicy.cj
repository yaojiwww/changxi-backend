// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.abstractions

/**
 * @brief 标记可安全缓存的参数策略接口。
 * @description 实现该接口的无状态参数策略可由缓存工厂复用，避免重复创建实例。
 */
public interface ICachableParameterPolicy {
}
