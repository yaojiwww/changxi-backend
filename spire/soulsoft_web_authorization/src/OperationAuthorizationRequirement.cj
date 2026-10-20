// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示携带操作名称的资源级授权要求。
 */
public class OperationAuthorizationRequirement <: IAuthorizationRequirement {
    private let _name: String

    /**
     * @brief 创建一个操作授权要求。
     * @param name 操作名称。
     */
    public init(name: String) {
        _name = name
    }

    /**
     * @brief 获取操作名称。
     * @return 当前授权要求绑定的操作名称。
     */
    public prop name: String {
        get() { _name }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        "OperationAuthorizationRequirement:Name=${_name}"
    }
}
