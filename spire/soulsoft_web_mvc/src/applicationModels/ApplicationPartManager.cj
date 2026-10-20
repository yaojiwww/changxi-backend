// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.applicationModels

import std.collection.*

/**
 * @brief 管理 MVC 可发现的应用程序部件和特性提供器。
 */
public class ApplicationPartManager {
    private let _parts = ArrayList<ApplicationPart>()
    private let _featureProviders = ArrayList<IApplicationFeatureProvider>()

    /**
     * @brief 创建应用程序部件管理器实例。
     */
    public init() {
    }

    /**
     * @brief 返回已注册的应用程序部件列表。
     * @return 当前已注册的应用程序部件集合。
     */
    public prop parts: List<ApplicationPart> {
        get() {
            _parts
        }
    }

    /**
     * @brief 返回已注册的特性提供器列表。
     * @return 当前已注册的特性提供器集合。
     */
    public prop featureProviders: List<IApplicationFeatureProvider> {
        get() {
            _featureProviders
        }
    }

    /**
     * @brief 使用匹配的特性提供器填充指定特性实例。
     * @param feature 要填充的特性实例。
     */
    public func populateFeature<TFeature>(feature: TFeature): Unit {
        for (pattern in _featureProviders |> filterMap {f => f as ApplicationFeatureProvider<TFeature>}) {
            pattern.populate(_parts, feature)
        }
    }
}
