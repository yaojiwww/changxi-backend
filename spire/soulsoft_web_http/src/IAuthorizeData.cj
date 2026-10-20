// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义授权元数据。
 */
public interface IAuthorizeData {
    /**
     * @brief 返回当前授权策略名称。
     * @return 当前授权策略名称；如果未指定则返回空。
     */
    prop policy: ?String
    /**
     * @brief 返回当前要求的角色集合描述。
     * @return 当前角色集合描述；如果未指定则返回空。
     */
    prop roles: ?String
    /**
     * @brief 返回允许使用的认证方案集合描述。
     * @return 当前认证方案集合描述；如果未指定则返回空。
     */
    prop authenticationSchemes: ?String
}
