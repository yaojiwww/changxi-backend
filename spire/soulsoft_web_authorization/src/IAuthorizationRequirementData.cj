// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 定义可提供授权要求集合的元数据接口。
 */
public interface IAuthorizationRequirementData {
    /**
     * @brief 获取附加的授权要求集合。
     * @return 授权要求集合。
     */
    func getRequirements(): Collection<IAuthorizationRequirement>
}
