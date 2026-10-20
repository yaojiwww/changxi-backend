// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.fs.*
import std.collection.*
import stdx.encoding.json.*

protected class FileSystemKeyRepository <: IKeyRepository {
    private let _path: Path

    public init(path: Path) {
        _path = path
    }

    public func getAll(): ReadOnlyList<JsonObject> {
        ensureDirectoryExists()
        let files = ArrayList<JsonObject>()
        Directory.walk(_path) {
            file =>
                // ① 只处理普通文件，跳过子目录和符号链接
                if (!file.isRegular()) {
                    return true
                }
                // ② 只处理 .json 文件，过滤 .DS_Store、.tmp 等非密钥文件
                if (file.path.extensionName != "json") {
                    return true
                }
                if (!file.canRead()) {
                    return true
                }
                // ③ per-file 异常隔离：单个文件损坏不影响其他密钥加载
                try {
                    let bytes = File.readFrom(file.path)
                    // ④ 用 String.fromUtf8 替代 unsafe { String.withRawData }：
                    //    fromUtf8 验证 UTF-8 合法性，无效字节序列抛 IllegalArgumentException
                    let content = String.fromUtf8(bytes)
                    let json = JsonValue.fromStr(content).asObject()
                    files.add(json)
                } catch (_: Exception) {
                    // 记录错误后继续，保证其他密钥正常加载
                    //_logger.warn("Skipping unreadable key file '${file.path}': ${e.message}")
                }
                return true
        }
        return files
    }

    public func store(jsonObject: JsonObject, friendlyName: String): Unit {
        ensureDirectoryExists()
        let targetFile = _path.join(friendlyName)
        let tmpFile = _path.join("${friendlyName}.tmp")
        let content = jsonObject.toJsonString().toArray()
        // 先写临时文件，再原子 rename 到目标路径：
        // 防止写入过程中进程崩溃产生截断的 JSON 文件
        try {
            File.writeTo(tmpFile, content)
            rename(tmpFile, to: targetFile, overwrite: true)
        } catch (e: Exception) {
            // 清理残留的临时文件，防止下次 getAll 误读
            removeIfExists(tmpFile)
            throw e
        }
    }

    private func ensureDirectoryExists() {
        // try/catch 规避 TOCTOU：检查与创建之间可能被其他进程抢先创建
        try {
            Directory.create(_path, recursive: true)
        } catch (e: FSException) {
            // Directory.create 在目录已存在时抛 FSException，此时可安全忽略。
            // 若抛出时目录仍不存在，则是真实错误（权限不足等），重新抛出原始异常。
            if (!exists(_path)) {
                throw e // 重抛原始异常，保留原始错误消息
            }
        }
    }
}
