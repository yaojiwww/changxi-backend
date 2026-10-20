// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

/**
 * @brief 定义配置文档读取接口。
 */
public interface IDocumentRetriever {
    /**
     * @brief 读取指定地址的文档内容。
     * @param address 文档地址。
     * @return 返回读取到的文档字符串。
     */
    func getDocument(address: String): String
}
