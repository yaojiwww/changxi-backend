// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

/**
 * @brief 表示一个身份验证令牌。
 */
public class AuthenticationToken {
    private let _name: String
    private let _value: String
    
    /**
     * @brief 创建一个身份验证令牌。
     * @param name 令牌名称。
     * @param value 令牌值。
     */
    public init(name: String, value: String) {
        _name = name
        _value = value
    }
    
    /**
     * @brief 返回令牌名称。
     * @return 令牌名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回令牌值。
     * @return 令牌值。
     */
    public prop value: String {
        get() {
            _value
        }
    }
}
