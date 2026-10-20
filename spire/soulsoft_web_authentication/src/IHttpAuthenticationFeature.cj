// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_identity_claims.*

/**
 * @brief 定义 HTTP 身份验证用户特性。
 */
public interface IHttpAuthenticationFeature {
    /**
     * @brief 返回当前 HTTP 上下文中的用户主体。
     */
    prop user: ?ClaimsPrincipal
}
