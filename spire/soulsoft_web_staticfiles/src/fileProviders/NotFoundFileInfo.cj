// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.io.*
import std.time.*

/**
 * @brief 表示一个不存在的文件项。
 */
public class NotFoundFileInfo <: IFileInfo {
    private let _name: String

    /**
     * @brief 使用给定名称创建不存在的文件项。
     * @param name 不存在的文件名称。
     */
    public init(name: String) {
        _name = name
    }

    /**
     * @brief 返回不存在文件的名称。
     * @return 不存在文件的名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回不存在文件的大小占位值。
     * @return 固定返回 -1。
     */
    public prop size: Int64 {
        get() {
            -1
        }
    }

    /**
     * @brief 返回文件是否存在。
     * @return 固定返回 false。
     */
    public prop exists: Bool {
        get() {
            false
        }
    }

    /**
     * @brief 返回当前项是否为目录。
     * @return 固定返回 false。
     */
    public prop isDirectory: Bool {
        get() {
            false
        }
    }

    /**
     * @brief 返回不存在文件的物理路径。
     * @return 固定返回空。
     */
    public prop physicalPath: ?String {
        get() {
            None
        }
    }

    /**
     * @brief 返回不存在文件的默认修改时间。
     * @return 固定返回 Unix 纪元时间。
     */
    public prop lastModified: DateTime {
        get() {
            return DateTime.of(year: 1970, month: 1, dayOfMonth: 1)
        }
    }

    /**
     * @brief 为不存在的文件创建读取流。
     * @return 不会返回有效输入流。
     * @throws IOException 调用时总是抛出异常。
     */
    public func createReadStream(): InputStream {
        throw IOException()
    }
}
