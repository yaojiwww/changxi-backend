// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.metadata

/**
 * @brief 提供 API 可见性元数据。
 */
public interface IApiVisibilityProvider {
    /**
     * @brief 返回当前 API 是否应被忽略。
     * @return 如果当前 API 需要从 OpenAPI 文档中忽略则返回 `true`。
     */
    prop ignore: Bool
}
