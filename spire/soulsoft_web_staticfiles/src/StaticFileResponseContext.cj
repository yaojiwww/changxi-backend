// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import soulsoft_web_staticfiles.fileProviders.*

/**
 * @brief 表示静态文件响应准备阶段的上下文。
 */
public class StaticFileResponseContext {
    /**
     * @brief 创建静态文件响应上下文。
     * @param context 当前 HTTP 上下文。
     * @param file 即将写入响应的文件信息。
     */
    public StaticFileResponseContext(public let context: HttpContext, public let file: IFileInfo) {
    }
}
