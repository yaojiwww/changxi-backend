// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

/**
 * @brief 定义用于存放身份验证结果的功能特性。
 */
public interface IAuthenticateResultFeature {
    /**
     * @brief 获取或设置当前身份验证结果。
     */
    mut prop result: AuthenticateResult
}
