// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import stdx.encoding.url.Form

/**
 * @brief 表示 `application/x-www-form-urlencoded` 格式的 HTTP 内容。
 */
public class FormUrlContent <: ByteArrayContent {
    /**
     * @brief 使用键值集合创建表单编码内容。
     * @param values 要编码为表单数据的键值集合。
     */
    public init(values: Collection<(String, String)>) {
        super(serializeToByteArray(toForm(values)))
        super.headers.add(HeaderNames.ContentType, "application/x-www-form-urlencoded")
    }

    /**
     * @brief 使用表单对象创建表单编码内容。
     * @param form 要编码的表单对象。
     */
    public init(form: Form) {
        super(serializeToByteArray(form))
        super.headers.add(HeaderNames.ContentType, "application/x-www-form-urlencoded")
    }

    private static func serializeToByteArray(form: Form) {
        return form.toEncodeString().toArray()
    }

    private static func toForm(values: Collection<(String, String)>) {
        let form = Form()
        for ((key, value) in values) {
            form.add(key, value)
        }
        return form
    }
}
