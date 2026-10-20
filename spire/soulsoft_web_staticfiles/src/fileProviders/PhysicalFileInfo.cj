// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.io.*
import std.fs.*
import std.time.*
import std.fs.exists as fs_exists

/**
 * @brief 表示物理文件系统中的文件信息。
 */
public class PhysicalFileInfo <: IFileInfo {
    private let _info: FileInfo

    /**
     * @brief 使用指定文件信息创建物理文件对象。
     * @param info 底层文件信息。
     */
    public init(info: FileInfo) {
        _info = info
    }

    /**
     * @brief 返回物理文件名称。
     * @return 当前文件名称。
     */
    public prop name: String {
        get() {
            _info.name
        }
    }

    /**
     * @brief 返回物理文件大小。
     * @return 当前文件的字节大小。
     */
    public prop size: Int64 {
        get() {
            _info.size
        }
    }

    /**
     * @brief 返回物理文件是否存在且可读。
     * @return 如果文件存在、可读且不是目录则返回 true，否则返回 false。
     */
    public prop exists: Bool {
        get() {
            fs_exists(_info.path) && _info.canRead() && !_info.isDirectory()
        }
    }

    /**
     * @brief 返回当前项是否为目录。
     * @return 如果底层项是目录则返回 true，否则返回 false。
     */
    public prop isDirectory: Bool {
        get() {
            _info.isDirectory()
        }
    }

    /**
     * @brief 返回物理文件路径。
     * @return 当前文件的物理路径。
     */
    public prop physicalPath: ?String {
        get() {
            _info.path.toString()
        }
    }

    /**
     * @brief 返回物理文件的最后修改时间。
     * @return 当前文件的最后修改时间。
     */
    public prop lastModified: DateTime {
        get() {
            _info.lastModificationTime
        }
    }

    /**
     * @brief 创建用于读取物理文件内容的输入流。
     * @return 指向当前文件的只读输入流。
     * @throws IOException 当文件无法打开时抛出异常。
     */
    public func createReadStream(): InputStream {
        return File(_info.path, OpenMode.Read)
    }
}
