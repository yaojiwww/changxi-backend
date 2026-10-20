// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

import std.io.*
import std.fs.*

/**
 * @brief 提供基于文件系统的文档读取实现。
 */
public class FileDocumentRetriever <: IDocumentRetriever {
    /**
     * @brief 读取指定文件地址的文档内容。
     * @param address 文档文件路径。
     * @return 返回文件中的文档字符串。
     */
    public func getDocument(address: String): String {
        try (fs = File(address, OpenMode.Read)) {
            return StringReader(fs).readToEnd()
        }
        throw UnsupportedException()
    }
}
