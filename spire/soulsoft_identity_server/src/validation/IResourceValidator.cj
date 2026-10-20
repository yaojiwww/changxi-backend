/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_identity_server.models.*

/**
 * @brief 定义资源验证器接口。
 */
public interface IResourceValidator {
    /**
     * @brief 根据客户端和作用域验证资源访问。
     * @param client 当前客户端。
     * @param grantType 授权类型。
     * @param scopes 请求作用域数组。
     * @return 返回验证通过的资源集合。
     */
    func validate(client: Client, grantType: String, scopes: Array<String>): ResourceCollection
}
