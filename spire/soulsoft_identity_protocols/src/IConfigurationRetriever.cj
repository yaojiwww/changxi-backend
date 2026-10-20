// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

/**
 * @brief 定义协议配置检索器接口。
 */
public interface IConfigurationRetriever<T> {
    /**
     * @brief 从指定地址检索配置对象。
     * @param address 配置文档地址。
     * @param documentRetriever 用于读取文档内容的检索器。
     * @return 返回解析后的配置对象。
     */
    func getConfiguration(address: String, documentRetriever: IDocumentRetriever): T
}
