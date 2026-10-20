// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.services

/**
 * @brief 表示带名称的服务标识。
 */
public class NamedService {
    /**
     * @brief 表示服务名称。
     */
    public let name: String

    /**
     * @brief 创建带名称的服务标识实例。
     * @param name 服务名称。
     */
    public init(name: String) {
        this.name = name
    }
}
