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
 * @brief 定义身份验证过程使用的请求路径特性。
 */
public interface IAuthenticationFeature {
    /**
     * @brief 获取或设置进入身份验证流程时的原始路径。
     */
    mut prop originalPath: PathString
}
