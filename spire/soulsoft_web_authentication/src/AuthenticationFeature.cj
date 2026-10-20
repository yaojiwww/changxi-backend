// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 保存身份验证中使用的原始请求路径。
 */
public class AuthenticationFeature <: IAuthenticationFeature {
    private var _originalPath: PathString

    /**
     * @brief 创建一个身份验证特性实例。
     * @param originalPath 原始请求路径。
     */
    public init(originalPath: PathString) {
        _originalPath = originalPath
    }

    /**
     * @brief 获取或设置原始请求路径。
     */
    public mut prop originalPath: PathString {
        get() {
            _originalPath
        }
        set(value) {
            _originalPath = value
        }
    }
}
