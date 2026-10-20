// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.metadata

import std.reflect.*

/**
 * @brief 提供 API 响应元数据。
 */
public interface IApiResponseMetadataProvider {
    /**
     * @brief 返回响应状态码。
     * @return 当前 API 响应的状态码。
     */
    prop status: Int64
    /**
     * @brief 返回响应类型信息。
     * @return 当前 API 响应的数据类型信息。
     */
    prop typeInfo: TypeInfo
}
