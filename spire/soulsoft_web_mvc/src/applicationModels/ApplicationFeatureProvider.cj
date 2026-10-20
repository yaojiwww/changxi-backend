// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.applicationModels

/**
 * @brief 定义应用程序特性提供器基类。
 */
public abstract class ApplicationFeatureProvider<TFeature> <: IApplicationFeatureProvider {
    /**
     * @brief 使用应用程序部件填充指定特性。
     * @param parts 可供扫描的应用程序部件集合。
     * @param feature 要填充的特性实例。
     */
    public func populate(parts: Collection<ApplicationPart>, feature: TFeature): Unit
}
