// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_injection

/**
 * @brief 标记构造函数参数以从带键服务中解析依赖。
 */
@Annotation[target: [Parameter]]
public class FromKeyedServices {
    private let _mode: ServiceKeyLookupMode

    /**
     * @brief 创建一个继承父级服务键的参数注解。
     */
    public const init() {
        _mode = ServiceKeyLookupMode.Inherit
    }

    /**
     * @brief 创建一个显式指定服务键的参数注解。
     * @param key 要解析的服务键。
     */
    public const init(key: String) {
        _mode = ServiceKeyLookupMode.Explicit(key)
    }

    /**
     * @brief 返回当前注解使用的服务键查找模式。
     * @return 当前注解对应的服务键查找模式。
     */
    public prop mode: ServiceKeyLookupMode {
        get() {
            _mode
        }
    }
}

/**
 * @brief 表示 `FromKeyedServices` 使用的服务键查找方式。
 */
public enum ServiceKeyLookupMode {
    /**
     * @brief 表示显式使用指定服务键。
     */
    Explicit(String)
    /**
     * @brief 表示继承父级上下文中的服务键。
     */
    | Inherit
}
