// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

/**
 * @brief 表示静态文件中间件的配置选项。
 */
public class StaticFileOptions <: SharedOptionsBase {
    /**
     * @brief 创建使用独立共享状态的静态文件选项。
     */
    public init() {
        super(SharedOptions())
    }

    /**
     * @brief 使用指定共享状态创建静态文件选项。
     * @param sharedOptions 要共享的选项状态。
     */
    public init(sharedOptions: SharedOptions) {
        super(sharedOptions)
    }

    /**
     * @brief 获取或修改用于解析内容类型的提供器。
     */
    public var contentTypeProvider: ?IContentTypeProvider = None

    /**
     * @brief 获取或修改无法识别内容类型时使用的默认内容类型。
     */
    public var defaultContentType: ?String = None

    /**
     * @brief 获取或修改是否向未知内容类型的文件提供响应。
     */
    public var serveUnknownFileTypes: Bool = false

    /**
     * @brief 获取或修改写入静态文件响应正文前执行的回调。
     */
    public var onPrepareResponse: ?(StaticFileResponseContext) -> Unit = None
}
