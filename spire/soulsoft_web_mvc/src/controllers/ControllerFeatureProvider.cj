// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.controllers

import std.reflect.*
import std.collection.*
import soulsoft_web_mvc.applicationModels.*

/**
 * @brief 定义控制器特性提供器基类。
 */
public abstract class ControllerFeatureProvider <: ApplicationFeatureProvider<ControllerFeature> {
    /**
     * @brief 从应用程序部件中填充控制器特性。
     * @param parts 可供扫描的应用程序部件集合。
     * @param feature 要填充的控制器特性实例。
     */
    public func populate(parts: Collection<ApplicationPart>, feature: ControllerFeature): Unit {
        for (pattern in parts |> flatMap {f => f.typeInfos}) {
            if (isController(pattern) && !feature.controllers.contains(pattern)) {
                feature.controllers.add(pattern)
            }
        }
    }

    /**
     * @brief 检查指定类型是否应被视为控制器。
     * @param typeInfo 要检查的类型信息。
     * @return 如果该类型应被识别为控制器则返回 `true`。
     */
    public func isController(typeInfo: TypeInfo): Bool
}
