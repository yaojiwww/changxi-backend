// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

/**
 * @brief 提供静态资源路径到内容类型的映射能力。
 */
public interface IContentTypeProvider {  
    /**
     * @brief 根据路径解析对应的内容类型。
     * @param path 要解析的资源路径。
     * @return 匹配到的内容类型；未匹配时返回空。
     */
    func getContentType(path: String): ?String
}
