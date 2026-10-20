/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief JSON 序列化与反序列化异常。
 */
public class JsonSerializationException <: Exception {
    public let path: ?String
    public let inner: ?Exception

    public init() {
        super()
        path = None
        inner = None
    }

    public init(message: String) {
        super(message)
        path = None
        inner = None
    }

    public init(message: String, path: ?String) {
        super(message)
        this.path = path
        inner = None
    }

    public init(message: String, path: ?String, inner: ?Exception) {
        super(message)
        this.path = path
        this.inner = inner
    }

    protected override func getClassName(): String {
        return "JsonSerializationException"
    }
}
