// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.utilities

/**
 * @brief 提供字符串处理工具方法。
 */
protected class StringUtilities {
    private init() {}

    /**
     * @brief 将字符串首字母转为小写，其余字符保持不变。
     * @param s 输入字符串。
     * @return 首字母小写后的字符串。
     */
    public static func lowerFirst(s: String): String {
        if (s.isEmpty()) {
            return s
        }
        return "${s[0..1].toAsciiLower()}${s[1..s.size]}"
    }
}
