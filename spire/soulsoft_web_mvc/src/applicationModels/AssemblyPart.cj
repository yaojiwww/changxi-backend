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
 * @brief 表示由一组类型信息组成的程序集部件。
 */
public class AssemblyPart <: ApplicationPart {
    private let _name: String
    private let _typeInfos: Collection<TypeInfo>

    /**
     * @brief 创建程序集部件实例。
     * @param name 程序集部件名称。
     * @param typeInfos 程序集部件包含的类型集合。
     */
    public init(name: String, typeInfos: Collection<TypeInfo>) {
        _name = name
        _typeInfos = typeInfos
    }

    /**
     * @brief 返回程序集部件名称。
     * @return 当前程序集部件的名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回程序集部件包含的类型集合。
     * @return 当前程序集部件公开的类型集合。
     */
    public prop typeInfos: Collection<TypeInfo> {
        get() {
            _typeInfos
        }
    }
}
