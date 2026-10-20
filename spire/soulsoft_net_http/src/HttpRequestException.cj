/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

/**
 * @brief 表示 HTTP 请求失败时抛出的异常。
 */
public class HttpRequestException <: Exception {
    
    private let _status: ?UInt16

    init(message: String, status: ?UInt16) {
        super(message)
        _status = status
    }

    /**
     * @brief 获取关联的 HTTP 状态码。
     * @return 异常关联的状态码；未知时返回 `None`。
     */
    public prop status: ?UInt16{
        get() {
            _status
        }
    }
}
