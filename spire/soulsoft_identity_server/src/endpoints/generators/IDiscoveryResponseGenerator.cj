/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators

import soulsoft_identity_tokens.*
import soulsoft_identity_protocols_oidc.*

/**
 * @brief 定义 Discovery 端点响应生成器接口。
 */
public interface IDiscoveryResponseGenerator {
    /**
     * @brief 创建 Discovery 响应配置。
     * @return 返回 Discovery 配置对象。
     */
    func createDiscoveryResponse(): OpenIdConnectConfiguration

    /**
     * @brief 创建 JWKS 响应。
     * @return 返回 JSON Web Key Set 对象。
     */
    func createJwksResponse(): JsonWebKeySet
}
