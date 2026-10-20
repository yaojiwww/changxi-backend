// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/**
 * @brief 表示构建服务提供者时使用的配置选项。
 */
public class ServiceProviderOptions {
    /**
     * @brief 指示是否启用作用域校验。
     */
    public var validateScopes = false

    /**
     * @brief 指示是否在构建阶段验证服务图。
     */
    public var validateOnBuild = false
}
