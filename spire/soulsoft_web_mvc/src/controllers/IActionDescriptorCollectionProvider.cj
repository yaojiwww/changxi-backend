// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.controllers

/**
 * @brief 提供动作描述符集合访问能力。
 */
public interface IActionDescriptorCollectionProvider {
    /**
     * @brief 返回当前动作描述符集合。
     * @return 当前可用的动作描述符集合。
     */
    prop actionDescriptors: ActionDescriptorCollection
}
