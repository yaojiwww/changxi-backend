// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_net_http

/**
 * @brief 表示对象在已释放后仍被访问时抛出的异常。
 */
public class ObjectDisposedException <: Exception {
    private let _objectName: String

    init(objectName: String) {
        super("Cannot access a disposed object.")
        _objectName = objectName
    }

    /**
     * @brief 获取已释放对象的名称。
     * @return 已释放对象的名称。
     */
    public prop objectName: String {
        get() {
            _objectName
        }
    }
}
