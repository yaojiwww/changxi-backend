/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

protected func ensurePathDoesNotEndInSlash(path: String) {
    if (!path.isEmpty() && path.endsWith('/')) {
        throw Exception("path must not end in a slash: '${path}'")
    }
}

// RFC 9112 下这些响应在首部结束后即终止，不能再携带消息体。
protected func responseStatusMustNotHaveBody(statusCode: UInt16): Bool {
    return (statusCode >= UInt16(100) && statusCode < UInt16(200)) || statusCode == StatusCodes.NoContent ||
        statusCode == StatusCodes.ResetContent || statusCode == StatusCodes.NotModified
}
