// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_staticfiles.fileProviders

/**
 * @brief 表示可枚举的目录内容集合。
 */
public interface IDirectoryContents <: Iterable<IFileInfo> {
    /**
     * @brief 返回目录内容是否存在。
     * @return 如果目录内容存在则返回 true，否则返回 false。
     */
    prop exists: Bool
}
