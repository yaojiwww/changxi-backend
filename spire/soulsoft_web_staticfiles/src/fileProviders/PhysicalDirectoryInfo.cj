// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.fs.*
import std.io.*
import std.time.*
import std.collection.*
import std.fs.exists as fs_exists

/**
 * @brief 表示物理文件系统中的目录信息及其内容集合。
 */
public class PhysicalDirectoryInfo <: IDirectoryContents & IFileInfo {
    private let _info: FileInfo
    private let _filters: ExclusionFilters
    // None 表示尚未初始化，Some 表示已枚举完成
    private var _entries: ?ArrayList<IFileInfo> = None

    /**
     * @brief 使用默认过滤规则创建物理目录对象。
     * @param info 底层目录信息。
     */
    public init(info: FileInfo) {
        _info = info
        _filters = ExclusionFilters.Sensitive
    }

    /**
     * @brief 使用指定过滤规则创建物理目录对象。
     * @param info 底层目录信息。
     * @param filters 要应用的排除过滤标志。
     */
    public init(info: FileInfo, filters: ExclusionFilters) {
        _info = info
        _filters = filters
    }

    /**
     * @brief 返回目录是否存在。
     * @return 如果底层路径存在且为目录则返回 true，否则返回 false。
     */
    public prop exists: Bool {
        get() {
            _info.isDirectory() && fs_exists(_info.path)
        }
    }

    /**
     * @brief 返回目录内容的迭代器。
     * @return 当前目录下可访问文件项的迭代器。
     */
    public func iterator(): Iterator<IFileInfo> {
        ensureInitialized()
        return (_entries ?? ArrayList<IFileInfo>()).iterator()
    }

    /**
     * @brief 返回目录名称。
     * @return 当前目录名称。
     */
    public prop name: String {
        get() {
            _info.name
        }
    }

    /**
     * @brief 返回目录大小占位值。
     * @return 固定返回 -1。
     */
    public prop size: Int64 {
        get() {
            -1 // 目录无固定大小
        }
    }

    /**
     * @brief 返回当前项是否为目录。
     * @return 固定返回 true。
     */
    public prop isDirectory: Bool {
        get() {
            true
        }
    }

    /**
     * @brief 返回目录的物理路径。
     * @return 当前目录的物理路径。
     */
    public prop physicalPath: ?String {
        get() {
            _info.path.toString()
        }
    }

    /**
     * @brief 返回目录的最后修改时间。
     * @return 当前目录的最后修改时间。
     */
    public prop lastModified: DateTime {
        get() {
            _info.lastModificationTime
        }
    }

    /**
     * @brief 为目录创建读取流。
     * @return 不会返回有效输入流。
     * @throws UnsupportedException 调用时总是抛出异常。
     */
    public func createReadStream(): InputStream {
        throw UnsupportedException("Cannot create read stream for directory")
    }

    // ─── 内部辅助 ─────────────────────────────────────────────────────────

    private func ensureInitialized(): Unit {
        if (_entries.isSome()) {
            return
        }
        let entries = ArrayList<IFileInfo>()
        try {
            let items = Directory.readFrom(_info.path)
            for (fileInfo in items) {
                // 应用 ExclusionFilters 过滤（DotPrefixed / Hidden / System）
                if (FileSystemInfoHelper.isExcluded(fileInfo, _filters)) {
                    continue
                }
                let childPath = _info.path.join(fileInfo.name)
                if (fileInfo.isDirectory()) {
                    entries.add(PhysicalDirectoryInfo(FileInfo(childPath), _filters))
                } else {
                    entries.add(PhysicalFileInfo(FileInfo(childPath)))
                }
            }
        } catch (e: IOException) {
            // 目录无法读取时返回空列表，不向上抛出
        }
        _entries = Some(entries)
    }
}
