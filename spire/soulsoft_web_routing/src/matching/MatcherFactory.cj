// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_routing.http.*

/**
 * @brief 定义匹配器工厂的抽象基类。
 */
public abstract class MatcherFactory {
    /**
     * @brief 为指定端点数据源创建匹配器。
     * @param dataSource 端点数据源。
     * @return 创建得到的匹配器实例。
     */
    public func createMatcher(dataSource: EndpointDataSource): Matcher
}
