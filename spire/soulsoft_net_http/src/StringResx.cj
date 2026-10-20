// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http


class StringResx {
    public static let net_http_operation_started = "This instance has already started one or more requests. Properties can only be modified before sending the first request."
    public static let net_http_handler_not_assigned = "The inner handler has not been assigned."
    public static let net_http_client_invalid_requesturi = "An invalid request URI was provided. Either the request URI must be an absolute URI or BaseAddress must be set."
    public static func net_http_headers_misused(name: String): String {
        "Misused header name, '${name}'. Make sure request headers are used with HttpRequestMessage, response headers with HttpResponseMessage, and content headers with HttpContent objects."
    }
    public static let net_http_content_stream_already_read = "The stream was already consumed. It can only be read once."
}