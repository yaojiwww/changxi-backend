// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.applicationModels

import std.reflect.*

/**
 * @brief 表示可供 MVC 发现的应用程序部件。
 */
public abstract class ApplicationPart {
    /**
     * @brief 返回应用程序部件名称。
     * @return 当前应用程序部件的名称。
     */
    public prop name: String
    /**
     * @brief 返回应用程序部件包含的类型集合。
     * @return 当前应用程序部件公开的类型集合。
     */
    public prop typeInfos: Collection<TypeInfo>
}
