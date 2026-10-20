// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.utilities

/**
 * @brief 表示 multipart 读取过程中使用的边界信息。
 */
public class MultipartBoundary {
    private let _boundaryBytes: Array<Byte>
    private var _expectLeadingCrlf = false

    /**
     * @brief 使用边界字符串创建实例。
     * @param value multipart 边界字符串。
     */
    public init(value: String) {
        _boundaryBytes = "\r\n--${value}".toArray()
    }

    /**
     * @brief 标记后续边界需要带前导 CRLF。
     */
    public func expectLeadingCrlf(): Unit {
        _expectLeadingCrlf = true
    }

    /**
     * @brief 检查当前是否仍位于首个边界之前。
     * @return 如果尚未经过首个边界则返回 true，否则返回 false。
     */
    public func beforeFirstBoundary(): Bool {
        !_expectLeadingCrlf
    }

    /**
     * @brief 返回当前边界字节序列。
     * @return 根据当前状态返回是否包含前导 CRLF 的边界字节序列。
     */
    public prop boundaryBytes: Array<Byte> {
        get() {
            if (_expectLeadingCrlf) {
                _boundaryBytes
            } else {
                _boundaryBytes[2..]
            }
        }
    }

    /**
     * @brief 返回最终边界的总长度。
     * @return 当前边界字节序列加结束标记 `--` 后的总长度。
     */
    public prop finalBoundaryLength: Int64 {
        get() {
            _boundaryBytes.size + 2
        }
    }
}
