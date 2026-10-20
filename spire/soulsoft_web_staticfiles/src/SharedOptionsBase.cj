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
 * @brief 表示静态文件共享选项的抽象基类。
 * @description 该基类将公共属性委托到同一个 SharedOptions 实例，使组合选项与子选项共享配置状态。
 */
public abstract class SharedOptionsBase {
    /**
     * @brief 表示供派生类访问的底层共享状态。
     */
    protected let sharedOptions: SharedOptions

    /**
     * @brief 使用共享选项创建选项基类。
     * @param sharedOptions 底层共享选项对象。
     */
    protected init(sharedOptions: SharedOptions) {
        this.sharedOptions = sharedOptions
    }

    /**
     * @brief 获取或修改映射到静态资源的相对请求路径。
     * @return 当前配置的请求路径。
     * @throws IllegalArgumentException 当路径以斜杠结尾时抛出。
     */
    public mut prop requestPath: PathString {
        get() {
            sharedOptions.requestPath
        }
        set(value) {
            sharedOptions.requestPath = value
        }
    }

    /**
     * @brief 获取或修改用于定位资源的文件提供器。
     * @return 当前配置的文件提供器；未设置时返回空。
     */
    public mut prop fileProvider: ?IFileProvider {
        get() {
            sharedOptions.fileProvider
        }
        set(value) {
            sharedOptions.fileProvider = value
        }
    }

    /**
     * @brief 获取或修改是否在目录请求末尾追加斜杠后重定向。
     * @return 是否启用尾部斜杠重定向。
     */
    public mut prop redirectToAppendTrailingSlash: Bool {
        get() {
            sharedOptions.redirectToAppendTrailingSlash
        }
        set(value) {
            sharedOptions.redirectToAppendTrailingSlash = value
        }
    }
}
