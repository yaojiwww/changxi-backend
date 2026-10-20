/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.options

import soulsoft_identity_server.constants.*

/**
 * @brief 表示发现文档相关配置选项。
 */
public class DiscoveryOptions {
    /**
     * @brief 指示发现文档中是否公开密钥集。
     */
    public var showKeySet = true
    /**
     * @brief 指示发现文档中是否公开端点信息。
     */
    public var showEndpoints = true
}
