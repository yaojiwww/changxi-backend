// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.metadata

/**
 * @brief 提供 API 描述元数据。
 */
public interface IApiDescriptionMetadata {
    /**
     * @brief 返回 API 描述信息。
     * @return 当前 API 的描述信息。
     */
    prop description: ?String
}
