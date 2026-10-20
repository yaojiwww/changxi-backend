/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_web_http.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义扩展授权验证器接口。
 */
public interface IExtensionGrantValidator {
    /**
     * @brief 验证扩展授权请求。
     * @param request 扩展授权验证请求。
     * @return 返回验证通过的用户。
     */
    func validate(request: ExtensionGrantValidationRequest): IdentityUser
}

/**
 * @brief 表示扩展授权验证请求。
 */
public class ExtensionGrantValidationRequest {
    /**
     * @brief 创建扩展授权验证请求。
     * @param parameters 请求参数提供程序。
     * @param client 当前客户端。
     * @param resources 请求对应的资源集合。
     */
    public ExtensionGrantValidationRequest(public let parameters: IValueProvider, public let client: Client,
        public let resources: ResourceCollection) {
    }
}
